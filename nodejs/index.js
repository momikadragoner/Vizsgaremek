const express = require('express');

const app = express(),
      bodyParser = require("body-parser");

const product = {
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
};

const reviews = [
  { id: 0, username: "Anitaaa74", title: "Nagyszerű!!!", review: "Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!", rating: 5, points: 6, publishedAt: new Date(2021, 10, 28) },
  { id: 1, username: "kmarika1234", title: "Csinos nyaklánc a kollekciómba", review: "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", rating: 4, points: 3, publishedAt: new Date(2021, 11, 6) },
  { id: 2, username: "ralau42", title: "Szép darab", review: "Egyszerűen imádom lorem ipsum dolor sit amet", rating: 4, points: 2, publishedAt: new Date(2021, 11, 1) },
]

const productList = [
  { id: 1, name: "Gyöngy nyakék", seller: "Kiss Márta", price: 12599, discountAvailable: false, imgUrl: "assets/item2.jpg"},
  { id: 2, name: "Arany lánc", seller: "Nagy Erzsébet", price: 18599, discountAvailable: false, imgUrl: "assets/item1.jpg"},
  { id: 3, name: "Ásvány medál ékszer", seller: "Széles Lajos", price: 11999, discountAvailable: false, imgUrl: "assets/item3.jfif"},
  { id: 4, name: "Arany és kristály nyaklánc", seller: "Közepes Borbála", price: 19599, discountAvailable: false, imgUrl: "assets/item4.jpg"}
];

const productListLong = [
  { id: 1, name: "Gyöngy nyakék", seller: "Kiss Márta", price: 12599, discountAvailable: false, imgUrl: "assets/item2.jpg"},
  { id: 2, name: "Arany lánc", seller: "Nagy Erzsébet", price: 18599, discountAvailable: false, imgUrl: "assets/item1.jpg"},
  { id: 3, name: "Ásvány medál ékszer", seller: "Széles Lajos", price: 11999, discountAvailable: false, imgUrl: "assets/item3.jfif"},
  { id: 4, name: "Arany és kristály nyaklánc", seller: "Közepes Borbála", price: 19599, discountAvailable: false, imgUrl: "assets/item4.jpg"},
  { id: 5, name: "Őszibarack befőtt", seller: "Kiss Márta", price: 2599, discountAvailable: false, imgUrl: "assets/item5.jfif"},
  { id: 6, name: "Egres befőtt", seller: "Szekszárdi Katalin", price: 2799, discountAvailable: false, imgUrl: "assets/item6.JPG"},
  { id: 7, name: "Diós és lekváros leveles kiflik", seller: "Szekszárdi Katalin", price: 1999, discountAvailable: false, imgUrl: "assets/item7.jpg"},
  { id: 8, name: "Túrós-fahéjas hajtogatós", seller: "Szekszárdi Katalin", price: 1999, discountAvailable: false, imgUrl: "assets/item8.jpg"},
];

app.use(bodyParser.json());

app.get('/api/product', (req, res, next) => {
  res.json(product);
});

app.get('/api/reviews', (req, res, next) => {
  res.json(reviews);
});

app.get('/api/product-list', (req, res, next) => {
  res.json(productList);
});

app.get('/api/product-list-long', (req, res, next) => {
  res.json(productListLong);
});

app.post('/api/user', (req, res) => {
  const user = req.body.user;
  users.push(user);
  res.json("user addedd");
});

app.get('/', (req,res) => {
    res.send('App Works !!!!');
});

// app.get('/', (req,res) => {
//     res.sendFile(process.cwd()+"/my-app/dist/angular-nodejs-example/index.html")
// });

app.listen(3080);