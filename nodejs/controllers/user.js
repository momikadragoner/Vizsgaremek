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
  deleteFromDatabase('CALL deleteProduct(?)',req, res);
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
  conn.end();
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
  conn.end();
}
exports.getCartProducts = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'This product does not exist.'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectCartProducts(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json(results[0]);
    }
  })
  conn.end();
}
exports.getCart = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'This product does not exist.'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectCart(?)';
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      results[0][0].products = results[1];
      var cart = results[0];
      res.status(200);
      res.json(cart[0]);
    }
  })
  conn.end();
}
exports.postReview = (req, res, next) => {
  let review = req.body;
  let sql = 'CALL insertReview(?, ?, ?, ?, ?, ?)';

  conn = connectDb();
  conn.query(sql, 
    [
      review.userId,
      review.productId,
      review.title,
      review.content,
      new Date(),
      review.rating
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.deleteReview = (req, res, next) => {
  deleteFromDatabase('CALL deleteReview(?)', req, res);
}
exports.deleteCart = (req, res, next) => {
  deleteFromDatabase('CALL deleteCart(?)', req, res);
}
exports.deleteWishList = (req, res, next) => {
  deleteFromDatabase('CALL deleteWishList(?)', req, res)
}
exports.deleteAddress = (req, res, next) => {
  deleteFromDatabase('CALL deleteAddress(?)', req, res)
}
function deleteFromDatabase(sql, req, res) {
  if (!Number(req.params.id)) return res.json({'Error' : 'ID must be a number'});
  let id = Number(req.params.id);
  conn = connectDb();
  conn.query(sql, [id], 
  (err) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json();
    }
  })
  conn.end();
}
exports.postFollow = (req, res, next) => {
  let sql = 'CALL insertFollow(?, ?)';
  conn = connectDb();
  conn.query(sql, 
    [
      req.body.follower,
      req.body.following
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.deleteFollow = (req, res, next) => {
  if (!Number(req.params.follower)) return res.json({'Error' : 'ID must be a number'});
  let follower = Number(req.params.follower);
  if (!Number(req.params.following)) return res.json({'Error' : 'ID must be a number'});
  let following = Number(req.params.following);

  let sql = 'CALL deleteFollow(?, ?)'

  conn = connectDb()
  conn.query(sql,
    [following, follower], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.status(200);
        res.json();
      }
    }
  );
  conn.end();
}
exports.getUserShortLog = (req, res, next) => {
  if (!Number(req.params.user)) return res.json({'Error' : 'ID must be a number'});
  let user = Number(req.params.user);
  if (!Number(req.params.log)) return res.json({'Error' : 'ID must be a number'});
  let log = Number(req.params.log);

  let sql = 'CALL selectUserShort(?, ?)'
  
  conn = connectDb()
  conn.query(sql,
    [user, log], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.status(200);
        res.json(rows[0][0]);
      }
    }
  );
  conn.end();
}

