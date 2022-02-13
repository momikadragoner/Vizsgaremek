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

router.post('/post-cart', userController.postCart);

router.get('/cart/:id', userController.getCart);

module.exports = router;