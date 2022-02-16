const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

app.use(bodyParser.json());

exports.getProductById = (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);
  let materials = [];
  let tags = [];
  let imgUrl = [];
  let reviews = [];

  conn.query('SELECT material_name FROM material INNER JOIN product_material ON material.material_id = product_material.material_id WHERE product_material.product_id = ?',
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        rows.forEach((rows) => { materials.push(rows.material_name) });
      }
    }
  );
  conn.query('SELECT tag_name FROM tag INNER JOIN product_tag ON tag.tag_id = product_tag.tag_id WHERE product_tag.product_id = ?',
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        rows.forEach((rows) => { tags.push(rows.tag_name) });
      }
    }
  );
  conn.query('SELECT product_picture.resource_link FROM product_picture WHERE product_picture.product_id = ?',
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        rows.forEach((rows) => { imgUrl.push(rows.resource_link) });
      }
    }
  );
  conn.query('SELECT review.review_id AS reviewId, review.member_id AS userId, review.rating, review.title, review.content, review.published_at AS publishedAt, member.first_name AS userFirstName, member.last_name AS userLastName FROM review INNER JOIN member ON member.member_id = review.member_id WHERE review.product_id = ?;',
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        rows.forEach((rows) => { reviews.push(rows) });
      }
    }
  );
  conn.query('SELECT product.product_id AS productId, product.name, product.price, product.description, product.inventory, product.delivery, product.category, product.rating, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, product.created_at AS createdAt, product.last_updated_at AS lastUpdatedAt, product.published_at AS publishedAt, member.first_name AS sellerFirstName, member.last_name AS sellerLastName FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product_id = ?',
    [id], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else if (rows[0] == undefined) {
        res.json('Error: This product does not exist.');
      }
      else {
        rows[0].materials = materials;
        rows[0].tags = tags;
        rows[0].imgUrl = imgUrl;
        rows[0].reviews = reviews;
        res.json(rows[0]);
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

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);

  conn.query('SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, vendor_detail.takes_custom_orders AS takesCustomOrders FROM member INNER JOIN vendor_detail ON vendor_detail.member_id = member.member_id WHERE member.member_id = ?',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows[0]);
      }
    }
  );
  conn.end();
};
exports.getUser = (req, res, next) => {

  if (!Number(req.params.id)) return res.json({'Error': 'This URL does not lead to any products.'});
  let id = Number(req.params.id);
  let sql = 'CALL selectUser(?)';

  conn = connectDb();
  conn.query(sql,
    [id], (err, rows, fields) => {
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
  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');
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