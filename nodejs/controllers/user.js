const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

exports.getMyProducts = (req, res, next) => {

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

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
      if (err) res.json("Query " + err)
      else {
        productId = results.insertId;
        insertMaterials(productId, product.materials);
        insertTags(productId, product.tags);
        insertPicture(product.imgUrl[0], productId);
        res.status(201);
        res.json(product)
      }
    }
  )
  conn.end();
};
async function insertMaterials(productId, materials) {
  materials.forEach(material => {
    let sql = 'SELECT material.material_id FROM material WHERE material.material_name = ? LIMIT 1';
    conn.query(sql, [material], (err, rows, fields) => {
      if (err) return ("Query " + err)
      else if (rows[0] == undefined) {
        let sql = 'INSERT INTO `material`(`material_name`) VALUES (?)'
        conn.query(sql, [material], (err, results, fields) => {
          if (err) return "Query " + err;
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
    if (err) return "Query " + err;
    else {
      return true;
    }
  })
}
async function insertTags(productId, tags) {
  tags.forEach(tag => {
    let sql = 'SELECT `tag_id` FROM `tag` WHERE tag_name = ? LIMIT 1';
    conn.query(sql, [tag], (err, result, fields) => {
      if (err) return "Query " + err;
      else {
        if (result[0] != undefined) {
          insertTag(result[0].tag_id, productId);
        }
      }
    });
  });
}
async function insertTag(tagId, productId) {
  let sql = 'INSERT INTO `product_tag`(`tag_id`, `product_id`) VALUES (?, ?)';
  conn.query(sql, [tagId, productId], (err, rows, fields) => {
    if (err) return "Query " + err;
    else {
      return true;
    }
  })
}
async function insertPicture(imgUrl, productId) {
  let sql = 'INSERT INTO `product_picture`(`product_id`, `resource_link`, `is_thumbnail`) VALUES (?, ?, TRUE)';
  conn.query(sql, [productId, imgUrl], (err, rows, fields) => {
    if (err) return "Query " + err;
    else {
      return true;
    }
  })
}
exports.deleteProduct = (req, res, next) => {
  if (!Number(req.params.id)) return res.json('Error: This product does not exist.');

  let id = Number(req.params.id);
  // check if an order not yet delivered exists 
  // let sql =  '';
  // conn.query(sql, [id], (err, results, fields) => {
  //   if (err) res.json("Query " + err)
  //   else {

  //   }
  // }
  // )

  let stmts = [
    'DELETE FROM `product_material` WHERE product_id = ?',
    'DELETE FROM `product_picture` WHERE product_id = ?',
    'DELETE FROM `product_tag` WHERE product_id = ?',
    'UPDATE `product` SET `name`="Eltávolított termék",`price`=NULL,`description`=NULL,`inventory`=NULL,`delivery`=NULL,`category`=NULL,`rating`=NULL,`vendor_id`=NULL,`discount`=NULL,`is_published`=FALSE,`is_removed`=TRUE,`created_at`=NULL,`last_updated_at`=NULL,`published_at`=NULL WHERE `product_id` = ?'
  ];
  conn = connectDb()
  stmts.forEach(stmt => {
    conn.query(stmt, [id], (err, results, fields) => {
      if (err) return console.log("Query " + err)
      else {
        //res.status(200);
      }
    }
    )
  });
  res.status(200);
  res.json();
  conn.end();
}
exports.updateProduct = (req, res, next) => {
  product = req.body;
  if (!Number(req.params.id)) return res.json('Error: This product does not exist.');
  let id = Number(req.params.id);
  let sql = 'UPDATE `product` SET `name`=?,`price`=?,`description`=?,`inventory`=?,`delivery`=?,`category`=?,`discount`=?,`is_published`=?,`last_updated_at`=?,`published_at`=? WHERE product_id = ?';
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
      id
    ], (err, results, fields) => {
      if (err) res.json("Query " + err)
      else {
        res.status(200);
        res.json(product)
      }
    }
  )
  conn.end();
}
exports.changeProductVisibility = (req, res, next) => {
  if (!Number(req.params.id)) return res.json('Error: This product does not exist.');
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'UPDATE `product` SET `is_published`=?,`last_updated_at`=? WHERE product_id = ?'
  conn.query(sql, [req.body.isPublic, new Date(), id], 
  (err, results, fields) => {
    if (err) res.json("Query " + err)
    else {
      res.status(200);
      res.json();
    }
  })
}