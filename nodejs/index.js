const express = require('express');
var mysql = require('mysql');

const app = express(),
  bodyParser = require("body-parser");

const products = [{
  id: 1,
  name: "Csodálatos arany nyaklánc medál",
  seller: "Kiss Márta",
  price: 12599,
  discountAvailable: false,
  inventory: 12,
  delivery: "Azonnal szállítható",
  category: "Ékszer",
  tags: ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"],
  materials: ["arany", "ásvány"],
  imgUrl: ["assets/item2.jpg", "assets/item1.jpg", "assets/item4.jpg"],
  description: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Tempore, quo voluptates nemo dolores at modi ipsam fuga odio architecto beatae aliquid molestiae enim qui obcaecati doloribus. Ex saepe voluptatem magnam!",
  isPublic: true,
  rating: 4.7
},
{
  id: 2,
  name: "Arany lánc",
  seller: "Nagy Erzsébet",
  price: 18599,
  discountAvailable: false,
  inventory: 10,
  delivery: "Azonnal szállítható",
  category: "Ékszer",
  tags: ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"],
  materials: ["arany", "ásvány"],
  imgUrl: ["assets/item1.jpg", "assets/item2.jpg", "assets/item4.jpg"],
  description: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Tempore, quo voluptates nemo dolores at modi ipsam fuga odio architecto beatae aliquid molestiae enim qui obcaecati doloribus. Ex saepe voluptatem magnam!",
  isPublic: true,
  rating: 4.7
}];

const reviews = [
  { id: 0, username: "Anitaaa74", title: "Nagyszerű!!!", review: "Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!", rating: 5, points: 6, publishedAt: new Date(2021, 10, 28) },
  { id: 1, username: "kmarika1234", title: "Csinos nyaklánc a kollekciómba", review: "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", rating: 4, points: 3, publishedAt: new Date(2021, 11, 6) },
  { id: 2, username: "ralau42", title: "Szép darab", review: "Egyszerűen imádom lorem ipsum dolor sit amet", rating: 4, points: 2, publishedAt: new Date(2021, 11, 1) },
]

const productList = [
  { id: 1, name: "Gyöngy nyakék", seller: "Kiss Márta", price: 12599, discountAvailable: false, imgUrl: "assets/item2.jpg" },
  { id: 2, name: "Arany lánc", seller: "Nagy Erzsébet", price: 18599, discountAvailable: false, imgUrl: "assets/item1.jpg" },
  { id: 3, name: "Ásvány medál ékszer", seller: "Széles Lajos", price: 11999, discountAvailable: false, imgUrl: "assets/item3.jfif" },
  { id: 4, name: "Arany és kristály nyaklánc", seller: "Közepes Borbála", price: 19599, discountAvailable: false, imgUrl: "assets/item4.jpg" }
];

const productListLong = [
  { id: 1, name: "Gyöngy nyakék", seller: "Kiss Márta", price: 12599, discountAvailable: false, imgUrl: "assets/item2.jpg" },
  { id: 2, name: "Arany lánc", seller: "Nagy Erzsébet", price: 18599, discountAvailable: false, imgUrl: "assets/item1.jpg" },
  { id: 3, name: "Ásvány medál ékszer", seller: "Széles Lajos", price: 11999, discountAvailable: false, imgUrl: "assets/item3.jfif" },
  { id: 4, name: "Arany és kristály nyaklánc", seller: "Közepes Borbála", price: 19599, discountAvailable: false, imgUrl: "assets/item4.jpg" },
  { id: 5, name: "Őszibarack befőtt", seller: "Kiss Márta", price: 2599, discountAvailable: false, imgUrl: "assets/item5.jfif" },
  { id: 6, name: "Egres befőtt", seller: "Szekszárdi Katalin", price: 2799, discountAvailable: false, imgUrl: "assets/item6.JPG" },
  { id: 7, name: "Diós és lekváros leveles kiflik", seller: "Szekszárdi Katalin", price: 1999, discountAvailable: false, imgUrl: "assets/item7.jpg" },
  { id: 8, name: "Túrós-fahéjas hajtogatós", seller: "Szekszárdi Katalin", price: 1999, discountAvailable: false, imgUrl: "assets/item8.jpg" },
];

