const express = require('express');
const app = express();

const userController = require('../controllers/user');

const router = express.Router();

router.get('/my-products/:id', userController.getMyProducts);

router.post('/add-product', userController.postNewProduct);

router.delete('/delete-product/:id', userController.deleteProduct);

router.put('/update-product/:id', userController.updateProduct);

router.put('/change-visibility/:id', userController.changeProductVisibility);

module.exports = router;