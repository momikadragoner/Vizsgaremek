const express = require('express');
const app = express();

const shopController = require('../controllers/shop');

const router = express.Router();

router.get('/product/:id', shopController.getProduct);

router.get('/review/:id', shopController.getReviewById);

router.get('/products', shopController.getAllProducts);

router.get('/products/seller/:id', shopController.getProductsBySeller);

router.get('/user/:id/short', shopController.getUserShort);

router.get('/user/:id', shopController.getUser);

router.get('/wish-list/:id', shopController.getWishList);

router.get('/search', shopController.searchProducts);

module.exports = router;