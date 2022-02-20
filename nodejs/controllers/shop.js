const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

app.use(bodyParser.json());

exports.getProduct = (req, res, next) => {
  
  if (!Number(req.params.id)) return res.json({'Error': 'This URL does not lead to any products.'});
  let id = Number(req.params.id);

  let materials = [];
  let tags = [];
  let imgUrl = [];
  let reviews = [];
  var sql = 'CALL selectProduct(?)';

  conn = connectDb()
  conn.query(sql,
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        let result = [];
        rows[0].forEach((rows) => { materials.push(rows.material_name) });
        rows[1].forEach((rows) => { tags.push(rows.tag_name) });
        rows[2].forEach((rows) => { imgUrl.push(rows.resource_link) });
        rows[3].forEach((rows) => { reviews.push(rows) });
        result = rows[4];
        result[0].materials = materials;
        result[0].tags = tags;
        result[0].imgUrl = imgUrl;
        result[0].reviews = reviews;
        res.status(200);
        res.json(result[0]);
      }
    }
  );
  conn.end();

};
exports.getReviewById = (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);

  conn.query('SELECT review.review_id AS reviewId, review.product_id AS productId, review.member_id AS memberId, review.rating, review.points, review.title, review.content, review.published_at AS publishedAt, member.first_name AS userFirstName, member.last_name AS userLastName FROM review INNER JOIN member ON member.member_id = review.member_id WHERE review.review_id = ?',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows[0]);
      }
    }
  );
  conn.end();
};
exports.getAllProducts = (req, res, next) => {
  conn = connectDb()

  conn.query('SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product.is_published = TRUE;',
    (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows);
      }
    }
  );
  conn.end();
};
exports.getProductsBySeller = (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);
  let sorter = req.query.orderby;
  //console.log(sorter);
  var sql = 'SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product.is_published = TRUE AND product.vendor_id = ?';
  if (req.query.term) {
    //console.log(req.query.term);
    sql += " AND product.name LIKE " + conn.escape('%' + req.query.term + '%');
  }
  if (sorter != undefined) {
    let order;
    switch (sorter) {
      case 'Legújabb':
        order = ' ORDER BY published_at DESC'
        break;
      case 'Legrégebbi':
        order = ' ORDER BY published_at'
        break;
      case 'Ár szerint csökkenő':
        order = ' ORDER BY price DESC'
        break;
      case 'Ár szerint növekvő':
        order = ' ORDER BY price'
        break;
      case 'Készleten':
        order = ' AND product.inventory > 0'
        break;
      default:
        order = "";
        break;
    }
    sql += order;
  }
  conn.query(sql,
    [id, "ORDER BY product.price DESC"], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows);
      }
    }
  );
  conn.end();
};
exports.getUserShort = (req, res, next) => {

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');
  let id = Number(req.params.id);

  let sql = 'CALL selectUserShort(?, ?)'
  
  conn = connectDb()
  conn.query(sql,
    [id, 0], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows[0][0]);
      }
    }
  );
  conn.end();
};
exports.getUser = (req, res, next) => {

  if (!Number(req.params.id)) return res.json({'Error': 'This URL does not lead to any products.'});
  let id = Number(req.params.id);
  let sql = 'CALL selectUser(?, ?)';

  conn = connectDb();
  conn.query(sql,
    [id, 0], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(rows[0][0]);
      }
    }
  );
  conn.end();
};
exports.getWishList = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error': 'This URL does not lead to any products.'});
  let id = Number(req.params.id);

  let sql = 'CALL selectWishList(?)';
  conn = connectDb();
  conn.query(sql,
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(rows[0]);
      }
    }
  );
  conn.end();
};