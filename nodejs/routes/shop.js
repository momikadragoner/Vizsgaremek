const express = require('express');
const app = express();

const shopController = require('../controllers/shop');

const router = express.Router();

router.get('/product/:id', shopController.getProduct);

router.get('/review/:id', shopController.getReviewById);

router.get('/list-all-products', shopController.getAllProducts);

router.get('/products-by-seller/:id', shopController.getProductsBySeller);

router.get('/user-short/:id', shopController.getUserShort);

router.get('/user/:id', shopController.getUser);

router.get('/wish-list/:id', shopController.getWishList);

module.exports = router;