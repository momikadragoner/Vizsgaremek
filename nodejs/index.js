// const products = [{
//   id: 1,
//   name: "Csodálatos arany nyaklánc medál",
//   seller: "Kiss Márta",
//   price: 12599,
//   discountAvailable: false,
//   inventory: 12,
//   delivery: "Azonnal szállítható",
//   category: "Ékszer",
//   tags: ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"],
//   materials: ["arany", "ásvány"],
//   imgUrl: ["assets/item2.jpg", "assets/item1.jpg", "assets/item4.jpg"],
//   description: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Tempore, quo voluptates nemo dolores at modi ipsam fuga odio architecto beatae aliquid molestiae enim qui obcaecati doloribus. Ex saepe voluptatem magnam!",
//   isPublic: true,
//   rating: 4.7
// },
// {
//   id: 2,
//   name: "Arany lánc",
//   seller: "Nagy Erzsébet",
//   price: 18599,
//   discountAvailable: false,
//   inventory: 10,
//   delivery: "Azonnal szállítható",
//   category: "Ékszer",
//   tags: ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"],
//   materials: ["arany", "ásvány"],
//   imgUrl: ["assets/item1.jpg", "assets/item2.jpg", "assets/item4.jpg"],
//   description: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Tempore, quo voluptates nemo dolores at modi ipsam fuga odio architecto beatae aliquid molestiae enim qui obcaecati doloribus. Ex saepe voluptatem magnam!",
//   isPublic: true,
//   rating: 4.7
// }];

// const reviews = [
//   { id: 0, username: "Anitaaa74", title: "Nagyszerű!!!", review: "Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!", rating: 5, points: 6, publishedAt: new Date(2021, 10, 28) },
//   { id: 1, username: "kmarika1234", title: "Csinos nyaklánc a kollekciómba", review: "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", rating: 4, points: 3, publishedAt: new Date(2021, 11, 6) },
//   { id: 2, username: "ralau42", title: "Szép darab", review: "Egyszerűen imádom lorem ipsum dolor sit amet", rating: 4, points: 2, publishedAt: new Date(2021, 11, 1) },
// ]

// const productList = [
//   { id: 1, name: "Gyöngy nyakék", seller: "Kiss Márta", price: 12599, discountAvailable: false, imgUrl: "assets/item2.jpg" },
//   { id: 2, name: "Arany lánc", seller: "Nagy Erzsébet", price: 18599, discountAvailable: false, imgUrl: "assets/item1.jpg" },
//   { id: 3, name: "Ásvány medál ékszer", seller: "Széles Lajos", price: 11999, discountAvailable: false, imgUrl: "assets/item3.jfif" },
//   { id: 4, name: "Arany és kristály nyaklánc", seller: "Közepes Borbála", price: 19599, discountAvailable: false, imgUrl: "assets/item4.jpg" }
// ];

// const productListLong = [
//   { id: 1, name: "Gyöngy nyakék", seller: "Kiss Márta", price: 12599, discountAvailable: false, imgUrl: "assets/item2.jpg" },
//   { id: 2, name: "Arany lánc", seller: "Nagy Erzsébet", price: 18599, discountAvailable: false, imgUrl: "assets/item1.jpg" },
//   { id: 3, name: "Ásvány medál ékszer", seller: "Széles Lajos", price: 11999, discountAvailable: false, imgUrl: "assets/item3.jfif" },
//   { id: 4, name: "Arany és kristály nyaklánc", seller: "Közepes Borbála", price: 19599, discountAvailable: false, imgUrl: "assets/item4.jpg" },
//   { id: 5, name: "Őszibarack befőtt", seller: "Kiss Márta", price: 2599, discountAvailable: false, imgUrl: "assets/item5.jfif" },
//   { id: 6, name: "Egres befőtt", seller: "Szekszárdi Katalin", price: 2799, discountAvailable: false, imgUrl: "assets/item6.JPG" },
//   { id: 7, name: "Diós és lekváros leveles kiflik", seller: "Szekszárdi Katalin", price: 1999, discountAvailable: false, imgUrl: "assets/item7.jpg" },
//   { id: 8, name: "Túrós-fahéjas hajtogatós", seller: "Szekszárdi Katalin", price: 1999, discountAvailable: false, imgUrl: "assets/item8.jpg" },
// ];

// const user = {
//   id: 1,
//   name: "Nagy Erzsébet",
//   follows: 16,
//   followers: 54,
//   email: "erzsi.nagy@mail.hu",
//   phone: "301234567",
//   about: "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎",
//   profileImgUrl: "assets/profilepic.jpg",
//   headerImgUrl: "assets/header2.jpg",
//   registeredAt: new Date(2021, 11, 2),
//   isVendor: true,
//   isAdmin: false,
//   companyName: undefined,
//   siteLocation: "Nagybajcs",
//   website: "erzsiekszer.hu",
//   takesCustomOrders: true
// }

// app.get('/', (req,res) => {
//     res.sendFile(process.cwd()+"/my-app/dist/angular-nodejs-example/index.html")
// });

const express = require('express');
const app = express();

app.use(express.urlencoded({ extended: false }));

app.use(express.json())

const shopRoutes = require('./routes/shop');
const userRoutes = require('./routes/user');

app.get('/', (req, res) => {
  res.send('API Works!');
});

app.use('/api', shopRoutes);
app.use('/api', userRoutes);

app.listen(3080);