const user = {
  id: 1,
  name: "Nagy Erzsébet",
  follows: 16,
  followers: 54,
  email: "erzsi.nagy@mail.hu",
  phone: "301234567",
  about: "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎",
  profileImgUrl: "assets/profilepic.jpg",
  headerImgUrl: "assets/header2.jpg",
  registeredAt: new Date(2021, 11, 2),
  isVendor: true,
  isAdmin: false,
  companyName: undefined,
  siteLocation: "Nagybajcs",
  website: "erzsiekszer.hu",
  takesCustomOrders: true
}

app.use(bodyParser.json());

function connectDb() {
  var connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'agora-webshop'
  })

  connection.connect()
  return connection;
}

app.get('/api/users-db', (req, res, next) => {
  conn = connectDb()
  conn.query('SELECT * FROM member', function (err, rows, fields) {
    if (err) throw err

    res.json(rows);
    console.log('Users: ', rows[0])
  })
  conn.end()
})

app.get('/api/product/:id', (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);
  let materials = [];
  let tags = [];
  let imgUrl = [];
  let reviews = [];

  conn.query('SELECT material_name FROM material INNER JOIN product_material ON material.material_id = product_material.material_id WHERE product_material.product_id = ?',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        rows.forEach((rows) => { materials.push(rows.material_name) });
      }
    }
  );
  conn.query('SELECT tag_name FROM tag INNER JOIN product_tag ON tag.tag_id = product_tag.tag_id WHERE product_tag.product_id = ?',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        rows.forEach((rows) => { tags.push(rows.tag_name) });
      }
    }
  );
  conn.query('SELECT product_picture.resource_link FROM product_picture WHERE product_picture.product_id = ?',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        rows.forEach((rows) => { imgUrl.push(rows.resource_link) });
      }
    }
  );
  conn.query('SELECT review.review_id AS reviewId, review.member_id AS userId, review.rating, review.title, review.content, review.published_at AS publishedAt, member.first_name AS userFirstName, member.last_name AS userLastName FROM review INNER JOIN member ON member.member_id = review.member_id WHERE review.product_id = ?;',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        rows.forEach((rows) => { reviews.push(rows) });
      }
    }
  );
  conn.query('SELECT product.product_id AS productId, product.name, product.price, product.description, product.inventory, product.delivery, product.category, product.rating, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublished, product.created_at AS createdAt, product.last_updated_at AS lastUpdatedAt, product.published_at AS publishedAt, member.first_name AS sellerFirstName, member.last_name AS sellerLastName FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product_id = ?',
    [id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
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

})

app.get('/api/product-old/:id', (req, res, next) => {
  if (products[Number(req.params.id) - 1]) {
    res.json(products[Number(req.params.id) - 1]);
  }
  //res.json(req.params.id);
});

app.get('/api/review/:id', (req, res, next) => {

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
});

app.get('/api/list-all-products', (req, res, next) => {
  conn = connectDb()

  conn.query('SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product.is_published = TRUE AND product.inventory > 0;',
    (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows);
      }
    }
  );
});

app.get('/api/recommended-products/:user/:product', (req, res, next) => {
  res.json(productListLong);
});

app.get('/api/products-by-seller/:id', (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);
  let sorter = req.query.orderby;
  console.log(sorter);
  var sql = 'SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product.is_published = TRUE AND product.vendor_id = ?';
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
});

app.get('/api/user-short/:id', (req, res, next) => {

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
});

app.get('/api/user/:id', (req, res, next) => {

  conn = connectDb()

  if (!Number(req.params.id)) return res.json('Error: This URL does not lead to any products.');

  let id = Number(req.params.id);

  conn.query('SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, member.header_picture_link AS headerImgUrl, member.registered_at AS registeredAt, v.company_name AS companyName, v.site_location AS siteLocation, v.website, v.takes_custom_orders AS takesCustomOrders, (SELECT COUNT(follower_relations.following_id = ?) FROM follower_relations) AS followers, (SELECT COUNT(follower_relations.follower_id = ?) FROM follower_relations ) AS following FROM member INNER JOIN vendor_detail AS v ON v.member_id = member.member_id WHERE member.member_id = ?',
    [id, id, id], (err, rows, fields) => {
      if (err) res.json("Query error: " + err)
      else {
        res.json(rows[0]);
      }
    }
  );
});

app.post('/api/user', (req, res) => {
  const user = req.body.user;
  users.push(user);
  res.json("user addedd");
});

app.get('/', (req, res) => {
  res.send('App Works !!!!');
});

// app.get('/', (req,res) => {
//     res.sendFile(process.cwd()+"/my-app/dist/angular-nodejs-example/index.html")
// });

app.listen(3080);