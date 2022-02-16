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

router.get('/cart/:id', userController.getCart);

router.delete('/delete-cart/:id', userController.deleteCart);

router.post('/post-review', userController.postReview);

router.post('/post-follow', userController.postFollow);

module.exports = router;