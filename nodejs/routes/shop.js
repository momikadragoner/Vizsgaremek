const express = require('express');
const app = express();

const shopController = require('../controllers/shop');

const router = express.Router();

router.get('/product/:id', shopController.getProductById);

router.get('/review/:id', shopController.getReviewById);

router.get('/list-all-products', shopController.getAllProducts);

router.get('/products-by-seller/:id', shopController.getProductsBySeller);

router.get('/user-short/:id', shopController.getUserShort);

router.get('/user/:id', shopController.getUser);

module.exports = router;