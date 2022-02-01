const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

exports.getMyProducts = (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);
  let sorter = req.query.orderby;
  //console.log(sorter);
  var sql = 'SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product.vendor_id = ?';
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
};
exports.postNewProduct = (req, res, next) => {
  product = req.body;
  let productId;
  var publshedAt = product.isPublic ? new Date() : null;
  var sql = 'INSERT INTO `product`(`name`, `price`, `description`, `inventory`, `delivery`, `category`, `vendor_id`, `discount`, `is_published`, `created_at`, `published_at`)';
  sql += 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
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
      publshedAt
    ], (err, results, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        productId = results.insertId;
        insertMaterials(productId, product.materials);
      }
    }
  )
};
async function insertMaterials(productId, materials) {
  materials.forEach(material => {
    let sql = 'SELECT material.material_id FROM material WHERE material.material_name = ?';
    conn.query(sql, [material], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else if (rows[0] == undefined) {
        let sql = 'INSERT INTO `material`(`material_name`) VALUES (?)'
        conn.query(sql, [material], (err, results, fields) => {
          if (err) res.json("Query error: " + err)
          else {
            insertMaterial(results.insertId, productId);
          }
        })
      }
      else {
        insertMaterial(rows[0].material_id, productId);
      }
    });
  });
}
async function insertMaterial(materialId, productId) {
  let sql = 'INSERT INTO `product_material`(`material_id`, `product_id`) VALUES (?, ?)'
  conn.query(sql, [materialId, productId], (err, rows, fields) => {
    if (err) res.json("Query error: " + err)
    else {
      return true;
    }
  })
}