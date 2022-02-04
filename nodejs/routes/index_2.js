const express=require('express');
const router=express.Router();

const user = require('./auth');

router.use('/user',user);

module.exports=router;