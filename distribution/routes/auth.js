const express = require('express');
const app = express();

const authController = require('../controllers/auth');

const router = express.Router();

router.post('/signup',authController.userSignup);

router.post('/login',authController.userLogin);

router.post('/signupasvendor',authController.userSignupAsVendor);



module.exports=router;
