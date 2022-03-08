const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

app.use(bodyParser.json());

exports.getProduct = (req, res, next) => {

  if (!Number(req.params.id)) return res.json({ 'Error': 'This URL does not lead to any products.' });
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

  conn.query('CALL selectReview(?, ?)',
    [id, 0], (err, rows, fields) => {
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

  if (!Number(req.params.id)) return res.json({ 'Error': 'This URL does not lead to any products.' });
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
  if (!Number(req.params.id)) return res.json({ 'Error': 'This URL does not lead to any products.' });
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

exports.searchProducts = (req, res, next) => {

  const categories = [
    "Zöldség",
    "Gyümölcs",
    "Pékáru",
    "Tejtermék",
    "Ital",
    "Ékszer",
    "Művészet",
    "Divat"
  ]

  const tags = [
    "Környezetbarát",
    "Kézzel készült",
    "Etikusan beszerzett alapanyagok",
    "Vegán",
    "Vegetáriánus",
    "Organikus",
    "Bio",
    "Helyben termesztett",
  ]

  let sql = `
    SELECT DISTINCT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl 
    FROM product 
    INNER JOIN member ON member.member_id = product.vendor_id
    INNER JOIN product_tag ON product.product_id = product_tag.product_id
    INNER JOIN tag ON tag.tag_id = product_tag.tag_id
    WHERE `;

  let selectedCategories = categories.filter(x => req.query[x] == 'true');
  let selectedTags = tags.filter(x => req.query[x] == 'true');

  if (selectedCategories.length > 0) {
    sql += 'product.category IN (';
    for (let i = 0; i < selectedCategories.length; i++) {
      const cat = selectedCategories[i];
      sql += '\"' + cat + '\"';
      if ((selectedCategories.length - 1) != i) {
        sql += ", ";
      }
    }
    sql += ')';
  }
  if (selectedTags.length > 0) {
    for (let i = 0; i < selectedTags.length; i++) {
      const tag = selectedTags[i];
      if (selectedCategories.length != 0 || i > 0) {
        sql += ' AND ';
      }
      sql += 'tag.tag_name = \"' + tag + '\"';
    }
  }
  if (req.query['minPrice']) {
    if (selectedCategories.length != 0 || selectedTags.length != 0) {
      sql += ' AND ';
    }
    sql += 'product.price > ' + req.query['minPrice'];
  }
  if (req.query['maxPrice']) {
    if (selectedCategories.length != 0 || selectedTags.length != 0 || req.query['minPrice']) {
      sql += ' AND ';
    }
    sql += 'product.price < ' + req.query['maxPrice'];
  }
  if (req.query['inStock'] == 'true') {
    if (selectedCategories.length != 0 || selectedTags.length != 0 || req.query['minPrice'] || req.query['maxPrice']) {
      sql += ' AND ';
    }
    sql += 'product.inventory > 0';
  }
  if (req.query['madeOnDemand'] == 'true') {
    if (selectedCategories.length != 0 || selectedTags.length != 0 || req.query['minPrice'] || req.query['maxPrice'] || req.query['inStock'] == 'true') {
      sql += ' AND ';
    }
    sql += 'product.delivery = \'Megrendelésre készül\'';
  }
  if (req.query['discount'] == 'true') {
    if (selectedCategories.length != 0 || selectedTags.length != 0 || req.query['minPrice'] || req.query['maxPrice'] || req.query['inStock'] == 'true' || req.query['madeOnDemand'] == 'true') {
      sql += ' AND ';
    }
    sql += 'product.discount IS NOT NULL ';
  }
  if (selectedCategories.length == 0 && selectedTags.length == 0 && !req.query['minPrice'] && !req.query['maxPrice'] && req.query['inStock'] != 'true' && req.query['madeOnDemand'] != 'true' && req.query['discount'] != 'true') {
    sql += '1';
  }
  sql += ' ORDER BY product.rating DESC';
  //console.log(sql);
  conn = connectDb();
  conn.query(sql,
    [], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(rows);
      }
    }
  );
  conn.end();
};