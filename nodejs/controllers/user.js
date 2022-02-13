const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

exports.getMyProducts = (req, res, next) => {

  if (!Number(req.params.id)) return res.json({'Error':'This product does not exist.'});

  conn = connectDb()
  let id = Number(req.params.id);
  let sorter = req.query.orderby;

  var sql = 'SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, product.is_published AS isPublic, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product.vendor_id = ?';
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
      case 'Közzétett':
        order = ' AND product.is_published = TRUE'
        break;
      case 'Nincs közzétéve':
        order = ' AND product.is_published = FALSE'
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
function stringifyArray(array) {
  let strArray = '';
  for (let index = 0; index < array.length; index++) {
    const element = array[index];
    strArray += ( "(" + (index + 1) + ",\'" + element + "\'");
    if (index == (array.length - 1)) {
      strArray += ")";
    }
    else{
      strArray += "),";
    }
  }
  return strArray;
};
exports.postNewProduct = (req, res, next) => {
  product = req.body;
  let productId;
  var publshedAt = product.isPublic ? new Date() : null;
  let matString = stringifyArray(product.materials);
  let tagString = stringifyArray(product.tags);
  let picString = stringifyArray(product.imgUrl);

  var sql = 'CALL insertProduct(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )';
  conn = connectDb()
  conn.query(sql,
    [
      product.name,
      product.price,
      product.description,
      product.inventory,
      product.delivery,
      product.category,
      product.sellerId,
      product.discount,
      product.isPublic,
      new Date(),
      publshedAt,
      tagString,
      product.tags.length,
      matString,
      product.materials.length,
      picString,
      product.imgUrl.length,
      1
    ], (err, results, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(201);
        res.json(product)
      }
    }
  )
  conn.end();
};
exports.deleteProduct = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error':'This product does not exist.'});

  let id = Number(req.params.id);
  // TO DO: check if an order not yet delivered exists 
  let sql = 'CALL deleteProduct(?)';
  conn = connectDb()
  conn.query(sql, [id], (err, results, fields) => {
    if (err) return console.log("Query " + err)
    else {
      res.status(200);
      res.json();
    }
  }
  )
  conn.end();
};
exports.updateProduct = (req, res, next) => {
  product = req.body;
  if (!Number(req.params.id)) return res.json({'Error':'This product does not exist.'});
  let id = Number(req.params.id);
  let sql = 'CALL updateProduct(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  conn = connectDb()
  conn.query(sql,
    [
      product.name,
      product.price,
      product.description,
      product.inventory,
      product.delivery,
      product.category,
      product.discount,
      product.isPublic,
      new Date(),
      product.publishedAt,
      id,
      stringifyArray(product.tags),
      product.tags.length,
      stringifyArray(product.materials),
      product.materials.length,
      stringifyArray(product.imgUrl),
      product.imgUrl.length,
      1
    ], (err, results, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(product);
      }
    }
  )
  conn.end();
};
exports.changeProductVisibility = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'This product does not exist.'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL changeProductVisibility(?, ?, ?)'
  conn.query(sql, [req.body.isPublic, new Date(), id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json();
    }
  })
};
exports.postWishList = (req, res, next) => {
  let wishList = req.body;
  let sql = 'CALL insertWishList(?, ?, ?)';
  conn = connectDb();
  conn.query(sql, [wishList.productId, wishList.userId, new Date()], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
}
exports.postCart = (req, res, next) => {
  let cart = req.body;
  let sql = 'CALL insertCart(?, ?)';
  conn = connectDb();
  conn.query(sql, [cart.userId, cart.productId], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
}
exports.getCart = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'This product does not exist.'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectCart(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json(results[0]);
    }
  })
}