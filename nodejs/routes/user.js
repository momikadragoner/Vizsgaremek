const express = require('express');
const app = express();

const userController = require('../controllers/user');

const router = express.Router();

router.get('/my-products/:id', userController.getMyProducts);

router.post('/add-product', userController.postNewProduct);

router.delete('/delete-product/:id', userController.deleteProduct);

router.put('/update-product/:id', userController.updateProduct);

router.put('/change-visibility/:id', userController.changeProductVisibility);

router.post('/post-wish-list', userController.postWishList);

router.delete('/delete-wish-list/:id', userController.deleteWishList);

router.post('/post-cart', userController.postCart);

router.get('/cart-products/:id', userController.getCartProducts);

router.delete('/delete-cart/:id', userController.deleteCart);

router.post('/post-review', userController.postReview);

router.post('/post-follow', userController.postFollow);

router.delete('/delete-follow/:following/:follower', userController.deleteFollow);

router.get('/user-short-log/:user/:log', userController.getUserShortLog);

router.get('/user-log/:user/:log', userController.getUserLog);

router.get('/city-by-code/:id', userController.getCityByPostalCode);

router.get('/address/:id', userController.getAddress);

router.post('/post-address', userController.postAddress);

router.post('/post-address-to-cart', userController.postAddressToCart);

router.get('/cart/:id', userController.getCart);

router.put('/put-cart', userController.updateCart);

router.get('/order/:id', userController.getOrder);

router.put('/update-cart-products', userController.updateCartProduct);

router.put('/update-user', userController.updateUser);

module.exports = router;