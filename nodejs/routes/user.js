const express = require('express');
const app = express();

const userController = require('../controllers/user');

const router = express.Router();

router.get('/my-products/:id', userController.getMyProducts);

module.exports = router;