const express = require('express');
const app = express();
const multer  = require('multer')
const upload = multer({ dest: 'uploads/' })

const userController = require('../controllers/user');

const router = express.Router();

router.get('/my-products/:id', userController.getMyProducts);
// router.post('/product', upload.array('imgUrl', 3), (req, res, next) => { console.log(req.file); next();} ,userController.postNewProduct);
router.post('/product', upload.array('imgUrl', 3), (req, res, next) => { console.log(req.files, req.headers);});
router.delete('/product/:id', userController.deleteProduct);
router.put('/product/:id', userController.updateProduct);
router.put('/change-visibility/:id', userController.changeProductVisibility);

router.post('/wish-list', userController.postWishList);
router.delete('/wish-list/:id', userController.deleteWishList);

router.post('/cart', userController.postCart);
router.get('/cart-products/:id', userController.getCartProducts);
router.delete('/cart/:id', userController.deleteCart);
router.get('/cart/:id', userController.getCart);
router.put('/cart', userController.updateCart);
router.get('/order/:id', userController.getOrder);
router.get('/my-orders/:id', userController.getMyOrders);
router.put('/cart-products', userController.updateCartProduct);
router.delete('/cart-order/:cartId/:userId', userController.deleteCartOrder);

router.post('/review', userController.postReview);
router.get('/review/:review/auth/:log', userController.getReviewLog);
router.post('/review-vote', userController.postReviewVote);
router.delete('/review-vote/:reviewId/:userId', userController.deleteReviewVote);

router.post('/follow', userController.postFollow);
router.delete('/follow/:following/:follower', userController.deleteFollow);

router.get('/user/:user/short/auth/:log', userController.getUserShortLog);
router.get('/user/:user/auth/:log', userController.getUserLog);
router.put('/user', userController.updateUser);
router.get('/contacts/:id', userController.getContacts);

router.get('/address/:id', userController.getAddress);
router.post('/address', userController.postAddress);
router.post('/address-to-cart', userController.postAddressToCart);
router.delete('/address/:id', userController.deleteAddress);
router.put('/address', userController.updateAddress);
router.get('/city-by-code/:id', userController.getCityByPostalCode);

router.get('/notifications/:id', userController.getNotifications);
router.put('/notification', userController.updateNotifSeen);

router.get('/messages/:userId/:contactId', userController.getMessages);
router.post('/message', userController.postMessage);


module.exports = router;