exports.getUserLog = (req, res, next) => {

  if (!Number(req.params.user)) return res.json({'Error' : 'ID must be a number'});
  let user = Number(req.params.user);
  if (!Number(req.params.log)) return res.json({'Error' : 'ID must be a number'});
  let log = Number(req.params.log);

  let sql = 'CALL selectUser(?, ?)';

  conn = connectDb();
  conn.query(sql,
    [user, log], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(rows[0][0]);
      }
    }
  );
  conn.end();
};
exports.getCityByPostalCode = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'ID must be a number'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectCity(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json(results[0][0]);
    }
  })
  conn.end();
}
exports.getAddress = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'ID must be a number'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectAddress(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json(results[0]);
    }
  })
  conn.end();
}
exports.postAddress = (req, res, next) => {
  let sql = 'CALL insertAddress(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  let address = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      address.userId,
      address.addressName,
      address.phone,
      address.userFirstName,
      address.userLastName,
      address.email,
      address.country,
      address.region,
      address.city,
      address.streetAddress,
      address.postalCode
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.postAddressToCart = (req, res, next) => {
  let sql = 'CALL insertAddressToCart(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  let address = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      address.addressId,
      address.userId,
      address.addressName,
      address.phone,
      address.userFirstName,
      address.userLastName,
      address.email,
      address.country,
      address.region,
      address.city,
      address.streetAddress,
      address.postalCode
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.updateCart = (req, res, next) => {
  let sql = 'CALL updateOrderCart(?, ?)';
  let cart = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      cart.cartId,
      cart.status
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.getOrder = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'ID must be a number'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectOrder(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      let orders = results[0];
      let products = results[1];
      let addresses = results[2];
      orders.forEach( order => {
        for (let index = 0; index < products.length; index++) {
          const product = products[index];
          if (order.cartId == product.cartId) {
            if (order.products == undefined) {
              order.products = [];
            }
            order.products.push(product);
          }
        }
        for (let index = 0; index < addresses.length; index++) {
          const address = addresses[index];
          if (address.addressId == order.shippingId) {
            order.address = address;
          }
        }
      })
      res.status(200);
      res.json(orders);
    }
  })
  conn.end();
}
exports.updateCartProduct = (req, res, next) => {
  let sql = 'CALL updateCartProducts(?, ?)';
  let sts = '';
  let array = req.body;
  for (let index = 0; index < array.length; index++) {
    const element = array[index];
    sts += ( "(" + (index + 1) + ",\'" + element.status + "\'," + element.cartProductId );
    if (index == (array.length - 1)) {
      sts += ")";
    }
    else{
      sts += "),";
    }
  }
  conn = connectDb();
  conn.query(sql, 
    [
      sts,
      req.body.length
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.updateUser = (req, res, next) => {
  let sql = 'CALL updateUser(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  let user = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      user.userId,
      user.firstName,
      user.lastName,
      user.phone,
      user.about,
      user.profileImgUrl,
      user.headerImgUrl,
      user.isVendor,
      user.companyName,
      user.siteLocation,
      user.website,
      user.takesCustomOrders
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.updateAddress = (req, res, next) => {
  let sql = 'CALL updateAddress(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  let address = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      address.userId,
      address.addressName,
      address.phone,
      address.userFirstName,
      address.userLastName,
      address.email,
      address.country,
      address.region,
      address.city,
      address.streetAddress,
      address.postalCode,
      address.addressId
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.deleteCartOrder= (req, res, next) => {
  if (!Number(req.params.cartId)) return res.json({'Error' : 'ID must be a number'});
  let cartId = Number(req.params.cartId);
  if (!Number(req.params.userId)) return res.json({'Error' : 'ID must be a number'});
  let userId = Number(req.params.userId);

  let sql = 'CALL deleteCartOrder(?, ?)'

  conn = connectDb()
  conn.query(sql,
    [userId, cartId], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.status(200);
        res.json();
      }
    }
  );
  conn.end();
}
exports.getMyOrders = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'ID must be a number'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectMyOrders(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      let orders = results[0];
      let products = results[1];
      let addresses = results[2];
      orders.forEach( order => {
        for (let index = 0; index < products.length; index++) {
          const product = products[index];
          if (order.cartId == product.cartId) {
            if (order.products == undefined) {
              order.products = [];
            }
            order.products.push(product);
          }
        }
        for (let index = 0; index < addresses.length; index++) {
          const address = addresses[index];
          if (address.addressId == order.shippingId) {
            order.address = address;
          }
        }
      })
      res.status(200);
      res.json(orders);
    }
  })
  conn.end();
}
exports.getReviewLog = (req, res, next) => {

  if (!Number(req.params.review)) return res.json({'Error' : 'ID must be a number'});
  let review = Number(req.params.review);
  if (!Number(req.params.log)) return res.json({'Error' : 'ID must be a number'});
  let log = Number(req.params.log);

  let sql = 'CALL selectReview(?, ?)';

  conn = connectDb();
  conn.query(sql,
    [review, log], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(rows[0][0]);
      }
    }
  );
  conn.end();
};
exports.postReviewVote = (req, res, next) => {
  let sql = 'CALL insertReviewVote(?, ?, ?, ?, ?)';
  let vote = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      vote.productId,
      vote.reviewId,
      vote.userId,
      vote.vote,
      new Date()
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.deleteReviewVote= (req, res, next) => {
  if (!Number(req.params.reviewId)) return res.json({'Error' : 'ID must be a number'});
  let reviewId = Number(req.params.reviewId);
  if (!Number(req.params.userId)) return res.json({'Error' : 'ID must be a number'});
  let userId = Number(req.params.userId);

  let sql = 'CALL deleteReviewVote(?, ?)'

  conn = connectDb()
  conn.query(sql,
    [reviewId, userId], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.status(200);
        res.json();
      }
    }
  );
  conn.end();
}
exports.getNotifications = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'ID must be a number'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectNotifications(?)'
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json(results[0]);
    }
  })
  conn.end();
}
exports.updateNotifSeen = (req, res, next) => {
  conn = connectDb();
  let sql = 'CALL updateNotifSeen(?)'
  conn.query(sql, [req.body.notificationId], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(200);
      res.json(results[0]);
    }
  })
  conn.end();
}
exports.postMessage = (req, res, next) => {
  let sql = 'CALL insertMessage(?, ?, ?, ?)';
  let message = req.body;
  conn = connectDb();
  conn.query(sql, 
    [
      message.senderId,
      message.reciverId,
      message.message,
      new Date()
    ], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      res.status(201);
      res.json();
    }
  })
  conn.end();
}
exports.getMessages = (req, res, next) => {

  if (!Number(req.params.userId)) return res.json({'Error' : 'ID must be a number'});
  let userId = Number(req.params.userId);
  if (!Number(req.params.contactId)) return res.json({'Error' : 'ID must be a number'});
  let contactId = Number(req.params.contactId);

  let sql = 'CALL selectMessages(?, ?)';

  conn = connectDb();
  conn.query(sql,
    [userId, contactId], (err, rows, fields) => {
      if (err) console.log("Query " + err)
      else {
        res.status(200);
        res.json(rows[0]);
      }
    }
  );
  conn.end();
};
exports.getContacts = (req, res, next) => {
  if (!Number(req.params.id)) return res.json({'Error' : 'This product does not exist.'});
  let id = Number(req.params.id);
  conn = connectDb();
  let sql = 'CALL selectContacts(?)';
  conn.query(sql, [id], 
  (err, results, fields) => {
    if (err) console.log("Query " + err)
    else {
      results[0][0].products = results[1];
      var cart = results[0];
      res.status(200);
      res.json(cart[0]);
    }
  })
  conn.end();
}