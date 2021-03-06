-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 28, 2022 at 08:40 PM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agora-webshop`
--
CREATE DATABASE IF NOT EXISTS `agora-webshop` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci;
USE `agora-webshop`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `beginSession` (IN `mail` VARCHAR(320), IN `token` VARCHAR(1000))  NO SQL BEGIN

	SET @userId = (SELECT member.member_id FROM member WHERE member.email = mail);

    CALL endSession(@userId);

	INSERT INTO `session` (member_id, jwt, logged_in_at) VALUES (@userId, token, NOW());

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `changeProductVisibility` (IN `isPub` TINYINT, IN `lstUp` DATETIME, IN `prodId` INT)  NO SQL BEGIN

	UPDATE `product` SET `is_published`=isPub, `last_updated_at`=lstUp WHERE product_id = prodId;

    IF isPub THEN

    	CALL insertProductNotifs((SELECT product.vendor_id FROM product WHERE product.product_id = prodId), prodId);

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteAddress` (IN `addressId` INT)  NO SQL BEGIN

	DELETE FROM `shipping_address` WHERE shipping_address_id = addressId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteCart` (IN `cartProdId` INT)   BEGIN

	SET @prodId = (SELECT cart_product.product_id FROM cart_product WHERE cart_product.cart_product_id = cartProdId);

	SET @prodPrice = (SELECT product.price FROM product WHERE product.product_id = @prodId);

    IF ((SELECT product.discount FROM product WHERE product.product_id = @prodId) IS NOT NULL) THEN

    	SET @prodPrice = (@prodPrice * (1-((SELECT product.discount FROM product WHERE product.product_id = @prodId)/100)));

    END IF;

	UPDATE cart SET cart.sum_price = (cart.sum_price - @prodPrice) WHERE cart.cart_id = (SELECT cart.cart_id FROM cart INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id WHERE cart_product.cart_product_id = cartProdId);

	DELETE FROM `cart_product` WHERE cart_product_id = cartProdId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteCartOrder` (IN `userId` INT, IN `cartId` INT)  NO SQL BEGIN

	DELETE FROM cart_product

WHERE cart_product_id IN (SELECT cart_product.cart_product_id FROM cart_product 

INNER JOIN product on cart_product.product_id = product.product_id

WHERE product.vendor_id = userId AND cart_product.cart_id = cartId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteFollow` (IN `followerId` INT, IN `followingId` INT)  NO SQL BEGIN

	DELETE FROM follower_relations WHERE follower_relations.follower_id = followerId AND follower_relations.following_id = followingId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProduct` (IN `prodId` INT)  NO SQL BEGIN

	DELETE FROM `product_material` WHERE product_id = prodId;

    DELETE FROM `product_picture` WHERE product_id = prodId;

    DELETE FROM `product_tag` WHERE product_id = prodId;

    UPDATE `product` SET `name`="Eltávolított termék",`price`=NULL,`description`=NULL,`inventory`=NULL,`delivery`=NULL,`category`=NULL,`rating`=NULL,`vendor_id`=NULL,`discount`=NULL,`is_published`=FALSE,`is_removed`=TRUE,`created_at`=NULL,`last_updated_at`=NULL,`published_at`=NULL WHERE `product_id` = prodId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteReview` (IN `revId` INT)  NO SQL BEGIN

	DELETE FROM `review` WHERE review_id = revId;
    CALL selectReview(revId,0);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteReviewVote` (IN `reviewId` INT, IN `userId` INT)   BEGIN
	SELECT review_vote.review_vote_id FROM review_vote WHERE review_vote.review_id = reviewId AND review_vote.member_id = userId;
	DELETE FROM `review_vote` WHERE review_vote.review_id = reviewId AND review_vote.member_id = userId;

    UPDATE review SET review.points = ((SELECT COUNT(*) FROM review_vote WHERE review_vote.review_id = reviewId AND review_vote.vote = 'up')-(SELECT COUNT(*) FROM review_vote WHERE review_vote.review_id = reviewId AND review_vote.vote = 'down')) WHERE review.review_id = reviewId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteWishList` (IN `wishId` INT)  NO SQL BEGIN

	DELETE FROM `wish_list` WHERE wish_list.wish_list_id = wishId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `endSession` (IN `userId` INT)  NO SQL BEGIN

	DELETE FROM `session` WHERE `session`.`member_id` = userId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertAddress` (IN `userId` INT, IN `nm` VARCHAR(50), IN `phn` VARCHAR(50), IN `frstNm` VARCHAR(50), IN `lstNm` VARCHAR(50), IN `mail` VARCHAR(100), IN `cntry` VARCHAR(50), IN `rgn` VARCHAR(50), IN `cty` VARCHAR(50), IN `strtAd` VARCHAR(50), IN `postCode` VARCHAR(50))  NO SQL BEGIN

	IF nm = '' THEN

    	SET @count = (SELECT COUNT(*) FROM shipping_address WHERE shipping_address.member_id = userId) + 1;

    	SET nm = CONCAT(@count, '. szállítási cím');

    END IF;

	INSERT INTO `shipping_address`(`member_id`, `name`, `phone`, `first_name`, `last_name`, `email`, `country`, `region`, `city`, `street_adress`, `postal_code`) VALUES (userId, nm, phn, frstNm, lstNm, mail, cntry, rgn, cty, strtAd, postCode);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertAddressToCart` (IN `addId` INT, IN `userId` INT, IN `nm` VARCHAR(50), IN `phn` VARCHAR(50), IN `frstNm` VARCHAR(50), IN `lstNm` VARCHAR(50), IN `mail` VARCHAR(100), IN `cntry` VARCHAR(50), IN `rgn` VARCHAR(50), IN `cty` VARCHAR(50), IN `strtAd` VARCHAR(50), IN `postCode` VARCHAR(50))  NO SQL BEGIN

	IF addId = 0 THEN

    	CALL insertAddress(userId, nm, phn, frstNm, lstNm, mail, cntry, rgn, cty, strtAd, postCode);

    UPDATE `cart` SET `shipping_address_id`=(SELECT last_insert_id()) WHERE cart.member_id = userId AND cart.status = 'Not Sent';

    ELSE

    	UPDATE `cart` SET `shipping_address_id`= addId WHERE cart.member_id = userId AND cart.status = 'Not Sent';

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertCart` (IN `userId` INT, IN `prodId` INT)  NO SQL BEGIN

	IF (FALSE = (SELECT EXISTS( SELECT * FROM cart WHERE cart.member_id = userId AND cart.status = 'Not Sent'))) THEN

    	INSERT INTO cart(member_id, sum_price, shipping_address_id, status) VALUES (userId, 0, NULL, 'Not Sent');

    END IF;

    SET @currCartId = ( SELECT cart_id FROM cart WHERE cart.member_id = userId AND cart.status = 'Not Sent');

    IF (SELECT EXISTS ( SELECT * FROM cart_product WHERE cart_id = @currCartId AND product_id = prodId )) THEN

    	SET @prevAmount = (SELECT amount FROM cart_product WHERE cart_id = @currCartId AND product_id = prodId);

    	UPDATE cart_product SET amount = (@prevAmount + 1) WHERE cart_id = @currCartId AND product_id = prodId;

    ELSE

    	INSERT INTO cart_product(cart_id, product_id, amount, cart_product.status) VALUES (@currCartId, prodId, 1, "In Cart");

    END IF;

    SET @prodPrice = (SELECT product.price FROM product WHERE product.product_id = prodId);

    IF ((SELECT product.discount FROM product WHERE product.product_id = prodId) IS NOT NULL) THEN

    	SET @prodPrice = (@prodPrice * (1-((SELECT product.discount FROM product WHERE product.product_id = prodId)/100)));

    END IF;

    UPDATE cart SET cart.sum_price = cart.sum_price + @prodPrice WHERE cart.cart_id = @currCartId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertFollow` (IN `flwerId` INT, IN `flwingId` INT)  NO SQL BEGIN

	INSERT INTO `follower_relations`(`follower_id`, `following_id`) VALUES (flwerId, flwingId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertMaterials` (IN `mats` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL BEGIN

	DECLARE x INT DEFAULT 1;

	CREATE TEMPORARY TABLE materials(i INT, name VARCHAR(50));

    SET @sql = CONCAT('INSERT INTO materials(i, name) VALUES ', mats);

  	PREPARE stmt FROM @sql;

  	EXECUTE stmt;

  	DEALLOCATE PREPARE stmt;

    WHILE (x < (length + 1)) DO

        SET @currMatName = (SELECT name FROM materials WHERE materials.i = x);

        IF (SELECT EXISTS (SELECT * from material WHERE material.material_name = @currMatName)) THEN

    		INSERT INTO product_material(material_id, product_id) VALUES( (SELECT material_id FROM material WHERE material_name = @currMatName), prodId);

        ELSE

        	INSERT INTO material(material_name) VALUES(@currMatName);

            INSERT INTO product_material(material_id, product_id) VALUES( (SELECT material_id FROM material WHERE material_name = @currMatName), prodId);

    	END IF;

        SET x = x + 1;

    END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertMessage` (IN `senderId` INT, IN `reciverId` INT, IN `msg` VARCHAR(255), IN `sentAt` INT)   BEGIN

	INSERT INTO `message`(`sender_id`, `reciver_id`, `message`, `sent_at`) VALUES (senderId, reciverId, msg, sentAt);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertNotification` (IN `senderId` INT, IN `reciverId` INT, IN `typ` VARCHAR(50), IN `itemId` INT)   BEGIN

	SET @lnk = '';

    SET @cont = '';

	IF typ = 'product' THEN

    	SET @lnk = CONCAT('/product-details/', itemId);

        SET @cont = 'új terméket tett közzé.';

    ELSEIF typ = 'order-tracking' THEN

    	SET @lnk = '/order-tracking';

        SET @cont = 'frissítette egy rendelésed állapotát.';

    ELSEIF typ = 'order-arrived' THEN

    	SET @lnk = '/order-management';

        SET @cont = 'megkapott egy tőled rendelt terméket.';

    END IF;

	INSERT INTO `notification`(`sender_id`, `reciver_id`, `content`, `type`, `item_id`, `link`, `seen`, `sent_at`) VALUES (senderId, reciverId, @cont, typ, itemId, @lnk, FALSE, NOW());

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertPictures` (IN `pics` VARCHAR(65535), IN `length` INT, IN `prodId` INT, IN `thId` INT)  NO SQL BEGIN

	DECLARE x INT DEFAULT 1;

	CREATE TEMPORARY TABLE pictures(i INT, url VARCHAR(100));

    SET @sql = CONCAT('INSERT INTO pictures(i, url) VALUES ', pics);

  	PREPARE stmt FROM @sql;

  	EXECUTE stmt;

  	DEALLOCATE PREPARE stmt;

    WHILE (x < (length + 1)) DO

    	IF x = thId THEN

        	SET @isTh = TRUE;

        ELSE

        	SET @isTh = FALSE;

        END IF;

        INSERT INTO `product_picture`(`product_id`, `resource_link`, `is_thumbnail`) VALUES (prodId, (SELECT url FROM pictures WHERE i = x), @isTh);

        SET x = x + 1;

    END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertProduct` (IN `nm` VARCHAR(50), IN `prc` INT, IN `dsc` TEXT, IN `inv` INT, IN `del` VARCHAR(50), IN `cat` VARCHAR(50), IN `venId` INT, IN `disc` INT, IN `isPub` TINYINT, IN `crAt` DATETIME, IN `pbAt` DATETIME, IN `tags` VARCHAR(255), IN `tagsL` INT, IN `mats` VARCHAR(255), IN `matsL` INT, IN `pics` VARCHAR(65535), IN `picsL` INT, IN `thumId` INT)  NO SQL BEGIN

INSERT INTO `product`(`name`, `price`, `description`, `inventory`, `delivery`, `category`, `vendor_id`, `discount`, `is_published`, `created_at`, `published_at`) VALUES (nm, prc, dsc, inv, del, cat, venId, disc, isPub, crAt, pbAt);

SET @productId = (SELECT LAST_INSERT_ID());

IF matsL > 0 THEN
	CALL insertMaterials(mats, matsL, @productId);
END IF;

IF tagsL > 0 THEN
	CALL insertTags(tags, tagsL, @productId);
END IF;

CALL insertPictures(pics, picsL, @productId, thumId);

IF isPub THEN 

	CALL insertProductNotifs(venId, @productId);

END IF;

CALL selectProduct(@productId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertProductNotifs` (IN `userId` INT, IN `prodId` INT)   BEGIN

DECLARE n INT DEFAULT 0;

DECLARE i INT DEFAULT 0;

SELECT COUNT(*) FROM follower_relations WHERE follower_relations.following_id = userId INTO n;    

WHILE i<n DO 

   CALL insertNotification( userId, (SELECT follower_relations.follower_id FROM follower_relations WHERE follower_relations.following_id = userId LIMIT i,1), 'product', prodId);

  SET i = i + 1;

END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertReview` (IN `userId` INT, IN `prodId` INT, IN `titl` VARCHAR(50), IN `cont` TEXT, IN `pubAt` DATETIME, IN `rat` INT)   BEGIN

	INSERT INTO `review`(`product_id`, `member_id`, `rating`, `points`, `title`, `content`, `published_at`) VALUES (prodId, userId, rat, 0, titl, cont, pubAt);
	SET @reviewId = (SELECT LAST_INSERT_ID());
    UPDATE product SET product.rating = (SELECT AVG(review.rating) FROM review WHERE product_id = prodId) WHERE product_id = prodId;
    
    CALL selectReview(@reviewId,0);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertReviewVote` (IN `prodId` INT, IN `reviewId` INT, IN `userId` INT, IN `vt` VARCHAR(10), IN `vtAt` DATETIME)   BEGIN

	IF (EXISTS(SELECT * FROM review_vote WHERE review_vote.review_id = reviewId AND review_vote.member_id = userId)) THEN

    	CALL deleteReviewVote(reviewId, userId);

    END IF;

    INSERT INTO `review_vote`(`product_id`, `review_id`, `member_id`, `vote`, `voted_at`) VALUES (prodId, reviewId, userId, vt, vtAt);
	SELECT LAST_INSERT_ID() AS vote;
    UPDATE review SET review.points = ((SELECT COUNT(*) FROM review_vote WHERE review_vote.review_id = reviewId AND review_vote.vote = 'up')-(SELECT COUNT(*) FROM review_vote WHERE review_vote.review_id = reviewId AND review_vote.vote = 'down')) WHERE review.review_id = reviewId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertTags` (IN `tgs` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL BEGIN

	DECLARE x INT DEFAULT 1;

	CREATE TEMPORARY TABLE tags(i INT, name VARCHAR(50));

    SET @sql = CONCAT('INSERT INTO tags(i, name) VALUES ', tgs);

  	PREPARE stmt FROM @sql;

  	EXECUTE stmt;

  	DEALLOCATE PREPARE stmt;

    WHILE (x < (length + 1)) DO

        SET @currTagName = (SELECT name FROM tags WHERE i = x);

        IF (SELECT EXISTS (SELECT * from tag WHERE tag.tag_name = @currTagName)) THEN

    		INSERT INTO product_tag(tag_id, product_id) VALUES( (SELECT tag_id FROM tag WHERE tag_name = @currTagName), prodId);

        ELSE

        	INSERT INTO tag(tag_name) VALUES(@currTagName);

            INSERT INTO product_tag(tag_id, product_id) VALUES( (SELECT tag_id FROM tag WHERE tag_name = @currTagName), prodId);

    	END IF;

        SET x = x + 1;

    END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertVendor` (IN `lastName` VARCHAR(50), IN `firstName` VARCHAR(50), IN `userEmail` VARCHAR(100), IN `userPassword` VARCHAR(50), IN `profilePicture` VARCHAR(50), IN `headerPicture` VARCHAR(50), IN `registered` DATE, IN `isVendor` TINYINT)   BEGIN
	
	insert into member (last_name, first_name, email, password, profile_picture_link, header_picture_link, registered_at, is_vendor) values(lastName,firstName,userEmail,userPassword,profilePicture,headerPicture,registered,isVendor);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertWishList` (IN `prodId` INT, IN `userId` INT, IN `addAt` DATETIME)  NO SQL BEGIN

	IF (SELECT EXISTS ( SELECT * FROM wish_list WHERE product_id = prodId AND member_id = userId)) THEN

    	UPDATE wish_list SET added_at = NOW() WHERE product_id = prodId AND member_id = userId;

    ELSE

		INSERT INTO wish_list(product_id, member_id, added_at) VALUES(prodId,userId,addAt);

    END IF;

    SELECT wish_list.wish_list_id FROM wish_list WHERE wish_list.product_id = prodId AND wish_list.member_id = userId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectAddress` (IN `userId` INT)   BEGIN

	SELECT shipping_address_id AS addressId, shipping_address.member_id as userId, member.first_name AS userFirstName, member.last_name AS userLastName, shipping_address.phone, shipping_address.email, shipping_address.name AS addressName, shipping_address.country, shipping_address.postal_code AS postalCode, shipping_address.region, shipping_address.city, shipping_address.street_adress AS streetAddress 

FROM `shipping_address` 

INNER JOIN member ON shipping_address.member_id = member.member_id

WHERE shipping_address.member_id = userId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCart` (IN `userId` INT)   BEGIN

	SELECT `cart_id` AS cartId, `member_id` AS userId, `shipping_address_id` AS shippingId, `sum_price` AS sumPrice, `status` FROM `cart` WHERE cart.member_id = userId AND cart.status = 'Not Sent';

    CALL selectCartProducts(userId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCartProducts` (IN `userId` INT)  NO SQL BEGIN

	SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl, cart_product.amount, cart_product.status, cart_product.cart_product_id AS cartProductId

FROM cart

INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id

INNER JOIN product ON product.product_id = cart_product.product_id

INNER JOIN member ON member.member_id = product.vendor_id

WHERE cart.member_id = userId AND cart.status = 'Not Sent';

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCity` (IN `postalCode` INT)  NO SQL BEGIN

	SELECT city_name AS city, region_name AS region FROM city 

INNER JOIN region ON region.region_id = city.region_id

WHERE city.postal_code = postalCode;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectContacts` (IN `userId` INT)   BEGIN

	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, vendor_detail.takes_custom_orders AS takesCustomOrders FROM member INNER JOIN vendor_detail ON vendor_detail.member_id = member.member_id WHERE member.member_id IN (SELECT message.sender_id

FROM message 

WHERE message.reciver_id = userId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectMessages` (IN `userId` INT, IN `contactId` INT)   BEGIN

	SELECT message.message_id AS messageId, message.sender_id AS senderId, reciver_id AS reciverId, message.message, message.sent_at AS sentAt, (SELECT member.first_name FROM member WHERE member.member_id = contactId) AS contactFirstName, (SELECT member.last_name FROM member WHERE member.member_id = contactId) AS contactLastName, message.sent_at AS sentAt, (SELECT message.reciver_id = userId) AS recived

FROM message 

WHERE message.reciver_id = userId OR message.sender_id = userId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectMyOrders` (IN `userId` INT)  NO SQL BEGIN

	SELECT DISTINCT cart.cart_id AS cartId, cart.member_id AS userId, cart.shipping_address_id AS shippingId, cart.sum_price AS sumPrice, cart.status

    FROM `cart`

    WHERE cart.member_id = userId AND cart.status != 'Not Sent'

    ORDER BY cart.cart_id DESC;

	SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl, cart_product.amount, cart_product.status, cart_product.cart_product_id AS cartProductId, cart.cart_id AS cartId

    FROM cart_product

INNER JOIN product ON cart_product.product_id = product.product_id

INNER JOIN cart ON cart.cart_id = cart_product.cart_id

INNER JOIN member ON product.vendor_id = member.member_id

WHERE cart.member_id = userId;

SELECT DISTINCT shipping_address.shipping_address_id AS addressId, shipping_address.member_id as userId, member.first_name AS userFirstName, member.last_name AS userLastName, shipping_address.phone, shipping_address.email, shipping_address.name AS addressName, shipping_address.country, shipping_address.postal_code AS postalCode, shipping_address.region, shipping_address.city, shipping_address.street_adress AS streetAddress 

FROM `shipping_address` 

INNER JOIN member ON shipping_address.member_id = member.member_id

INNER JOIN cart ON cart.shipping_address_id = shipping_address.shipping_address_id

WHERE cart.member_id = userId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectNotifications` (IN `userId` INT)   BEGIN

	SELECT notification.notification_id AS notificationId, notification.sender_id AS senderId, notification.reciver_id AS reciverId, notification.content, notification.type, notification.item_id AS itemId, notification.link, notification.seen, notification.sent_at AS sentAt, member.first_name AS senderFirstName, member.last_name AS senderLastName 

FROM notification 

INNER JOIN member ON member.member_id = notification.sender_id

WHERE notification.reciver_id = userId

ORDER BY notification.sent_at DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectOrder` (IN `userId` INT)   BEGIN

	SELECT DISTINCT cart.cart_id AS cartId, cart.member_id AS userId, cart.shipping_address_id AS shippingId, cart.sum_price AS sumPrice, cart.status

    FROM `cart` 

    INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id

    INNER JOIN product ON product.product_id = cart_product.product_id

    WHERE product.vendor_id = userId AND cart.status != 'Not Sent'

    ORDER BY cart.cart_id DESC;

	SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl, cart_product.amount, cart_product.status, cart_product.cart_product_id AS cartProductId, cart.cart_id AS cartId

    FROM cart_product

INNER JOIN product ON cart_product.product_id = product.product_id

INNER JOIN cart ON cart.cart_id = cart_product.cart_id

INNER JOIN member ON cart.member_id = member.member_id

WHERE product.vendor_id = userId AND cart_product.status != 'In Cart'

ORDER BY cart.cart_id;

SELECT shipping_address.shipping_address_id AS addressId, shipping_address.member_id as userId, member.first_name AS userFirstName, member.last_name AS userLastName, shipping_address.phone, shipping_address.email, shipping_address.name AS addressName, shipping_address.country, shipping_address.postal_code AS postalCode, shipping_address.region, shipping_address.city, shipping_address.street_adress AS streetAddress 

FROM `shipping_address` 

INNER JOIN member ON shipping_address.member_id = member.member_id

INNER JOIN cart ON cart.shipping_address_id = shipping_address.shipping_address_id

INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id

INNER JOIN product ON product.product_id = cart_product.product_id

WHERE product.vendor_id = userId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectProduct` (IN `prodId` INT)  NO SQL BEGIN

	SELECT material_name FROM material INNER JOIN product_material ON material.material_id = product_material.material_id WHERE product_material.product_id = prodId;

    SELECT tag_name FROM tag INNER JOIN product_tag ON tag.tag_id = product_tag.tag_id WHERE product_tag.product_id = prodId;

    SELECT product_picture.resource_link FROM product_picture WHERE product_picture.product_id = prodId;

    SELECT review.review_id AS reviewId, review.member_id AS userId, review.rating, review.title, review.content, review.published_at AS publishedAt, member.first_name AS userFirstName, member.last_name AS userLastName FROM review INNER JOIN member ON member.member_id = review.member_id WHERE review.product_id = prodId ORDER BY review.points DESC;

    SELECT product.product_id AS productId, product.name, product.price, product.description, product.inventory, product.delivery, product.category, product.rating, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, product.created_at AS createdAt, product.last_updated_at AS lastUpdatedAt, product.published_at AS publishedAt, member.first_name AS sellerFirstName, member.last_name AS sellerLastName FROM product INNER JOIN member ON member.member_id = product.vendor_id WHERE product_id = prodId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectReview` (IN `reviewId` INT, IN `userId` INT)   BEGIN

	IF (userId = 0) THEN

    	SELECT review.review_id AS reviewId, review.product_id AS productId, review.member_id AS memberId, review.rating, review.points, review.title, review.content, review.published_at AS publishedAt, member.first_name AS userFirstName, member.last_name AS userLastName 

        FROM review

        INNER JOIN member ON member.member_id = review.member_id 

        WHERE review.review_id = reviewId;

    ELSE

    	SELECT review.review_id AS reviewId, review.product_id AS productId, review.member_id AS memberId, review.rating, review.points, review.title, review.content, review.published_at AS publishedAt, member.first_name AS userFirstName, member.last_name AS userLastName, 

        (SELECT  review_vote.vote

FROM review_vote

WHERE review_id = reviewId AND member_id = userId) AS myVote

        FROM review 

        INNER JOIN member ON member.member_id = review.member_id 

        WHERE review.review_id = reviewId;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectUser` (IN `userId` INT, IN `myUserId` INT)   BEGIN

	IF myUserId = 0 THEN

    	IF (SELECT member.is_vendor AS isVendor FROM member WHERE member.member_id = userId) THEN

    	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, member.header_picture_link AS headerImgUrl, member.registered_at AS registeredAt, v.company_name AS companyName, v.site_location AS siteLocation, v.website, v.takes_custom_orders AS takesCustomOrders, 

        (SELECT COUNT(follower_relations.following_id) FROM follower_relations WHERE follower_relations.following_id  = userId) AS followers, 

        (SELECT COUNT(follower_relations.follower_id) FROM follower_relations WHERE follower_relations.follower_id = userId) AS following,

        member.email, member.phone, member.is_vendor AS isVendor

        FROM member 

        INNER JOIN vendor_detail AS v ON v.member_id = member.member_id 

        WHERE member.member_id = userId;

	ELSE

    	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, member.header_picture_link AS headerImgUrl, member.registered_at AS registeredAt, (SELECT COUNT(follower_relations.following_id) FROM follower_relations WHERE follower_relations.following_id = userId) AS followers, (SELECT COUNT(follower_relations.follower_id) FROM follower_relations WHERE follower_relations.follower_id = userId) AS following, member.email, member.phone, member.is_vendor AS isVendor

        FROM member 

        WHERE member.member_id = userId;

    END IF;

    ELSE

    	IF (SELECT member.is_vendor AS isVendor FROM member WHERE member.member_id = userId) THEN

    	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, member.header_picture_link AS headerImgUrl, member.registered_at AS registeredAt, v.company_name AS companyName, v.site_location AS siteLocation, v.website, v.takes_custom_orders AS takesCustomOrders, 

        (SELECT COUNT(follower_relations.following_id) FROM follower_relations WHERE follower_relations.following_id  = userId) AS followers, 

        (SELECT COUNT(follower_relations.follower_id) FROM follower_relations WHERE follower_relations.follower_id = userId) AS following, (SELECT EXISTS (SELECT * FROM follower_relations WHERE follower_relations.follower_id = myUserId AND follower_relations.following_id = userId)) AS iFollow, member.email, member.phone, member.is_vendor AS isVendor

        FROM member 

        INNER JOIN vendor_detail AS v ON v.member_id = member.member_id 

        WHERE member.member_id = userId;

	ELSE

    	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, member.header_picture_link AS headerImgUrl, member.registered_at AS registeredAt, (SELECT COUNT(follower_relations.following_id) FROM follower_relations WHERE follower_relations.following_id = userId) AS followers, (SELECT COUNT(follower_relations.follower_id) FROM follower_relations WHERE follower_relations.follower_id = userId) AS following, (SELECT EXISTS (SELECT * FROM follower_relations WHERE follower_relations.follower_id = myUserId AND follower_relations.following_id = userId)) AS iFollow, member.email, member.phone, member.is_vendor AS isVendor

        FROM member 

        WHERE member.member_id = userId;

    END IF;

    END IF;

	

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectUserShort` (IN `userId` INT, IN `myUserId` TINYINT)  NO SQL BEGIN

	IF myUserId != 0 THEN

    	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, vendor_detail.takes_custom_orders AS takesCustomOrders, (SELECT EXISTS (SELECT * FROM follower_relations WHERE follower_relations.follower_id = myUserId AND follower_relations.following_id = userId)) AS iFollow FROM member INNER JOIN vendor_detail ON vendor_detail.member_id = member.member_id WHERE member.member_id = userId;

    ELSE

    	SELECT member.member_id AS userId, member.first_name AS firstName, member.last_name AS lastName, member.about, member.profile_picture_link AS profileImgUrl, vendor_detail.takes_custom_orders AS takesCustomOrders FROM member INNER JOIN vendor_detail ON vendor_detail.member_id = member.member_id WHERE member.member_id = userId;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectWishList` (IN `userId` INT)  NO SQL SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl, wish_list.wish_list_id AS wishListId, wish_list.added_at AS addedAt

FROM wish_list

INNER JOIN product ON product.product_id = wish_list.product_id

INNER JOIN member ON member.member_id = product.vendor_id

WHERE wish_list.member_id = userId AND product.is_published = TRUE

ORDER BY wish_list.added_at DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `signUp` (IN `lastName` VARCHAR(50), IN `firstName` VARCHAR(50), IN `userEmail` VARCHAR(100), IN `userPassword` VARCHAR(50), IN `profilePicture` VARCHAR(50), IN `headerPicture` VARCHAR(50), IN `registered` DATE)   BEGIN
	insert into `member` (`last_name`, `first_name`, `email`, `password`, `profile_picture_link`, `header_picture_link`, `registered_at`) values(lastName,firstName,userEmail,userPassword,profilePicture,headerPicture,registered);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateAddress` (IN `userId` INT, IN `nm` VARCHAR(50), IN `phn` VARCHAR(50), IN `frstNm` VARCHAR(50), IN `lstNm` VARCHAR(50), IN `mail` VARCHAR(100), IN `cntry` VARCHAR(50), IN `rgn` VARCHAR(50), IN `cty` VARCHAR(50), IN `strtAd` VARCHAR(50), IN `postCode` VARCHAR(50), IN `saId` INT)  NO SQL BEGIN

	IF nm = '' THEN

    	SET @count = (SELECT COUNT(*) FROM shipping_address WHERE shipping_address.member_id = userId);

    	SET nm = CONCAT(@count, '. szállítási cím');

    END IF;

	UPDATE shipping_address SET shipping_address.name=nm, shipping_address.phone=phn, shipping_address.first_name=frstNm,  shipping_address.last_name=lstNm, shipping_address.email=mail, country=cntry, region=rgn, city=cty, street_adress=strtAd, postal_code=postCode WHERE shipping_address.shipping_address_id = saId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateCartProducts` (IN `sts` VARCHAR(255), IN `length` INT)  NO SQL BEGIN

	DECLARE x INT DEFAULT 1;

	CREATE TEMPORARY TABLE statuses(i INT, name VARCHAR(50), cpId INT);

    SET @sql = CONCAT('INSERT INTO statuses(i, name, cpId) VALUES ', sts);

  	PREPARE stmt FROM @sql;

  	EXECUTE stmt;

  	DEALLOCATE PREPARE stmt;

    WHILE (x < (length + 1)) DO

        UPDATE cart_product SET cart_product.status = ( SELECT statuses.name FROM statuses WHERE statuses.i = x) WHERE cart_product.cart_product_id =  (SELECT statuses.cpId FROM statuses WHERE statuses.i = x);

        SET @cartProdId = (SELECT statuses.cpId FROM statuses WHERE statuses.i = x);

        SET @stat = ( SELECT statuses.name FROM statuses WHERE statuses.i = x);

        IF @stat = 'Arrived' THEN

        	CALL insertNotification((SELECT cart.member_id FROM cart INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id WHERE cart_product.cart_product_id = @cartProdId), (SELECT product.vendor_id FROM product INNER JOIN cart_product ON cart_product.product_id = product.product_id WHERE cart_product.cart_product_id = @cartProdId), 'order-arrived', @cartProdId);

        ELSE

            CALL insertNotification((SELECT product.vendor_id FROM product INNER JOIN cart_product ON cart_product.product_id = product.product_id WHERE cart_product.cart_product_id = @cartProdId), (SELECT cart.member_id FROM cart INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id WHERE cart_product.cart_product_id = @cartProdId), 'order-tracking', @cartProdId);

        END IF;

        SET x = x + 1;

    END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateMaterials` (IN `mats` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL BEGIN

	DELETE FROM product_material WHERE product_id = prodId;

    CALL insertMaterials(mats, length, prodId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateNotifSeen` (IN `notifId` INT)   BEGIN

	UPDATE notification SET notification.seen= TRUE WHERE notification.notification_id = notifId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateOrderCart` (IN `cartId` INT, IN `st` VARCHAR(50))   BEGIN

	UPDATE `cart` SET `status`=st WHERE cart.cart_id = cartId;

    UPDATE cart_product SET cart_product.status = st WHERE cart_product.cart_id = cartId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePictures` (IN `pics` VARCHAR(255), IN `length` INT, IN `prodId` INT, IN `thId` INT)  NO SQL BEGIN

	DELETE FROM product_picture WHERE product_id = prodId;

    CALL insertPictures(pics, length, prodId, thId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateProduct` (IN `nm` VARCHAR(50), IN `prc` INT, IN `dsc` TEXT, IN `inv` INT, IN `del` VARCHAR(50), IN `cat` VARCHAR(50), IN `disc` INT, IN `isPub` TINYINT, IN `lstUp` DATETIME, IN `pubAt` DATETIME, IN `prodId` INT, IN `tags` VARCHAR(255), IN `tagsL` INT, IN `mats` VARCHAR(255), IN `matsL` INT, IN `pics` VARCHAR(255), IN `picsL` INT, IN `thumId` INT)  NO SQL BEGIN

	UPDATE `product` SET `name`=nm,`price`=prc,`description`=dsc,`inventory`=inv,`delivery`=del, `category`=cat,`discount`=disc,`is_published`=isPub,`last_updated_at`=lstUp, `published_at`=pubAt WHERE product_id = prodId;

    CALL updateTags(tags, tagsL, prodId);

    CALL updateMaterials(mats, matsL, prodId);

    CALL updatePictures(pics, picsL, prodId, thumId);

    CALL selectProduct(prodId);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateTags` (IN `tgs` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL BEGIN

	DELETE FROM product_tag WHERE product_id = prodId;

    CALL insertTags(tgs, length, prodId);



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUser` (IN `userId` INT, IN `frstNm` VARCHAR(50), IN `lstNm` VARCHAR(50), IN `phn` VARCHAR(15), IN `abt` TEXT, IN `pfpUrl` VARCHAR(200), IN `headerUrl` VARCHAR(200), IN `isVndor` TINYINT, IN `cNm` VARCHAR(50), IN `siteL` VARCHAR(50), IN `wbst` VARCHAR(50), IN `cstOrder` TINYINT)  NO SQL BEGIN

	UPDATE `member` SET `first_name`= frstNm ,`last_name`= lstNm, `phone`=phn,`about`=abt,`profile_picture_link`= pfpUrl,`header_picture_link`= headerUrl, `is_vendor`= isVndor WHERE member.member_id = userId;

    IF (SELECT member.is_vendor FROM member WHERE member.member_id = userId) THEN

    	UPDATE `vendor_detail` SET `company_name`= cNm,`site_location`= siteL,`website`= wbst, `takes_custom_orders`= cstOrder WHERE vendor_detail_id = (SELECT vendor_detail_id FROM vendor_detail WHERE vendor_detail.member_id = userId);

    END IF;
	CALL selectUser(userId,0);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `cart_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `shipping_address_id` int(11) DEFAULT NULL,
  `sum_price` int(11) DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart_product`
--

CREATE TABLE `cart_product` (
  `cart_product_id` int(11) NOT NULL,
  `cart_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `city`
--

CREATE TABLE `city` (
  `city_id` int(11) NOT NULL,
  `city_name` varchar(50) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `postal_code` varchar(10) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `region_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `city`
--

INSERT INTO `city` (`city_id`, `city_name`, `postal_code`, `region_id`) VALUES
(1, 'Aba', '8127', 6),
(2, 'Aba', '8128', 6),
(3, 'Abádszalók', '5241', 10),
(4, 'Abaliget', '7678', 2),
(5, 'Abasár', '3261', 9),
(6, 'Abaújalpár', '3882', 4),
(7, 'Abaújkér', '3882', 4),
(8, 'Abaújlak', '3815', 4),
(9, 'Abaújszántó', '3881', 4),
(10, 'Abaújszolnok', '3809', 4),
(11, 'Abaújvár', '3898', 4),
(12, 'Abda', '9151', 7),
(13, 'Abod', '3753', 4),
(14, 'Abony', '2740', 13),
(15, 'Ábrahámhegy', '8256', 18),
(16, 'Ács', '2941', 11),
(17, 'Acsa', '2683', 13),
(18, 'Acsád', '9746', 17),
(19, 'Acsalag', '9168', 7),
(20, 'Ácsteszér', '2887', 11),
(21, 'Adács', '3292', 9),
(22, 'Ádánd', '8653', 14),
(23, 'Adásztevel', '8561', 18),
(24, 'Adony', '2457', 6),
(25, 'Adorjánháza', '8497', 18),
(26, 'Adorjás', '7841', 2),
(27, 'Ág', '7381', 2),
(28, 'Ágasegyháza', '6076', 1),
(29, 'Ágfalva', '9423', 7),
(30, 'Aggtelek', '3759', 4),
(31, 'Agyagosszergény', '9441', 7),
(32, 'Ajak', '4524', 15),
(33, 'Ajka', '8400', 18),
(34, 'Ajka', '8447', 18),
(35, 'Ajka', '8448', 18),
(36, 'Ajka', '8451', 18),
(37, 'Aka', '2862', 11),
(38, 'Akasztó', '6221', 1),
(39, 'Alacska', '3779', 4),
(40, 'Alap', '7011', 6),
(41, 'Alattyán', '5142', 10),
(42, 'Albertirsa', '2730', 13),
(43, 'Alcsútdoboz', '8087', 6),
(44, 'Aldebrő', '3353', 9),
(45, 'Algyő', '6750', 5),
(46, 'Alibánfa', '8921', 19),
(47, 'Almamellék', '7934', 2),
(48, 'Almásfüzitő', '2931', 11),
(49, 'Almásháza', '8935', 19),
(50, 'Almáskamarás', '5747', 3),
(51, 'Almáskeresztúr', '7932', 2),
(52, 'Álmosd', '4285', 8),
(53, 'Alsóberecki', '3985', 4),
(54, 'Alsóbogát', '7443', 14),
(55, 'Alsódobsza', '3717', 4),
(56, 'Alsógagy', '3837', 4),
(57, 'Alsómocsolád', '7345', 2),
(58, 'Alsónána', '7147', 16),
(59, 'Alsónémedi', '2351', 13),
(60, 'Alsónemesapáti', '8924', 19),
(61, 'Alsónyék', '7148', 16),
(62, 'Alsóörs', '8226', 18),
(63, 'Alsópáhok', '8394', 19),
(64, 'Alsópetény', '2617', 12),
(65, 'Alsórajk', '8767', 19),
(66, 'Alsóregmec', '3989', 4),
(67, 'Alsószenterzsébet', '8973', 19),
(68, 'Alsószentiván', '7012', 6),
(69, 'Alsószentmárton', '7826', 2),
(70, 'Alsószölnök', '9983', 17),
(71, 'Alsószuha', '3726', 4),
(72, 'Alsótelekes', '3735', 4),
(73, 'Alsótold', '3069', 12),
(74, 'Alsóújlak', '9842', 17),
(75, 'Alsóvadász', '3811', 4),
(76, 'Alsózsolca', '3571', 4),
(77, 'Ambrózfalva', '6916', 5),
(78, 'Anarcs', '4546', 15),
(79, 'Andocs', '8675', 14),
(80, 'Andornaktálya', '3399', 9),
(81, 'Andrásfa', '9811', 17),
(82, 'Annavölgy', '2529', 11),
(83, 'Apácatorna', '8477', 18),
(84, 'Apagy', '4553', 15),
(85, 'Apaj', '2345', 13),
(86, 'Aparhant', '7186', 16),
(87, 'Apátfalva', '6931', 5),
(88, 'Apátistvánfalva', '9982', 17),
(89, 'Apátvarasd', '7720', 2),
(90, 'Apc', '3032', 9),
(91, 'Áporka', '2338', 13),
(92, 'Apostag', '6088', 1),
(93, 'Aranyosapáti', '4634', 15),
(94, 'Aranyosgadány', '7671', 2),
(95, 'Arka', '3885', 4),
(96, 'Arló', '3663', 4),
(97, 'Arnót', '3713', 4),
(98, 'Ároktő', '3467', 4),
(99, 'Árpádhalom', '6623', 5),
(100, 'Árpás', '9132', 7),
(101, 'Ártánd', '4115', 8),
(102, 'Ásotthalom', '6783', 5),
(103, 'Ásványráró', '9177', 7),
(104, 'Aszaló', '3841', 4),
(105, 'Ászár', '2881', 11),
(106, 'Aszód', '2170', 13),
(107, 'Aszófő', '8241', 18),
(108, 'Áta', '7763', 2),
(109, 'Átány', '3371', 9),
(110, 'Atkár', '3213', 9),
(111, 'Attala', '7252', 16),
(112, 'Babarc', '7757', 2),
(113, 'Babarcszőlős', '7814', 2),
(114, 'Babócsa', '7584', 14),
(115, 'Bábolna', '2943', 11),
(116, 'Bábonymegyer', '8658', 14),
(117, 'Babosdöbréte', '8983', 19),
(118, 'Babót', '9351', 7),
(119, 'Bácsalmás', '6430', 1),
(120, 'Bácsbokod', '6453', 1),
(121, 'Bácsborsód', '6454', 1),
(122, 'Bácsszentgyörgy', '6511', 1),
(123, 'Bácsszőlős', '6425', 1),
(124, 'Badacsonytomaj', '8257', 18),
(125, 'Badacsonytomaj', '8258', 18),
(126, 'Badacsonytomaj', '8261', 18),
(127, 'Badacsonytördemic', '8262', 18),
(128, 'Badacsonytördemic', '8263', 18),
(129, 'Bag', '2191', 13),
(130, 'Bagamér', '4286', 8),
(131, 'Baglad', '8977', 19),
(132, 'Bagod', '8992', 19),
(133, 'Bágyogszovát', '9145', 7),
(134, 'Baj', '2836', 11),
(135, 'Baja', '6500', 1),
(136, 'Baja', '6503', 1),
(137, 'Bajánsenye', '9944', 17),
(138, 'Bajna', '2525', 11),
(139, 'Bajót', '2533', 11),
(140, 'Bak', '8945', 19),
(141, 'Bakháza', '7585', 14),
(142, 'Bakóca', '7393', 2),
(143, 'Bakonszeg', '4164', 8),
(144, 'Bakonya', '7675', 2),
(145, 'Bakonybánk', '2885', 11),
(146, 'Bakonybél', '8427', 18),
(147, 'Bakonycsernye', '8056', 6),
(148, 'Bakonygyirót', '8433', 7),
(149, 'Bakonyjákó', '8581', 18),
(150, 'Bakonykoppány', '8571', 18),
(151, 'Bakonykúti', '8045', 6),
(152, 'Bakonynána', '8422', 18),
(153, 'Bakonyoszlop', '8418', 18),
(154, 'Bakonypéterd', '9088', 7),
(155, 'Bakonypölöske', '8457', 18),
(156, 'Bakonyság', '8557', 18),
(157, 'Bakonysárkány', '2861', 11),
(158, 'Bakonyszentiván', '8557', 18),
(159, 'Bakonyszentkirály', '8430', 18),
(160, 'Bakonyszentlászló', '8431', 7),
(161, 'Bakonyszombathely', '2884', 11),
(162, 'Bakonyszücs', '8572', 18),
(163, 'Bakonytamási', '8555', 18),
(164, 'Baks', '6768', 5),
(165, 'Baksa', '7834', 2),
(166, 'Baktakék', '3836', 4),
(167, 'Baktalórántháza', '4561', 15),
(168, 'Baktüttös', '8946', 19),
(169, 'Balajt', '3780', 4),
(170, 'Balassagyarmat', '2660', 12),
(171, 'Balástya', '6764', 5),
(172, 'Balaton', '3347', 9),
(173, 'Balatonakali', '8243', 18),
(174, 'Balatonalmádi', '8220', 18),
(175, 'Balatonberény', '8649', 14),
(176, 'Balatonboglár', '8630', 14),
(177, 'Balatonboglár', '8691', 14),
(178, 'Balatoncsicsó', '8272', 18),
(179, 'Balatonederics', '8312', 18),
(180, 'Balatonendréd', '8613', 14),
(181, 'Balatonfenyves', '8646', 14),
(182, 'Balatonfőkajár', '8164', 18),
(183, 'Balatonföldvár', '8623', 14),
(184, 'Balatonfüred', '8230', 18),
(185, 'Balatonfüred', '8236', 18),
(186, 'Balatonfűzfő', '8175', 18),
(187, 'Balatonfűzfő', '8184', 18),
(188, 'Balatongyörök', '8313', 19),
(189, 'Balatonhenye', '8275', 18),
(190, 'Balatonkenese', '8172', 18),
(191, 'Balatonkenese', '8174', 18),
(192, 'Balatonkeresztúr', '8648', 14),
(193, 'Balatonlelle', '8638', 14),
(194, 'Balatonmagyaród', '8753', 19),
(195, 'Balatonmáriafürdő', '8647', 14),
(196, 'Balatonőszöd', '8637', 14),
(197, 'Balatonrendes', '8255', 18),
(198, 'Balatonszabadi', '8651', 14),
(199, 'Balatonszárszó', '8624', 14),
(200, 'Balatonszemes', '8636', 14),
(201, 'Balatonszentgyörgy', '8710', 14),
(202, 'Balatonszepezd', '8252', 18),
(203, 'Balatonszőlős', '8233', 18),
(204, 'Balatonudvari', '8242', 18),
(205, 'Balatonújlak', '8712', 14),
(206, 'Balatonvilágos', '8171', 18),
(207, 'Balinka', '8054', 6),
(208, 'Balinka', '8055', 6),
(209, 'Balkány', '4233', 15),
(210, 'Ballószög', '6035', 1),
(211, 'Balmazújváros', '4060', 8),
(212, 'Balogunyom', '9771', 17),
(213, 'Balotaszállás', '6412', 1),
(214, 'Balsa', '4468', 15),
(215, 'Bálványos', '8614', 14),
(216, 'Bana', '2944', 11),
(217, 'Bánd', '8443', 18),
(218, 'Bánfa', '7914', 2),
(219, 'Bánhorváti', '3642', 4),
(220, 'Bánk', '2653', 12),
(221, 'Bánokszentgyörgy', '8891', 19),
(222, 'Bánréve', '3654', 4),
(223, 'Bár', '7711', 2),
(224, 'Barabás', '4937', 15),
(225, 'Baracs', '2426', 6),
(226, 'Baracs', '2427', 6),
(227, 'Baracska', '2471', 6),
(228, 'Báránd', '4161', 8),
(229, 'Baranyahidvég', '7841', 2),
(230, 'Baranyajenő', '7384', 2),
(231, 'Baranyaszentgyörgy', '7383', 2),
(232, 'Barbacs', '9169', 7),
(233, 'Barcs', '7557', 14),
(234, 'Barcs', '7570', 14),
(235, 'Bárdudvarnok', '7478', 14),
(236, 'Barlahida', '8948', 19),
(237, 'Bárna', '3126', 12),
(238, 'Barnag', '8291', 18),
(239, 'Bársonyos', '2883', 11),
(240, 'Basal', '7923', 2),
(241, 'Baskó', '3881', 4),
(242, 'Báta', '7149', 16),
(243, 'Bátaapáti', '7164', 16),
(244, 'Bátaszék', '7140', 16),
(245, 'Baté', '7258', 14),
(246, 'Bátmonostor', '6528', 1),
(247, 'Bátonyterenye', '3070', 12),
(248, 'Bátonyterenye', '3078', 12),
(249, 'Bátor', '3336', 9),
(250, 'Bátorliget', '4343', 15),
(251, 'Battonya', '5830', 3),
(252, 'Bátya', '6351', 1),
(253, 'Batyk', '8797', 19),
(254, 'Bázakerettye', '8887', 19),
(255, 'Bazsi', '8352', 18),
(256, 'Béb', '8565', 18),
(257, 'Becsehely', '8866', 19),
(258, 'Becske', '2693', 12),
(259, 'Becskeháza', '3768', 4),
(260, 'Becsvölgye', '8985', 19),
(261, 'Bedegkér', '8666', 14),
(262, 'Bedő', '4128', 8),
(263, 'Bejcgyertyános', '9683', 17),
(264, 'Békás', '8515', 18),
(265, 'Bekecs', '3903', 4),
(266, 'Békés', '5630', 3),
(267, 'Békéscsaba', '5600', 3),
(268, 'Békéscsaba', '5623', 3),
(269, 'Békéscsaba', '5671', 3),
(270, 'Békéssámson', '5946', 3),
(271, 'Békésszentandrás', '5561', 3),
(272, 'Bekölce', '3343', 9),
(273, 'Bélapátfalva', '3346', 9),
(274, 'Bélavár', '7589', 14),
(275, 'Belecska', '7061', 16),
(276, 'Beled', '9343', 7),
(277, 'Beleg', '7543', 14),
(278, 'Belezna', '8855', 19),
(279, 'Bélmegyer', '5643', 3),
(280, 'Beloiannisz', '2455', 6),
(281, 'Belsősárd', '8978', 19),
(282, 'Belvárdgyula', '7747', 2),
(283, 'Benk', '4643', 15),
(284, 'Bénye', '2216', 13),
(285, 'Bér', '3045', 12),
(286, 'Bérbaltavár', '9831', 17),
(287, 'Bercel', '2687', 12),
(288, 'Beregdaróc', '4934', 15),
(289, 'Beregsurány', '4933', 15),
(290, 'Berekböszörmény', '4116', 8),
(291, 'Berekfürdő', '5309', 10),
(292, 'Beremend', '7827', 2),
(293, 'Berente', '3704', 4),
(294, 'Beret', '3834', 4),
(295, 'Berettyóújfalu', '4100', 8),
(296, 'Berettyóújfalu', '4103', 8),
(297, 'Berhida', '8181', 18),
(298, 'Berhida', '8182', 18),
(299, 'Berkenye', '2641', 12),
(300, 'Berkesd', '7664', 2),
(301, 'Berkesz', '4521', 15),
(302, 'Bernecebaráti', '2639', 13),
(303, 'Berzék', '3575', 4),
(304, 'Berzence', '7516', 14),
(305, 'Besence', '7838', 2),
(306, 'Besenyőd', '4557', 15),
(307, 'Besenyőtelek', '3373', 9),
(308, 'Besenyszög', '5071', 10),
(309, 'Besnyő', '2456', 6),
(310, 'Beszterec', '4488', 15),
(311, 'Bezedek', '7782', 2),
(312, 'Bezenye', '9223', 7),
(313, 'Bezeréd', '8934', 19),
(314, 'Bezi', '9162', 7),
(315, 'Biatorbágy', '2051', 13),
(316, 'Bicsérd', '7671', 2),
(317, 'Bicske', '2060', 6),
(318, 'Bihardancsháza', '4175', 8),
(319, 'Biharkeresztes', '4110', 8),
(320, 'Biharnagybajom', '4172', 8),
(321, 'Bihartorda', '4174', 8),
(322, 'Biharugra', '5538', 3),
(323, 'Bikács', '7043', 16),
(324, 'Bikal', '7346', 2),
(325, 'Biri', '4235', 15),
(326, 'Birján', '7747', 2),
(327, 'Bisse', '7811', 2),
(328, 'Bő', '9625', 17),
(329, 'Boba', '9542', 17),
(330, 'Bocfölde', '8943', 19),
(331, 'Boconád', '3368', 9),
(332, 'Bőcs', '3574', 4),
(333, 'Bócsa', '6235', 1),
(334, 'Bocska', '8776', 19),
(335, 'Bocskaikert', '4241', 8),
(336, 'Boda', '7672', 2),
(337, 'Bodajk', '8053', 6),
(338, 'Böde', '8991', 19),
(339, 'Bödeháza', '8969', 19),
(340, 'Bodmér', '8085', 6),
(341, 'Bodolyabér', '7394', 2),
(342, 'Bodonhely', '9134', 7),
(343, 'Bodony', '3243', 9),
(344, 'Bodorfa', '8471', 18),
(345, 'Bodrog', '7439', 14),
(346, 'Bodroghalom', '3987', 4),
(347, 'Bodrogkeresztúr', '3916', 4),
(348, 'Bodrogkisfalud', '3917', 4),
(349, 'Bodrogolaszi', '3943', 4),
(350, 'Bódvalenke', '3768', 4),
(351, 'Bódvarákó', '3764', 4),
(352, 'Bódvaszilas', '3763', 4),
(353, 'Bogács', '3412', 4),
(354, 'Bogád', '7742', 2),
(355, 'Bogádmindszent', '7836', 2),
(356, 'Bogdása', '7966', 2),
(357, 'Bögöt', '9612', 17),
(358, 'Bögöte', '9675', 17),
(359, 'Bogyiszló', '7132', 16),
(360, 'Bogyoszló', '9324', 7),
(361, 'Böhönye', '8719', 14),
(362, 'Bojt', '4114', 8),
(363, 'Bókaháza', '8741', 19),
(364, 'Bokod', '2855', 11),
(365, 'Bököny', '4231', 15),
(366, 'Bokor', '3066', 12),
(367, 'Bölcske', '7025', 16),
(368, 'Boldog', '3016', 9),
(369, 'Boldogasszonyfa', '7937', 2),
(370, 'Boldogkőújfalu', '3884', 4),
(371, 'Boldogkőváralja', '3885', 4),
(372, 'Boldva', '3794', 4),
(373, 'Bolhás', '7517', 14),
(374, 'Bolhó', '7586', 14),
(375, 'Bóly', '7754', 2),
(376, 'Boncodfölde', '8992', 19),
(377, 'Bonnya', '7281', 14),
(378, 'Bőny', '9073', 7),
(379, 'Bonyhád', '7150', 16),
(380, 'Bonyhád', '7187', 16),
(381, 'Bonyhádvarasd', '7158', 16),
(382, 'Börcs', '9152', 7),
(383, 'Bordány', '6795', 5),
(384, 'Borgáta', '9554', 17),
(385, 'Borjád', '7756', 2),
(386, 'Borota', '6445', 1),
(387, 'Borsfa', '8885', 19),
(388, 'Borsodbóta', '3658', 4),
(389, 'Borsodgeszt', '3426', 4),
(390, 'Borsodivánka', '3462', 4),
(391, 'Borsodnádasd', '3671', 4),
(392, 'Borsodnádasd', '3672', 4),
(393, 'Borsodszentgyörgy', '3623', 4),
(394, 'Borsodszirák', '3796', 4),
(395, 'Borsosberény', '2644', 12),
(396, 'Borszörcsök', '8479', 18),
(397, 'Borzavár', '8428', 18),
(398, 'Börzönce', '8772', 19),
(399, 'Bősárkány', '9167', 7),
(400, 'Bosta', '7811', 2),
(401, 'Bőszénfa', '7475', 14),
(402, 'Botpalád', '4955', 15),
(403, 'Botykapeterd', '7900', 2),
(404, 'Bozsok', '9727', 17),
(405, 'Bózsva', '3994', 4),
(406, 'Bozzai', '9752', 17),
(407, 'Bucsa', '5527', 3),
(408, 'Bucsu', '9792', 17),
(409, 'Bucsuszentlászló', '8925', 19),
(410, 'Bucsuta', '8893', 19),
(411, 'Budajenő', '2093', 13),
(412, 'Budakalász', '2011', 13),
(413, 'Budakeszi', '2092', 13),
(414, 'Budaörs', '2040', 13),
(415, 'Budapest', '1011', 20),
(416, 'Budapest', '1012', 20),
(417, 'Budapest', '1013', 20),
(418, 'Budapest', '1014', 20),
(419, 'Budapest', '1015', 20),
(420, 'Budapest', '1016', 20),
(421, 'Budapest', '1021', 20),
(422, 'Budapest', '1022', 20),
(423, 'Budapest', '1023', 20),
(424, 'Budapest', '1024', 20),
(425, 'Budapest', '1025', 20),
(426, 'Budapest', '1026', 20),
(427, 'Budapest', '1027', 20),
(428, 'Budapest', '1028', 20),
(429, 'Budapest', '1029', 20),
(430, 'Budapest', '1031', 20),
(431, 'Budapest', '1032', 20),
(432, 'Budapest', '1033', 20),
(433, 'Budapest', '1034', 20),
(434, 'Budapest', '1035', 20),
(435, 'Budapest', '1036', 20),
(436, 'Budapest', '1037', 20),
(437, 'Budapest', '1038', 20),
(438, 'Budapest', '1039', 20),
(439, 'Budapest', '1041', 20),
(440, 'Budapest', '1042', 20),
(441, 'Budapest', '1043', 20),
(442, 'Budapest', '1044', 20),
(443, 'Budapest', '1045', 20),
(444, 'Budapest', '1046', 20),
(445, 'Budapest', '1047', 20),
(446, 'Budapest', '1048', 20),
(447, 'Budapest', '1051', 20),
(448, 'Budapest', '1052', 20),
(449, 'Budapest', '1053', 20),
(450, 'Budapest', '1054', 20),
(451, 'Budapest', '1055', 20),
(452, 'Budapest', '1056', 20),
(453, 'Budapest', '1061', 20),
(454, 'Budapest', '1062', 20),
(455, 'Budapest', '1063', 20),
(456, 'Budapest', '1064', 20),
(457, 'Budapest', '1065', 20),
(458, 'Budapest', '1066', 20),
(459, 'Budapest', '1067', 20),
(460, 'Budapest', '1068', 20),
(461, 'Budapest', '1069', 20),
(462, 'Budapest', '1071', 20),
(463, 'Budapest', '1072', 20),
(464, 'Budapest', '1073', 20),
(465, 'Budapest', '1074', 20),
(466, 'Budapest', '1075', 20),
(467, 'Budapest', '1076', 20),
(468, 'Budapest', '1077', 20),
(469, 'Budapest', '1078', 20),
(470, 'Budapest', '1081', 20),
(471, 'Budapest', '1082', 20),
(472, 'Budapest', '1083', 20),
(473, 'Budapest', '1084', 20),
(474, 'Budapest', '1085', 20),
(475, 'Budapest', '1086', 20),
(476, 'Budapest', '1087', 20),
(477, 'Budapest', '1088', 20),
(478, 'Budapest', '1089', 20),
(479, 'Budapest', '1091', 20),
(480, 'Budapest', '1092', 20),
(481, 'Budapest', '1093', 20),
(482, 'Budapest', '1094', 20),
(483, 'Budapest', '1095', 20),
(484, 'Budapest', '1096', 20),
(485, 'Budapest', '1097', 20),
(486, 'Budapest', '1098', 20),
(487, 'Budapest', '1101', 20),
(488, 'Budapest', '1102', 20),
(489, 'Budapest', '1103', 20),
(490, 'Budapest', '1104', 20),
(491, 'Budapest', '1105', 20),
(492, 'Budapest', '1106', 20),
(493, 'Budapest', '1107', 20),
(494, 'Budapest', '1108', 20),
(495, 'Budapest', '1111', 20),
(496, 'Budapest', '1112', 20),
(497, 'Budapest', '1113', 20),
(498, 'Budapest', '1114', 20),
(499, 'Budapest', '1115', 20),
(500, 'Budapest', '1116', 20),
(501, 'Budapest', '1117', 20),
(502, 'Budapest', '1118', 20),
(503, 'Budapest', '1119', 20),
(504, 'Budapest', '1121', 20),
(505, 'Budapest', '1122', 20),
(506, 'Budapest', '1123', 20),
(507, 'Budapest', '1124', 20),
(508, 'Budapest', '1125', 20),
(509, 'Budapest', '1126', 20),
(510, 'Budapest', '1131', 20),
(511, 'Budapest', '1132', 20),
(512, 'Budapest', '1133', 20),
(513, 'Budapest', '1134', 20),
(514, 'Budapest', '1135', 20),
(515, 'Budapest', '1136', 20),
(516, 'Budapest', '1137', 20),
(517, 'Budapest', '1138', 20),
(518, 'Budapest', '1139', 20),
(519, 'Budapest', '1141', 20),
(520, 'Budapest', '1142', 20),
(521, 'Budapest', '1143', 20),
(522, 'Budapest', '1144', 20),
(523, 'Budapest', '1145', 20),
(524, 'Budapest', '1146', 20),
(525, 'Budapest', '1147', 20),
(526, 'Budapest', '1148', 20),
(527, 'Budapest', '1149', 20),
(528, 'Budapest', '1151', 20),
(529, 'Budapest', '1152', 20),
(530, 'Budapest', '1153', 20),
(531, 'Budapest', '1154', 20),
(532, 'Budapest', '1155', 20),
(533, 'Budapest', '1156', 20),
(534, 'Budapest', '1157', 20),
(535, 'Budapest', '1158', 20),
(536, 'Budapest', '1161', 20),
(537, 'Budapest', '1162', 20),
(538, 'Budapest', '1163', 20),
(539, 'Budapest', '1164', 20),
(540, 'Budapest', '1165', 20),
(541, 'Budapest', '1171', 20),
(542, 'Budapest', '1172', 20),
(543, 'Budapest', '1173', 20),
(544, 'Budapest', '1174', 20),
(545, 'Budapest', '1181', 20),
(546, 'Budapest', '1182', 20),
(547, 'Budapest', '1183', 20),
(548, 'Budapest', '1184', 20),
(549, 'Budapest', '1185', 20),
(550, 'Budapest', '1186', 20),
(551, 'Budapest', '1188', 20),
(552, 'Budapest', '1191', 20),
(553, 'Budapest', '1192', 20),
(554, 'Budapest', '1193', 20),
(555, 'Budapest', '1194', 20),
(556, 'Budapest', '1195', 20),
(557, 'Budapest', '1196', 20),
(558, 'Budapest', '1201', 20),
(559, 'Budapest', '1202', 20),
(560, 'Budapest', '1203', 20),
(561, 'Budapest', '1204', 20),
(562, 'Budapest', '1205', 20),
(563, 'Budapest', '1211', 20),
(564, 'Budapest', '1212', 20),
(565, 'Budapest', '1213', 20),
(566, 'Budapest', '1214', 20),
(567, 'Budapest', '1215', 20),
(568, 'Budapest', '1221', 20),
(569, 'Budapest', '1222', 20),
(570, 'Budapest', '1223', 20),
(571, 'Budapest', '1224', 20),
(572, 'Budapest', '1225', 20),
(573, 'Budapest', '1237', 20),
(574, 'Budapest', '1238', 20),
(575, 'Budapest', '1239', 20),
(576, 'Budapest', '1529', 20),
(577, 'Bugac', '6114', 1),
(578, 'Bugacpusztaháza', '6114', 1),
(579, 'Bugyi', '2347', 13),
(580, 'Buj', '4483', 15),
(581, 'Buják', '3047', 12),
(582, 'Bük', '9737', 17),
(583, 'Bük', '9740', 17),
(584, 'Bükkábrány', '3422', 4),
(585, 'Bükkaranyos', '3554', 4),
(586, 'Bükkmogyorósd', '3648', 4),
(587, 'Bükkösd', '7682', 2),
(588, 'Bükkszék', '3335', 9),
(589, 'Bükkszenterzsébet', '3257', 9),
(590, 'Bükkszentkereszt', '3557', 4),
(591, 'Bükkszentmárton', '3346', 9),
(592, 'Bükkzsérc', '3414', 4),
(593, 'Bürüs', '7973', 2),
(594, 'Büssü', '7273', 14),
(595, 'Büttös', '3821', 4),
(596, 'Buzsák', '8695', 14),
(597, 'Cák', '9725', 17),
(598, 'Cakóháza', '9165', 7),
(599, 'Cece', '7013', 6),
(600, 'Cégénydányád', '4732', 15),
(601, 'Cegléd', '2700', 13),
(602, 'Cegléd', '2738', 13),
(603, 'Ceglédbercel', '2737', 13),
(604, 'Celldömölk', '9500', 17),
(605, 'Celldömölk', '9541', 17),
(606, 'Cered', '3123', 12),
(607, 'Chernelházadamonya', '9624', 17),
(608, 'Cibakháza', '5462', 10),
(609, 'Cigánd', '3973', 4),
(610, 'Cikó', '7161', 16),
(611, 'Cirák', '9364', 7),
(612, 'Csabacsűd', '5551', 3),
(613, 'Csabaszabadi', '5609', 3),
(614, 'Csabdi', '2064', 6),
(615, 'Csabrendek', '8474', 18),
(616, 'Csáfordjánosfa', '9375', 7),
(617, 'Csaholc', '4967', 15),
(618, 'Csajág', '8163', 18),
(619, 'Csákány', '8735', 14),
(620, 'Csákánydoroszló', '9919', 17),
(621, 'Csákberény', '8073', 6),
(622, 'Csákvár', '8083', 6),
(623, 'Csanádalberti', '6915', 5),
(624, 'Csanádapáca', '5662', 3),
(625, 'Csanádpalota', '6913', 5),
(626, 'Csánig', '9654', 17),
(627, 'Csány', '3015', 9),
(628, 'Csányoszró', '7964', 2),
(629, 'Csanytelek', '6647', 5),
(630, 'Csapi', '8756', 19),
(631, 'Csapod', '9372', 7),
(632, 'Csárdaszállás', '5621', 3),
(633, 'Csarnóta', '7811', 2),
(634, 'Csaroda', '4844', 15),
(635, 'Császár', '2858', 11),
(636, 'Császártöltés', '6239', 1),
(637, 'Császló', '4973', 15),
(638, 'Csátalja', '6523', 1),
(639, 'Csatár', '8943', 19),
(640, 'Csataszög', '5064', 10),
(641, 'Csatka', '2888', 11),
(642, 'Csávoly', '6448', 1),
(643, 'Csebény', '7935', 2),
(644, 'Csécse', '3052', 12),
(645, 'Csegöld', '4742', 15),
(646, 'Csehbánya', '8445', 18),
(647, 'Csehi', '9833', 17),
(648, 'Csehimindszent', '9834', 17),
(649, 'Csém', '2949', 11),
(650, 'Csemő', '2713', 13),
(651, 'Csempeszkopács', '9764', 17),
(652, 'Csengele', '6765', 5),
(653, 'Csenger', '4765', 15),
(654, 'Csengersima', '4743', 15),
(655, 'Csengerújfalu', '4764', 15),
(656, 'Csengőd', '6222', 1),
(657, 'Csénye', '9611', 17),
(658, 'Csenyéte', '3837', 4),
(659, 'Csép', '2946', 11),
(660, 'Csépa', '5475', 10),
(661, 'Csepreg', '9735', 17),
(662, 'Csér', '9375', 7),
(663, 'Cserdi', '7683', 2),
(664, 'Cserénfa', '7472', 14),
(665, 'Cserépfalu', '3413', 4),
(666, 'Cserépváralja', '3417', 4),
(667, 'Cserháthaláp', '2694', 12),
(668, 'Cserhátsurány', '2676', 12),
(669, 'Cserhátszentiván', '3066', 12),
(670, 'Cserkeszőlő', '5465', 10),
(671, 'Cserkút', '7673', 2),
(672, 'Csernely', '3648', 4),
(673, 'Cserszegtomaj', '8372', 19),
(674, 'Csertalakos', '8951', 19),
(675, 'Csertő', '7900', 2),
(676, 'Csesznek', '8419', 18),
(677, 'Csesztreg', '8973', 19),
(678, 'Csesztve', '2678', 12),
(679, 'Csetény', '8417', 18),
(680, 'Csévharaszt', '2212', 13),
(681, 'Csibrák', '7225', 16),
(682, 'Csikéria', '6424', 1),
(683, 'Csikóstőttős', '7341', 16),
(684, 'Csikvánd', '9127', 7),
(685, 'Csincse', '3442', 4),
(686, 'Csipkerek', '9836', 17),
(687, 'Csitár', '2673', 12),
(688, 'Csobád', '3848', 4),
(689, 'Csobaj', '3927', 4),
(690, 'Csobánka', '2014', 13),
(691, 'Csöde', '8999', 19),
(692, 'Csögle', '8495', 18),
(693, 'Csókakő', '8074', 6),
(694, 'Csökmő', '4145', 8),
(695, 'Csököly', '7526', 14),
(696, 'Csokonyavisonta', '7555', 14),
(697, 'Csokvaomány', '3647', 4),
(698, 'Csolnok', '2521', 11),
(699, 'Csólyospálos', '6135', 1),
(700, 'Csoma', '7253', 14),
(701, 'Csomád', '2161', 13),
(702, 'Csombárd', '7432', 14),
(703, 'Csömend', '8700', 14),
(704, 'Csömödér', '8957', 19),
(705, 'Csömör', '2141', 13),
(706, 'Csönge', '9513', 17),
(707, 'Csongrád', '6640', 5),
(708, 'Csongrád', '6648', 5),
(709, 'Csonkahegyhát', '8918', 19),
(710, 'Csonkamindszent', '7940', 2),
(711, 'Csopak', '8229', 18),
(712, 'Csór', '8041', 6),
(713, 'Csorna', '9300', 7),
(714, 'Csörnyeföld', '8873', 19),
(715, 'Csörög', '2135', 13),
(716, 'Csörötnek', '9962', 17),
(717, 'Csorvás', '5920', 3),
(718, 'Csősz', '8122', 6),
(719, 'Csót', '8558', 18),
(720, 'Csővár', '2615', 13),
(721, 'Csurgó', '8840', 14),
(722, 'Csurgónagymarton', '8840', 14),
(723, 'Cún', '7843', 2),
(724, 'Dabas', '2370', 13),
(725, 'Dabas', '2371', 13),
(726, 'Dabas', '2373', 13),
(727, 'Dabronc', '8345', 18),
(728, 'Dabrony', '8485', 18),
(729, 'Dad', '2854', 11),
(730, 'Dág', '2522', 11),
(731, 'Dáka', '8592', 18),
(732, 'Dalmand', '7211', 16),
(733, 'Damak', '3780', 4),
(734, 'Dámóc', '3978', 4),
(735, 'Dánszentmiklós', '2735', 13),
(736, 'Dány', '2118', 13),
(737, 'Daraboshegy', '9917', 17),
(738, 'Darány', '7988', 14),
(739, 'Darnó', '4737', 15),
(740, 'Darnózseli', '9232', 7),
(741, 'Daruszentmiklós', '2423', 6),
(742, 'Darvas', '4144', 8),
(743, 'Dávod', '6524', 1),
(744, 'Debercsény', '2694', 12),
(745, 'Debrecen', '4000', 8),
(746, 'Debrecen', '4002', 8),
(747, 'Debrecen', '4024', 8),
(748, 'Debrecen', '4025', 8),
(749, 'Debrecen', '4026', 8),
(750, 'Debrecen', '4027', 8),
(751, 'Debrecen', '4028', 8),
(752, 'Debrecen', '4029', 8),
(753, 'Debrecen', '4030', 8),
(754, 'Debrecen', '4031', 8),
(755, 'Debrecen', '4032', 8),
(756, 'Debrecen', '4033', 8),
(757, 'Debrecen', '4034', 8),
(758, 'Debrecen', '4063', 8),
(759, 'Debrecen', '4078', 8),
(760, 'Debrecen', '4079', 8),
(761, 'Debrecen', '4225', 8),
(762, 'Debréte', '3825', 4),
(763, 'Decs', '7144', 16),
(764, 'Dédestapolcsány', '3643', 4),
(765, 'Dég', '8135', 6),
(766, 'Dejtár', '2649', 12),
(767, 'Délegyháza', '2337', 13),
(768, 'Demecser', '4516', 15),
(769, 'Demjén', '3395', 9),
(770, 'Dencsháza', '7915', 2),
(771, 'Dénesfa', '9365', 7),
(772, 'Derecske', '4130', 8),
(773, 'Derekegyház', '6621', 5),
(774, 'Deszk', '6772', 5),
(775, 'Detek', '3834', 4),
(776, 'Detk', '3275', 9),
(777, 'Dévaványa', '5510', 3),
(778, 'Devecser', '8460', 18),
(779, 'Dinnyeberki', '7683', 2),
(780, 'Diósberény', '7072', 16),
(781, 'Diósd', '2049', 13),
(782, 'Diósjenő', '2643', 12),
(783, 'Dióskál', '8764', 19),
(784, 'Diósviszló', '7817', 2),
(785, 'Doba', '8482', 18),
(786, 'Döbörhegy', '9914', 17),
(787, 'Doboz', '5624', 3),
(788, 'Dobri', '8874', 19),
(789, 'Döbröce', '8357', 19),
(790, 'Döbrököz', '7228', 16),
(791, 'Dobronhegy', '8989', 19),
(792, 'Döbrönte', '8597', 18),
(793, 'Dóc', '6766', 5),
(794, 'Döge', '4495', 15),
(795, 'Domaháza', '3627', 4),
(796, 'Domaszék', '6781', 5),
(797, 'Dombegyház', '5836', 3),
(798, 'Dombiratos', '5745', 3),
(799, 'Dombóvár', '7200', 16),
(800, 'Dombrád', '4492', 15),
(801, 'Domony', '2182', 13),
(802, 'Dömös', '2027', 11),
(803, 'Domoszló', '3263', 9),
(804, 'Dömsöd', '2344', 13),
(805, 'Dör', '9147', 7),
(806, 'Dörgicse', '8244', 18),
(807, 'Dormánd', '3374', 9),
(808, 'Dorog', '2510', 11),
(809, 'Dorogháza', '3153', 12),
(810, 'Döröske', '9913', 17),
(811, 'Dötk', '8799', 19),
(812, 'Dövény', '3721', 4),
(813, 'Dozmat', '9791', 17),
(814, 'Drágszél', '6342', 1),
(815, 'Drávacsehi', '7849', 2),
(816, 'Drávacsepely', '7846', 2),
(817, 'Drávafok', '7967', 2),
(818, 'Drávagárdony', '7977', 14),
(819, 'Drávaiványi', '7960', 2),
(820, 'Drávakeresztúr', '7967', 2),
(821, 'Drávapalkonya', '7850', 2),
(822, 'Drávapiski', '7843', 2),
(823, 'Drávaszabolcs', '7851', 2),
(824, 'Drávaszerdahely', '7847', 2),
(825, 'Drávasztára', '7960', 2),
(826, 'Drávatamási', '7979', 14),
(827, 'Drégelypalánk', '2646', 12),
(828, 'Dubicsány', '3635', 4),
(829, 'Dudar', '8416', 18),
(830, 'Duka', '9556', 17),
(831, 'Dunaalmás', '2545', 11),
(832, 'Dunabogdány', '2023', 13),
(833, 'Dunaegyháza', '6323', 1),
(834, 'Dunafalva', '6513', 1),
(835, 'Dunaföldvár', '7020', 16),
(836, 'Dunaharaszti', '2330', 13),
(837, 'Dunakeszi', '2120', 13),
(838, 'Dunakiliti', '9225', 7),
(839, 'Dunapataj', '6328', 1),
(840, 'Dunaremete', '9235', 7),
(841, 'Dunaszeg', '9174', 7),
(842, 'Dunaszekcső', '7712', 2),
(843, 'Dunaszentbenedek', '6333', 1),
(844, 'Dunaszentgyörgy', '7135', 16),
(845, 'Dunaszentmiklós', '2897', 11),
(846, 'Dunaszentpál', '9175', 7),
(847, 'Dunasziget', '9226', 7),
(848, 'Dunatetétlen', '6325', 1),
(849, 'Dunaújváros', '2400', 6),
(850, 'Dunaújváros', '2407', 6),
(851, 'Dunavarsány', '2336', 13),
(852, 'Dunavecse', '6087', 1),
(853, 'Dusnok', '6353', 1),
(854, 'Dúzs', '7224', 16),
(855, 'Ebergőc', '9451', 7),
(856, 'Ebes', '4211', 8),
(857, 'Écs', '9083', 7),
(858, 'Ecséd', '3013', 9),
(859, 'Ecseg', '3053', 12),
(860, 'Ecsegfalva', '5515', 3),
(861, 'Ecseny', '7457', 14),
(862, 'Ecser', '2233', 13),
(863, 'Edde', '7443', 14),
(864, 'Edelény', '3780', 4),
(865, 'Edelény', '3783', 4),
(866, 'Edve', '9343', 7),
(867, 'Eger', '3300', 9),
(868, 'Eger', '3304', 9),
(869, 'Egerág', '7763', 2),
(870, 'Egeralja', '8497', 18),
(871, 'Egeraracsa', '8765', 19),
(872, 'Egerbakta', '3321', 9),
(873, 'Egerbocs', '3337', 9),
(874, 'Egercsehi', '3341', 9),
(875, 'Egerfarmos', '3379', 9),
(876, 'Egerlövő', '3461', 4),
(877, 'Egerszalók', '3394', 9),
(878, 'Égerszög', '3757', 4),
(879, 'Egerszólát', '3328', 9),
(880, 'Egervár', '8913', 19),
(881, 'Egervölgy', '9684', 17),
(882, 'Egyed', '9314', 7),
(883, 'Egyek', '4067', 8),
(884, 'Egyek', '4069', 8),
(885, 'Egyházasdengeleg', '3043', 12),
(886, 'Egyházasfalu', '9473', 7),
(887, 'Egyházasgerge', '3185', 12),
(888, 'Egyházasharaszti', '7824', 2),
(889, 'Egyházashetye', '9554', 17),
(890, 'Egyházashollós', '9781', 17),
(891, 'Egyházaskesző', '8523', 18),
(892, 'Egyházaskozár', '7347', 2),
(893, 'Egyházasrádóc', '9783', 17),
(894, 'Elek', '5742', 3),
(895, 'Ellend', '7744', 2),
(896, 'Előszállás', '2424', 6),
(897, 'Emőd', '3432', 4),
(898, 'Encs', '3854', 4),
(899, 'Encs', '3860', 4),
(900, 'Encsencs', '4374', 15),
(901, 'Endrefalva', '3165', 12),
(902, 'Endrőc', '7973', 2),
(903, 'Enese', '9143', 7),
(904, 'Enying', '8130', 6),
(905, 'Enying', '8131', 6),
(906, 'Eperjes', '6624', 5),
(907, 'Eperjeske', '4646', 15),
(908, 'Eplény', '8413', 18),
(909, 'Epöl', '2526', 11),
(910, 'Ercsi', '2451', 6),
(911, 'Ercsi', '2453', 6),
(912, 'Érd', '2030', 13),
(913, 'Érd', '2035', 13),
(914, 'Érd', '2036', 13),
(915, 'Erdőbénye', '3932', 4),
(916, 'Erdőhorváti', '3935', 4),
(917, 'Erdőkertes', '2113', 13),
(918, 'Erdőkövesd', '3252', 9),
(919, 'Erdőkürt', '2176', 12),
(920, 'Erdősmárok', '7735', 2),
(921, 'Erdősmecske', '7723', 2),
(922, 'Erdőtarcsa', '2177', 12),
(923, 'Erdőtelek', '3358', 9),
(924, 'Erk', '3295', 9),
(925, 'Érpatak', '4245', 15),
(926, 'Érsekcsanád', '6347', 1),
(927, 'Érsekhalma', '6348', 1),
(928, 'Érsekvadkert', '2659', 12),
(929, 'Értény', '7093', 16),
(930, 'Erzsébet', '7661', 2),
(931, 'Esztár', '4124', 8),
(932, 'Eszteregnye', '8882', 19),
(933, 'Esztergályhorváti', '8742', 19),
(934, 'Esztergom', '2500', 11),
(935, 'Esztergom', '2509', 11),
(936, 'Ete', '2947', 11),
(937, 'Etes', '3136', 12),
(938, 'Etyek', '2091', 6),
(939, 'Fábiánháza', '4354', 15),
(940, 'Fábiánsebestyén', '6625', 5),
(941, 'Fácánkert', '7136', 16),
(942, 'Fadd', '7133', 16),
(943, 'Fadd', '7139', 16),
(944, 'Fáj', '3865', 4),
(945, 'Fajsz', '6352', 1),
(946, 'Fancsal', '3855', 4),
(947, 'Farád', '9321', 7),
(948, 'Farkasgyepű', '8582', 18),
(949, 'Farkaslyuk', '3608', 4),
(950, 'Farmos', '2765', 13),
(951, 'Fazekasboda', '7732', 2),
(952, 'Fedémes', '3255', 9),
(953, 'Fegyvernek', '5213', 10),
(954, 'Fegyvernek', '5231', 10),
(955, 'Fehérgyarmat', '4900', 15),
(956, 'Fehértó', '9163', 7),
(957, 'Fehérvárcsurgó', '8052', 6),
(958, 'Feked', '7724', 2),
(959, 'Feketeerdő', '9211', 7),
(960, 'Felcsút', '8086', 6),
(961, 'Feldebrő', '3352', 9),
(962, 'Felgyő', '6645', 5),
(963, 'Felpéc', '9122', 7),
(964, 'Felsőberecki', '3985', 4),
(965, 'Felsőcsatár', '9794', 17),
(966, 'Felsődobsza', '3847', 4),
(967, 'Felsőegerszeg', '7370', 2),
(968, 'Felsőgagy', '3837', 4),
(969, 'Felsőjánosfa', '9934', 17),
(970, 'Felsőkelecsény', '3722', 4),
(971, 'Felsőlajos', '6055', 1),
(972, 'Felsőmarác', '9918', 17),
(973, 'Felsőmocsolád', '7456', 14),
(974, 'Felsőnána', '7175', 16),
(975, 'Felsőnyárád', '3721', 4),
(976, 'Felsőnyék', '7099', 16),
(977, 'Felsőörs', '8227', 18),
(978, 'Felsőpáhok', '8380', 19),
(979, 'Felsőpakony', '2363', 13),
(980, 'Felsőpetény', '2611', 12),
(981, 'Felsőrajk', '8767', 19),
(982, 'Felsőregmec', '3989', 4),
(983, 'Felsőszenterzsébet', '8973', 19),
(984, 'Felsőszentiván', '6447', 1),
(985, 'Felsőszentmárton', '7968', 2),
(986, 'Felsőszölnök', '9985', 17),
(987, 'Felsőtárkány', '3324', 9),
(988, 'Felsőtelekes', '3735', 4),
(989, 'Felsőtold', '3067', 12),
(990, 'Felsővadász', '3814', 4),
(991, 'Felsőzsolca', '3561', 4),
(992, 'Fényeslitke', '4621', 15),
(993, 'Fenyőfő', '8432', 7),
(994, 'Ferencszállás', '6774', 5),
(995, 'Fertőboz', '9493', 7),
(996, 'Fertőd', '9431', 7),
(997, 'Fertőd', '9433', 7),
(998, 'Fertőendréd', '9442', 7),
(999, 'Fertőhomok', '9492', 7),
(1000, 'Fertőrákos', '9421', 7),
(1001, 'Fertőszentmiklós', '9444', 7),
(1002, 'Fertőszéplak', '9436', 7),
(1003, 'Fiad', '7282', 14),
(1004, 'Filkeháza', '3994', 4),
(1005, 'Fityeház', '8835', 19),
(1006, 'Foktő', '6331', 1),
(1007, 'Földeák', '6922', 5),
(1008, 'Földes', '4177', 8),
(1009, 'Folyás', '4090', 8),
(1010, 'Fonó', '7271', 14),
(1011, 'Fony', '3893', 4),
(1012, 'Főnyed', '8732', 14),
(1013, 'Fonyód', '8640', 14),
(1014, 'Fonyód', '8644', 14),
(1015, 'Forráskút', '6793', 5),
(1016, 'Forró', '3849', 4),
(1017, 'Fót', '2151', 13),
(1018, 'Füle', '8157', 6),
(1019, 'Fülesd', '4964', 15),
(1020, 'Fulókércs', '3864', 4),
(1021, 'Fülöp', '4266', 8),
(1022, 'Fülöpháza', '6042', 1),
(1023, 'Fülöpjakab', '6116', 1),
(1024, 'Fülöpszállás', '6085', 1),
(1025, 'Fülpösdaróc', '4754', 15),
(1026, 'Fürged', '7087', 16),
(1027, 'Furta', '4141', 8),
(1028, 'Füzér', '3996', 4),
(1029, 'Füzérkajata', '3994', 4),
(1030, 'Füzérkomlós', '3997', 4),
(1031, 'Füzérradvány', '3993', 4),
(1032, 'Füzesabony', '3390', 9),
(1033, 'Füzesgyarmat', '5525', 3),
(1034, 'Füzvölgy', '8777', 19),
(1035, 'Gáborján', '4122', 8),
(1036, 'Gáborjánháza', '8969', 19),
(1037, 'Gacsály', '4972', 15),
(1038, 'Gadács', '7276', 14),
(1039, 'Gadány', '8716', 14),
(1040, 'Gadna', '3815', 4),
(1041, 'Gádoros', '5932', 3),
(1042, 'Gagyapáti', '3837', 4),
(1043, 'Gagybátor', '3817', 4),
(1044, 'Gagyvendégi', '3816', 4),
(1045, 'Galambok', '8754', 19),
(1046, 'Galgaguta', '2686', 12),
(1047, 'Galgagyörk', '2681', 13),
(1048, 'Galgahévíz', '2193', 13),
(1049, 'Galgamácsa', '2183', 13),
(1050, 'Gálosfa', '7473', 14),
(1051, 'Galvács', '3752', 4),
(1052, 'Gamás', '8685', 14),
(1053, 'Ganna', '8597', 18),
(1054, 'Gánt', '8082', 6),
(1055, 'Gara', '6522', 1),
(1056, 'Garáb', '3067', 12),
(1057, 'Garabonc', '8747', 19),
(1058, 'Garadna', '3873', 4),
(1059, 'Garbolc', '4976', 15),
(1060, 'Gárdony', '2483', 6),
(1061, 'Gárdony', '2484', 6),
(1062, 'Gárdony', '2485', 6),
(1063, 'Garé', '7812', 2),
(1064, 'Gasztony', '9952', 17),
(1065, 'Gátér', '6111', 1),
(1066, 'Gávavencsellő', '4471', 15),
(1067, 'Gávavencsellő', '4472', 15),
(1068, 'Géberjén', '4754', 15),
(1069, 'Gecse', '8543', 18),
(1070, 'Géderlak', '6334', 1),
(1071, 'Gégény', '4517', 15),
(1072, 'Gelej', '3444', 4),
(1073, 'Gelénes', '4935', 15),
(1074, 'Gellénháza', '8981', 19),
(1075, 'Gelse', '8774', 19),
(1076, 'Gelsesziget', '8774', 19),
(1077, 'Gemzse', '4567', 15),
(1078, 'Gencsapáti', '9721', 17),
(1079, 'Gérce', '9672', 17),
(1080, 'Gerde', '7951', 2),
(1081, 'Gerendás', '5925', 3),
(1082, 'Gerényes', '7362', 2),
(1083, 'Geresdlak', '7733', 2),
(1084, 'Gerjen', '7134', 16),
(1085, 'Gersekarát', '9813', 17),
(1086, 'Geszt', '5734', 3),
(1087, 'Gesztely', '3715', 4),
(1088, 'Gesztely', '3923', 4),
(1089, 'Geszteréd', '4232', 15),
(1090, 'Gétye', '8762', 19),
(1091, 'Gic', '8435', 18),
(1092, 'Gige', '7527', 14),
(1093, 'Gilvánfa', '7954', 2),
(1094, 'Girincs', '3578', 4),
(1095, 'Göd', '2131', 13),
(1096, 'Göd', '2132', 13),
(1097, 'Gödöllő', '2100', 13),
(1098, 'Gödre', '7385', 2),
(1099, 'Gödre', '7386', 2),
(1100, 'Gógánfa', '8346', 18),
(1101, 'Gölle', '7272', 14),
(1102, 'Golop', '3906', 4),
(1103, 'Gomba', '2217', 13),
(1104, 'Gombosszeg', '8984', 19),
(1105, 'Gömörszőlős', '3728', 4),
(1106, 'Gönc', '3895', 4),
(1107, 'Göncruszka', '3894', 4),
(1108, 'Gönyű', '9071', 7),
(1109, 'Gór', '9625', 17),
(1110, 'Görbeháza', '4075', 8),
(1111, 'Görcsöny', '7833', 2),
(1112, 'Görcsönydoboka', '7728', 2),
(1113, 'Gordisa', '7853', 2),
(1114, 'Görgeteg', '7553', 14),
(1115, 'Gősfa', '8913', 19),
(1116, 'Gosztola', '8978', 19),
(1117, 'Grábóc', '7162', 16),
(1118, 'Gulács', '4842', 15),
(1119, 'Gutorfölde', '8951', 19),
(1120, 'Gyál', '2360', 13),
(1121, 'Gyalóka', '9474', 7),
(1122, 'Gyanógeregye', '9774', 17),
(1123, 'Gyarmat', '9126', 7),
(1124, 'Gyékényes', '8851', 14),
(1125, 'Gyenesdiás', '8315', 19),
(1126, 'Gyepükaján', '8473', 18),
(1127, 'Gyermely', '2821', 11),
(1128, 'Gyód', '7668', 2),
(1129, 'Gyomaendrőd', '5500', 3),
(1130, 'Gyomaendrőd', '5502', 3),
(1131, 'Gyömöre', '9124', 7),
(1132, 'Gyömrő', '2230', 13),
(1133, 'Gyöngyfa', '7954', 2),
(1134, 'Gyöngyös', '3200', 9),
(1135, 'Gyöngyös', '3221', 9),
(1136, 'Gyöngyös', '3232', 9),
(1137, 'Gyöngyös', '3233', 9),
(1138, 'Gyöngyösfalu', '9723', 17),
(1139, 'Gyöngyöshalász', '3212', 9),
(1140, 'Gyöngyösmellék', '7972', 2),
(1141, 'Gyöngyösoroszi', '3211', 9),
(1142, 'Gyöngyöspata', '3035', 9),
(1143, 'Gyöngyössolymos', '3231', 9),
(1144, 'Gyöngyöstarján', '3036', 9),
(1145, 'Gyönk', '7064', 16),
(1146, 'Győr', '9000', 7),
(1147, 'Győr', '9011', 7),
(1148, 'Győr', '9012', 7),
(1149, 'Győr', '9019', 7),
(1150, 'Győr', '9021', 7),
(1151, 'Győr', '9022', 7),
(1152, 'Győr', '9023', 7),
(1153, 'Győr', '9024', 7),
(1154, 'Győr', '9025', 7),
(1155, 'Győr', '9026', 7),
(1156, 'Győr', '9027', 7),
(1157, 'Győr', '9028', 7),
(1158, 'Győr', '9029', 7),
(1159, 'Győr', '9030', 7),
(1160, 'Győrasszonyfa', '9093', 7),
(1161, 'Györe', '7352', 16),
(1162, 'Györgytarló', '3954', 4),
(1163, 'Györköny', '7045', 16),
(1164, 'Győrladamér', '9173', 7),
(1165, 'Gyóró', '9363', 7),
(1166, 'Győröcske', '4625', 15),
(1167, 'Győrság', '9084', 7),
(1168, 'Győrsövényház', '9161', 7),
(1169, 'Győrszemere', '9121', 7),
(1170, 'Győrtelek', '4752', 15),
(1171, 'Győrújbarát', '9081', 7),
(1172, 'Győrújfalu', '9171', 7),
(1173, 'Győrvár', '9821', 17),
(1174, 'Győrzámoly', '9172', 7),
(1175, 'Gyugy', '8692', 14),
(1176, 'Gyügye', '4733', 15),
(1177, 'Gyula', '5700', 3),
(1178, 'Gyula', '5703', 3),
(1179, 'Gyula', '5711', 3),
(1180, 'Gyulaháza', '4545', 15),
(1181, 'Gyulaj', '7227', 16),
(1182, 'Gyulakeszi', '8286', 18),
(1183, 'Gyüre', '4813', 15),
(1184, 'Gyúró', '2464', 6),
(1185, 'Gyűrűs', '8932', 19),
(1186, 'Hács', '8694', 14),
(1187, 'Hagyárosbörönd', '8992', 19),
(1188, 'Hahót', '8771', 19),
(1189, 'Hajdúbagos', '4273', 8),
(1190, 'Hajdúböszörmény', '4074', 8),
(1191, 'Hajdúböszörmény', '4086', 8),
(1192, 'Hajdúböszörmény', '4220', 8),
(1193, 'Hajdúböszörmény', '4224', 8),
(1194, 'Hajdúdorog', '4087', 8),
(1195, 'Hajdúhadház', '4242', 8),
(1196, 'Hajdúnánás', '4080', 8),
(1197, 'Hajdúnánás', '4085', 8),
(1198, 'Hajdúsámson', '4251', 8),
(1199, 'Hajdúszoboszló', '4200', 8),
(1200, 'Hajdúszovát', '4212', 8),
(1201, 'Hajmás', '7473', 14),
(1202, 'Hajmáskér', '8192', 18),
(1203, 'Hajós', '6344', 1),
(1204, 'Halastó', '9814', 17),
(1205, 'Halászi', '9228', 7),
(1206, 'Halásztelek', '2314', 13),
(1207, 'Halimba', '8452', 18),
(1208, 'Halmaj', '3842', 4),
(1209, 'Halmajugra', '3273', 9),
(1210, 'Halogy', '9917', 17),
(1211, 'Hangács', '3795', 4),
(1212, 'Hangony', '3626', 4),
(1213, 'Hantos', '2434', 6),
(1214, 'Harasztifalu', '9784', 17),
(1215, 'Harc', '7172', 16),
(1216, 'Harka', '9422', 7),
(1217, 'Harkakötöny', '6136', 1),
(1218, 'Harkány', '7815', 2),
(1219, 'Háromfa', '7585', 14),
(1220, 'Háromhuta', '3936', 4),
(1221, 'Harsány', '3555', 4),
(1222, 'Hárskút', '8442', 18),
(1223, 'Harta', '6326', 1),
(1224, 'Harta', '6327', 1),
(1225, 'Hásságy', '7745', 2),
(1226, 'Hatvan', '3000', 9),
(1227, 'Hédervár', '9178', 7),
(1228, 'Hedrehely', '7533', 14),
(1229, 'Hegyesd', '8296', 18),
(1230, 'Hegyeshalom', '9222', 7),
(1231, 'Hegyfalu', '9631', 17),
(1232, 'Hegyháthodász', '9915', 17),
(1233, 'Hegyhátmaróc', '7348', 2),
(1234, 'Hegyhátsál', '9915', 17),
(1235, 'Hegyhátszentjakab', '9934', 17),
(1236, 'Hegyhátszentmárton', '9931', 17),
(1237, 'Hegyhátszentpéter', '9826', 17),
(1238, 'Hegykő', '9437', 7),
(1239, 'Hegymagas', '8265', 18),
(1240, 'Hegymeg', '3786', 4),
(1241, 'Hegyszentmárton', '7837', 2),
(1242, 'Héhalom', '3041', 12),
(1243, 'Hejce', '3892', 4),
(1244, 'Hejőbába', '3593', 4),
(1245, 'Hejőkeresztúr', '3597', 4),
(1246, 'Hejőkürt', '3588', 4),
(1247, 'Hejőpapi', '3594', 4),
(1248, 'Hejőszalonta', '3595', 4),
(1249, 'Helesfa', '7683', 2),
(1250, 'Helvécia', '6034', 1),
(1251, 'Hencida', '4123', 8),
(1252, 'Hencse', '7532', 14),
(1253, 'Herceghalom', '2053', 13),
(1254, 'Hercegkút', '3958', 4),
(1255, 'Hercegszántó', '6525', 1),
(1256, 'Heréd', '3011', 9),
(1257, 'Héreg', '2832', 11),
(1258, 'Herencsény', '2677', 12),
(1259, 'Herend', '8440', 18),
(1260, 'Heresznye', '7587', 14),
(1261, 'Hermánszeg', '4735', 15),
(1262, 'Hernád', '2376', 13),
(1263, 'Hernádbűd', '3853', 4),
(1264, 'Hernádcéce', '3887', 4),
(1265, 'Hernádkak', '3563', 4),
(1266, 'Hernádkércs', '3846', 4),
(1267, 'Hernádnémeti', '3564', 4),
(1268, 'Hernádpetri', '3874', 4),
(1269, 'Hernádszentandrás', '3852', 4),
(1270, 'Hernádszurdok', '3875', 4),
(1271, 'Hernádvécse', '3874', 4),
(1272, 'Hernyék', '8957', 19),
(1273, 'Hét', '3655', 4),
(1274, 'Hetefejércse', '4843', 15),
(1275, 'Hetes', '7432', 14),
(1276, 'Hetvehely', '7681', 2),
(1277, 'Hetyefő', '8344', 18),
(1278, 'Heves', '3360', 9),
(1279, 'Hevesaranyos', '3322', 9),
(1280, 'Hevesvezekény', '3383', 9),
(1281, 'Hévíz', '8380', 19),
(1282, 'Hévízgyörk', '2192', 13),
(1283, 'Hidas', '7696', 2),
(1284, 'Hidasnémeti', '3876', 4),
(1285, 'Hidegkút', '8247', 18),
(1286, 'Hidegség', '9491', 7),
(1287, 'Hidvégardó', '3768', 4),
(1288, 'Himesháza', '7735', 2),
(1289, 'Himod', '9362', 7),
(1290, 'Hirics', '7838', 2),
(1291, 'Hobol', '7971', 2),
(1292, 'Hodász', '4334', 15),
(1293, 'Hódmezővásárhely', '6800', 5),
(1294, 'Hódmezővásárhely', '6806', 5),
(1295, 'Hőgyész', '7191', 16),
(1296, 'Hollád', '8731', 14),
(1297, 'Hollóháza', '3999', 4),
(1298, 'Hollókő', '3176', 12),
(1299, 'Homokbödöge', '8563', 18),
(1300, 'Homokkomárom', '8777', 19),
(1301, 'Homokmégy', '6341', 1),
(1302, 'Homokszentgyörgy', '7537', 14),
(1303, 'Homorúd', '7716', 2),
(1304, 'Homrogd', '3812', 4),
(1305, 'Hont', '2647', 12),
(1306, 'Horpács', '2658', 12),
(1307, 'Hort', '3014', 9),
(1308, 'Hortobágy', '4071', 8),
(1309, 'Horváthertelend', '7935', 2),
(1310, 'Horvátlövő', '9796', 17),
(1311, 'Horvátzsidány', '9733', 17),
(1312, 'Hosszúhetény', '7694', 2),
(1313, 'Hosszúpályi', '4274', 8),
(1314, 'Hosszúpereszteg', '9676', 17),
(1315, 'Hosszúvíz', '8716', 14),
(1316, 'Hosszúvölgy', '8777', 19),
(1317, 'Hosztót', '8475', 18),
(1318, 'Hottó', '8991', 19),
(1319, 'Hövej', '9361', 7),
(1320, 'Hugyag', '2672', 12),
(1321, 'Hunya', '5555', 3),
(1322, 'Hunyadfalva', '5063', 10),
(1323, 'Husztót', '7678', 2),
(1324, 'Ibafa', '7935', 2),
(1325, 'Iborfia', '8984', 19),
(1326, 'Ibrány', '4484', 15),
(1327, 'Igal', '7275', 14),
(1328, 'Igar', '7015', 6),
(1329, 'Igar', '7016', 6),
(1330, 'Igrici', '3459', 4),
(1331, 'Iharos', '8726', 14),
(1332, 'Iharosberény', '8725', 14),
(1333, 'Ikervár', '9756', 17),
(1334, 'Iklad', '2181', 13),
(1335, 'Iklanberény', '9634', 17),
(1336, 'Iklódbördőce', '8958', 19),
(1337, 'Ikrény', '9141', 7),
(1338, 'Iliny', '2675', 12),
(1339, 'Ilk', '4566', 15),
(1340, 'Illocska', '7775', 2),
(1341, 'Imola', '3724', 4),
(1342, 'Imrehegy', '6238', 1),
(1343, 'Ináncs', '3851', 4),
(1344, 'Inárcs', '2365', 13),
(1345, 'Inke', '8724', 14),
(1346, 'Ipacsfa', '7847', 2),
(1347, 'Ipolydamásd', '2631', 13),
(1348, 'Ipolytarnóc', '3138', 12),
(1349, 'Ipolytölgyes', '2633', 13),
(1350, 'Ipolyvece', '2669', 12),
(1351, 'Iregszemcse', '7095', 16),
(1352, 'Irota', '3786', 4),
(1353, 'Isaszeg', '2117', 13),
(1354, 'Ispánk', '9941', 17),
(1355, 'Istenmezeje', '3253', 9),
(1356, 'Istvándi', '7987', 14),
(1357, 'Iszkaszentgyörgy', '8043', 6),
(1358, 'Iszkáz', '8493', 18),
(1359, 'Isztimér', '8045', 6),
(1360, 'Ivád', '3248', 9),
(1361, 'Iván', '9374', 7),
(1362, 'Ivánbattyán', '7772', 2),
(1363, 'Ivánc', '9931', 17),
(1364, 'Iváncsa', '2454', 6),
(1365, 'Ivándárda', '7781', 2),
(1366, 'Izmény', '7353', 16),
(1367, 'Izsák', '6070', 1),
(1368, 'Izsófalva', '3741', 4),
(1369, 'Jágónak', '7362', 16),
(1370, 'Ják', '9798', 17),
(1371, 'Jakabszállás', '6078', 1),
(1372, 'Jákfa', '9643', 17),
(1373, 'Jákfalva', '3721', 4),
(1374, 'Jákó', '7525', 14),
(1375, 'Jánd', '4841', 15),
(1376, 'Jánkmajtis', '4741', 15),
(1377, 'Jánoshalma', '6440', 1),
(1378, 'Jánosháza', '9545', 17),
(1379, 'Jánoshida', '5143', 10),
(1380, 'Jánossomorja', '9241', 7),
(1381, 'Jánossomorja', '9242', 7),
(1382, 'Járdánháza', '3664', 4),
(1383, 'Jármi', '4337', 15),
(1384, 'Jásd', '8424', 18),
(1385, 'Jászágó', '5124', 10),
(1386, 'Jászalsószentgyörgy', '5054', 10),
(1387, 'Jászapáti', '5130', 10),
(1388, 'Jászárokszállás', '5123', 10),
(1389, 'Jászberény', '5100', 10),
(1390, 'Jászberény', '5152', 10),
(1391, 'Jászboldogháza', '5144', 10),
(1392, 'Jászdózsa', '5122', 10),
(1393, 'Jászfelsőszentgyörgy', '5111', 10),
(1394, 'Jászfényszaru', '5126', 10),
(1395, 'Jászivány', '5135', 10),
(1396, 'Jászjákóhalma', '5121', 10),
(1397, 'Jászkarajenő', '2746', 13),
(1398, 'Jászkisér', '5137', 10),
(1399, 'Jászladány', '5055', 10),
(1400, 'Jászszentandrás', '5136', 10),
(1401, 'Jászszentlászló', '6133', 1),
(1402, 'Jásztelek', '5141', 10),
(1403, 'Jéke', '4611', 15),
(1404, 'Jenő', '8146', 6),
(1405, 'Jobaháza', '9323', 7),
(1406, 'Jobbágyi', '3063', 12),
(1407, 'Jósvafő', '3758', 4),
(1408, 'Juta', '7431', 14),
(1409, 'Kaba', '4183', 8),
(1410, 'Kacorlak', '8773', 19),
(1411, 'Kács', '3424', 4),
(1412, 'Kacsóta', '7940', 2),
(1413, 'Kadarkút', '7530', 14),
(1414, 'Kajárpéc', '9123', 7),
(1415, 'Kajászó', '2472', 6),
(1416, 'Kajdacs', '7051', 16),
(1417, 'Kakasd', '7122', 16),
(1418, 'Kákics', '7958', 2),
(1419, 'Kakucs', '2366', 13),
(1420, 'Kál', '3350', 9),
(1421, 'Kalaznó', '7194', 16),
(1422, 'Káld', '9673', 17),
(1423, 'Kálló', '2175', 12),
(1424, 'Kallósd', '8785', 19),
(1425, 'Kállósemjén', '4324', 15),
(1426, 'Kálmáncsa', '7538', 14),
(1427, 'Kálmánháza', '4434', 15),
(1428, 'Kálócfa', '8988', 19),
(1429, 'Kalocsa', '6300', 1),
(1430, 'Káloz', '8124', 6),
(1431, 'Kám', '9841', 17),
(1432, 'Kamond', '8469', 18),
(1433, 'Kamut', '5673', 3),
(1434, 'Kánó', '3735', 4),
(1435, 'Kántorjánosi', '4335', 15),
(1436, 'Kány', '3821', 4),
(1437, 'Kánya', '8667', 14),
(1438, 'Kányavár', '8956', 19),
(1439, 'Kapolcs', '8294', 18),
(1440, 'Kápolna', '3355', 9),
(1441, 'Kápolnásnyék', '2475', 6),
(1442, 'Kapoly', '8671', 14),
(1443, 'Kaposfő', '7523', 14),
(1444, 'Kaposgyarmat', '7473', 14),
(1445, 'Kaposhomok', '7261', 14),
(1446, 'Kaposkeresztúr', '7258', 14),
(1447, 'Kaposmérő', '7521', 14),
(1448, 'Kapospula', '7251', 16),
(1449, 'Kaposszekcső', '7361', 16),
(1450, 'Kaposszerdahely', '7476', 14),
(1451, 'Kaposújlak', '7522', 14),
(1452, 'Kaposvár', '7400', 14),
(1453, 'Káptalanfa', '8471', 18),
(1454, 'Káptalantóti', '8283', 18),
(1455, 'Kapuvár', '9330', 7),
(1456, 'Kapuvár', '9339', 7),
(1457, 'Kára', '7285', 14),
(1458, 'Karácsond', '3281', 9),
(1459, 'Karád', '8676', 14),
(1460, 'Karakó', '9547', 17),
(1461, 'Karakószörcsök', '8491', 18),
(1462, 'Karancsalja', '3181', 12),
(1463, 'Karancsberény', '3137', 12),
(1464, 'Karancskeszi', '3183', 12),
(1465, 'Karancslapujtő', '3182', 12),
(1466, 'Karancsság', '3163', 12),
(1467, 'Kárász', '7333', 2),
(1468, 'Karcag', '5300', 10),
(1469, 'Karcsa', '3963', 4),
(1470, 'Kardos', '5552', 3),
(1471, 'Kardoskút', '5945', 3),
(1472, 'Karmacs', '8354', 19),
(1473, 'Károlyháza', '9182', 7),
(1474, 'Karos', '3962', 4),
(1475, 'Kartal', '2173', 13),
(1476, 'Kásád', '7827', 2),
(1477, 'Kaskantyú', '6211', 1),
(1478, 'Kastélyosdombó', '7977', 14),
(1479, 'Kaszaper', '5948', 3),
(1480, 'Kaszó', '7564', 14),
(1481, 'Katádfa', '7914', 2),
(1482, 'Katafa', '9915', 17),
(1483, 'Kátoly', '7661', 2),
(1484, 'Katymár', '6455', 1),
(1485, 'Káva', '2215', 13),
(1486, 'Kávás', '8994', 19),
(1487, 'Kazár', '3127', 12),
(1488, 'Kazár', '3147', 12),
(1489, 'Kazincbarcika', '3700', 4),
(1490, 'Kázsmárk', '3831', 4),
(1491, 'Kazsok', '7274', 14),
(1492, 'Kecel', '6237', 1),
(1493, 'Kecskéd', '2852', 11),
(1494, 'Kecskemét', '6000', 1),
(1495, 'Kecskemét', '6008', 1),
(1496, 'Kecskemét', '6044', 1),
(1497, 'Kehidakustány', '8784', 19),
(1498, 'Kék', '4515', 15),
(1499, 'Kékcse', '4494', 15),
(1500, 'Kéked', '3899', 4),
(1501, 'Kékesd', '7661', 2),
(1502, 'Kékkút', '8254', 18),
(1503, 'Kelebia', '6423', 1),
(1504, 'Keléd', '9549', 17),
(1505, 'Kelemér', '3728', 4),
(1506, 'Kéleshalom', '6444', 1),
(1507, 'Kelevíz', '8714', 14),
(1508, 'Kemecse', '4501', 15),
(1509, 'Kemence', '2638', 13),
(1510, 'Kemendollár', '8931', 19),
(1511, 'Kemeneshőgyész', '8516', 18),
(1512, 'Kemeneskápolna', '9553', 17),
(1513, 'Kemenesmagasi', '9522', 17),
(1514, 'Kemenesmihályfa', '9511', 17),
(1515, 'Kemenespálfa', '9544', 17),
(1516, 'Kemenessömjén', '9517', 17),
(1517, 'Kemenesszentmárton', '9521', 17),
(1518, 'Kemenesszentpéter', '8518', 18),
(1519, 'Keménfa', '8995', 19),
(1520, 'Kémes', '7843', 2),
(1521, 'Kemestaródfa', '9923', 17),
(1522, 'Kemse', '7839', 2),
(1523, 'Kenderes', '5331', 10),
(1524, 'Kenderes', '5349', 10),
(1525, 'Kenéz', '9752', 17),
(1526, 'Kenézlő', '3955', 4),
(1527, 'Kengyel', '5083', 10),
(1528, 'Kenyeri', '9514', 17),
(1529, 'Kercaszomor', '9945', 17),
(1530, 'Kercseliget', '7256', 14),
(1531, 'Kerecsend', '3396', 9),
(1532, 'Kerecseny', '8745', 19),
(1533, 'Kerekegyháza', '6041', 1),
(1534, 'Kereki', '8618', 14),
(1535, 'Kerékteleki', '2882', 11),
(1536, 'Kerepes', '2144', 13),
(1537, 'Kerepes', '2145', 13),
(1538, 'Keresztéte', '3821', 4),
(1539, 'Kerkabarabás', '8971', 19),
(1540, 'Kerkafalva', '8973', 19),
(1541, 'Kerkakutas', '8973', 19),
(1542, 'Kerkáskápolna', '9944', 17),
(1543, 'Kerkaszentkirály', '8874', 19),
(1544, 'Kerkateskánd', '8879', 19),
(1545, 'Kérsemjén', '4912', 15),
(1546, 'Kerta', '8492', 18),
(1547, 'Kertészsziget', '5526', 3),
(1548, 'Keszeg', '2616', 12),
(1549, 'Kesznyéten', '3579', 4),
(1550, 'Keszőhidegkút', '7062', 16),
(1551, 'Keszthely', '8360', 19),
(1552, 'Kesztölc', '2517', 11),
(1553, 'Keszü', '7668', 2),
(1554, 'Kétbodony', '2655', 12),
(1555, 'Kétegyháza', '5741', 3),
(1556, 'Kéthely', '8713', 14),
(1557, 'Kétpó', '5411', 10),
(1558, 'Kétsoprony', '5674', 3),
(1559, 'Kétújfalu', '7975', 2),
(1560, 'Kétvölgy', '9982', 17),
(1561, 'Kéty', '7174', 16),
(1562, 'Kevermes', '5744', 3),
(1563, 'Kilimán', '8774', 19),
(1564, 'Kimle', '9181', 7),
(1565, 'Kincsesbánya', '8044', 6),
(1566, 'Királd', '3657', 4),
(1567, 'Királyegyháza', '7953', 2),
(1568, 'Királyhegyes', '6911', 5),
(1569, 'Királyszentistván', '8195', 18),
(1570, 'Kisapáti', '8284', 18),
(1571, 'Kisapostag', '2428', 6),
(1572, 'Kisar', '4921', 15),
(1573, 'Kisasszond', '7523', 14),
(1574, 'Kisasszonyfa', '7954', 2),
(1575, 'Kisbabot', '9133', 7),
(1576, 'Kisbágyon', '3046', 12),
(1577, 'Kisbajcs', '9062', 7),
(1578, 'Kisbajom', '7542', 14),
(1579, 'Kisbárapáti', '7282', 14),
(1580, 'Kisbárkány', '3075', 12),
(1581, 'Kisbér', '2870', 11),
(1582, 'Kisbér', '2879', 11),
(1583, 'Kisberény', '8693', 14),
(1584, 'Kisberzseny', '8477', 18),
(1585, 'Kisbeszterce', '7391', 2),
(1586, 'Kisbodak', '9234', 7),
(1587, 'Kisbucsa', '8925', 19),
(1588, 'Kisbudmér', '7756', 2),
(1589, 'Kiscsécs', '3578', 4),
(1590, 'Kiscsehi', '8888', 19),
(1591, 'Kiscsősz', '8494', 18),
(1592, 'Kisdér', '7814', 2),
(1593, 'Kisdobsza', '7985', 2),
(1594, 'Kisdombegyház', '5837', 3),
(1595, 'Kisdorog', '7159', 16),
(1596, 'Kisecset', '2655', 12),
(1597, 'Kisfalud', '9341', 7),
(1598, 'Kisfüzes', '3256', 9),
(1599, 'Kisgörbő', '8356', 19),
(1600, 'Kisgyalán', '7279', 14),
(1601, 'Kisgyőr', '3556', 4),
(1602, 'Kishajmás', '7391', 2),
(1603, 'Kisharsány', '7800', 2),
(1604, 'Kishartyán', '3161', 12),
(1605, 'Kisherend', '7763', 2),
(1606, 'Kishódos', '4977', 15),
(1607, 'Kishuta', '3994', 4),
(1608, 'Kisigmánd', '2948', 11),
(1609, 'Kisjakabfalva', '7773', 2),
(1610, 'Kiskassa', '7766', 2),
(1611, 'Kiskinizs', '3843', 4),
(1612, 'Kisköre', '3384', 9),
(1613, 'Kiskőrös', '6200', 1),
(1614, 'Kiskorpád', '7524', 14),
(1615, 'Kiskunfélegyháza', '6100', 1),
(1616, 'Kiskunhalas', '6400', 1),
(1617, 'Kiskunlacháza', '2340', 13),
(1618, 'Kiskunmajsa', '6120', 1),
(1619, 'Kiskutas', '8911', 19),
(1620, 'Kisláng', '8156', 6),
(1621, 'Kisléta', '4325', 15),
(1622, 'Kislippó', '7775', 2),
(1623, 'Kislőd', '8446', 18),
(1624, 'Kismányok', '7356', 16),
(1625, 'Kismarja', '4126', 8),
(1626, 'Kismaros', '2623', 13),
(1627, 'Kisnamény', '4737', 15),
(1628, 'Kisnána', '3264', 9),
(1629, 'Kisnémedi', '2165', 13),
(1630, 'Kisnyárád', '7759', 2),
(1631, 'Kisoroszi', '2024', 13),
(1632, 'Kispalád', '4956', 15),
(1633, 'Kispáli', '8912', 19),
(1634, 'Kispirit', '8496', 18),
(1635, 'Kisrákos', '9936', 17),
(1636, 'Kisrécse', '8756', 19),
(1637, 'Kisrozvágy', '3965', 4),
(1638, 'Kissikátor', '3627', 4),
(1639, 'Kissomlyó', '9555', 17),
(1640, 'Kisszállás', '6421', 1),
(1641, 'Kisszékely', '7082', 16),
(1642, 'Kisszekeres', '4963', 15),
(1643, 'Kisszentmárton', '7841', 2),
(1644, 'Kissziget', '8957', 19),
(1645, 'Kisszőlős', '8483', 18),
(1646, 'Kistamási', '7981', 2),
(1647, 'Kistapolca', '7823', 2),
(1648, 'Kistarcsa', '2143', 13),
(1649, 'Kistelek', '6760', 5),
(1650, 'Kistokaj', '3553', 4),
(1651, 'Kistolmács', '8868', 19),
(1652, 'Kistormás', '7068', 16),
(1653, 'Kistótfalu', '7768', 2),
(1654, 'Kisújszállás', '5310', 10),
(1655, 'Kisunyom', '9772', 17),
(1656, 'Kisvárda', '4600', 15),
(1657, 'Kisvarsány', '4811', 15),
(1658, 'Kisvásárhely', '8341', 19),
(1659, 'Kisvaszar', '7381', 2),
(1660, 'Kisvejke', '7183', 16),
(1661, 'Kiszombor', '6775', 5),
(1662, 'Kiszsidány', '9733', 17),
(1663, 'Klárafalva', '6773', 5),
(1664, 'Köblény', '7334', 2),
(1665, 'Kocs', '2898', 11),
(1666, 'Kocsér', '2755', 13),
(1667, 'Köcsk', '9553', 17),
(1668, 'Kocsola', '7212', 16),
(1669, 'Kocsord', '4751', 15),
(1670, 'Kóka', '2243', 13),
(1671, 'Kokad', '4284', 8),
(1672, 'Kökény', '7668', 2),
(1673, 'Kőkút', '7530', 14),
(1674, 'Kölcse', '4965', 15),
(1675, 'Kölesd', '7052', 16),
(1676, 'Kölked', '7717', 2),
(1677, 'Kolontár', '8468', 18),
(1678, 'Komádi', '4138', 8),
(1679, 'Komárom', '2900', 11),
(1680, 'Komárom', '2903', 11),
(1681, 'Komárom', '2921', 11),
(1682, 'Komjáti', '3765', 4),
(1683, 'Komló', '7300', 2),
(1684, 'Komló', '7305', 2),
(1685, 'Kömlő', '3372', 9),
(1686, 'Kömlőd', '2853', 11),
(1687, 'Komlódtótfalu', '4765', 15),
(1688, 'Komlósd', '7582', 14),
(1689, 'Komlóska', '3937', 4),
(1690, 'Komoró', '4622', 15),
(1691, 'Kömörő', '4943', 15),
(1692, 'Kömpöc', '6134', 1),
(1693, 'Kompolt', '3356', 9),
(1694, 'Kondó', '3775', 4),
(1695, 'Kondorfa', '9943', 17),
(1696, 'Kondoros', '5553', 3),
(1697, 'Kóny', '9144', 7),
(1698, 'Konyár', '4133', 8),
(1699, 'Kópháza', '9495', 7),
(1700, 'Koppányszántó', '7094', 16),
(1701, 'Korlát', '3886', 4),
(1702, 'Körmend', '9900', 17),
(1703, 'Körmend', '9909', 17),
(1704, 'Környe', '2851', 11),
(1705, 'Köröm', '3577', 4);
INSERT INTO `city` (`city_id`, `city_name`, `postal_code`, `region_id`) VALUES
(1706, 'Koroncó', '9113', 7),
(1707, 'Kórós', '7841', 2),
(1708, 'Kőröshegy', '8617', 14),
(1709, 'Körösladány', '5516', 3),
(1710, 'Körösnagyharsány', '5539', 3),
(1711, 'Körösszakál', '4136', 8),
(1712, 'Körösszegapáti', '4135', 8),
(1713, 'Köröstarcsa', '5622', 3),
(1714, 'Kőröstetétlen', '2745', 13),
(1715, 'Körösújfalu', '5536', 3),
(1716, 'Kosd', '2612', 13),
(1717, 'Kóspallag', '2625', 13),
(1718, 'Kőszárhegy', '8152', 6),
(1719, 'Kőszeg', '9730', 17),
(1720, 'Kőszegdoroszló', '9725', 17),
(1721, 'Kőszegpaty', '9739', 17),
(1722, 'Kőszegszerdahely', '9725', 17),
(1723, 'Kótaj', '4482', 15),
(1724, 'Kötcse', '8627', 14),
(1725, 'Kötegyán', '5725', 3),
(1726, 'Kőtelek', '5062', 10),
(1727, 'Kovácshida', '7847', 2),
(1728, 'Kovácsszénája', '7678', 2),
(1729, 'Kovácsvágás', '3992', 4),
(1730, 'Kővágóörs', '8254', 18),
(1731, 'Kővágószőlős', '7673', 2),
(1732, 'Kővágótőttős', '7675', 2),
(1733, 'Kövegy', '6912', 5),
(1734, 'Köveskál', '8274', 18),
(1735, 'Kozárd', '3053', 12),
(1736, 'Kozármisleny', '7761', 2),
(1737, 'Kozmadombja', '8988', 19),
(1738, 'Krasznokvajda', '3821', 4),
(1739, 'Kübekháza', '6755', 5),
(1740, 'Kulcs', '2458', 6),
(1741, 'Külsősárd', '8978', 19),
(1742, 'Külsővat', '9532', 18),
(1743, 'Kunadacs', '6097', 1),
(1744, 'Kunágota', '5746', 3),
(1745, 'Kunbaja', '6435', 1),
(1746, 'Kunbaracs', '6043', 1),
(1747, 'Kuncsorba', '5412', 10),
(1748, 'Kunfehértó', '6413', 1),
(1749, 'Küngös', '8162', 18),
(1750, 'Kunhegyes', '5340', 10),
(1751, 'Kunmadaras', '5321', 10),
(1752, 'Kunpeszér', '6096', 1),
(1753, 'Kunszállás', '6115', 1),
(1754, 'Kunszentmárton', '5440', 10),
(1755, 'Kunszentmárton', '5449', 10),
(1756, 'Kunszentmiklós', '6090', 1),
(1757, 'Kunsziget', '9184', 7),
(1758, 'Kup', '8595', 18),
(1759, 'Kupa', '3813', 4),
(1760, 'Kurd', '7226', 16),
(1761, 'Kurityán', '3732', 4),
(1762, 'Kustánszeg', '8919', 19),
(1763, 'Kutas', '7541', 14),
(1764, 'Kutasó', '3066', 12),
(1765, 'Lábatlan', '2541', 11),
(1766, 'Lábod', '7551', 14),
(1767, 'Lácacséke', '3967', 4),
(1768, 'Lad', '7535', 14),
(1769, 'Ladánybene', '6045', 1),
(1770, 'Ládbesenyő', '3780', 4),
(1771, 'Lajoskomárom', '8136', 6),
(1772, 'Lajosmizse', '6050', 1),
(1773, 'Lak', '3786', 4),
(1774, 'Lakhegy', '8913', 19),
(1775, 'Lakitelek', '6065', 1),
(1776, 'Lakócsa', '7918', 14),
(1777, 'Lánycsók', '7759', 2),
(1778, 'Lápafő', '7214', 16),
(1779, 'Lapáncsa', '7775', 2),
(1780, 'Laskod', '4543', 15),
(1781, 'Lasztonya', '8887', 19),
(1782, 'Látrány', '8681', 14),
(1783, 'Lázi', '9089', 7),
(1784, 'Leányfalu', '2016', 13),
(1785, 'Leányvár', '2518', 11),
(1786, 'Lébény', '9155', 7),
(1787, 'Legénd', '2619', 12),
(1788, 'Legyesbénye', '3904', 4),
(1789, 'Léh', '3832', 4),
(1790, 'Lénárddaróc', '3648', 4),
(1791, 'Lendvadedes', '8978', 19),
(1792, 'Lendvajakabfa', '8977', 19),
(1793, 'Lengyel', '7184', 16),
(1794, 'Lengyeltóti', '8693', 14),
(1795, 'Lenti', '8960', 19),
(1796, 'Lenti', '8966', 19),
(1797, 'Lepsény', '8132', 6),
(1798, 'Lesencefalu', '8318', 18),
(1799, 'Lesenceistvánd', '8319', 18),
(1800, 'Lesencetomaj', '8318', 18),
(1801, 'Létavértes', '4281', 8),
(1802, 'Létavértes', '4283', 8),
(1803, 'Letenye', '8868', 19),
(1804, 'Letkés', '2632', 13),
(1805, 'Levél', '9221', 7),
(1806, 'Levelek', '4555', 15),
(1807, 'Libickozma', '8707', 14),
(1808, 'Lickóvadamos', '8981', 19),
(1809, 'Liget', '7331', 2),
(1810, 'Ligetfalva', '8782', 19),
(1811, 'Lipót', '9233', 7),
(1812, 'Lippó', '7781', 2),
(1813, 'Liptód', '7757', 2),
(1814, 'Lispeszentadorján', '8888', 19),
(1815, 'Liszó', '8831', 19),
(1816, 'Litér', '8196', 18),
(1817, 'Litka', '3866', 4),
(1818, 'Litke', '3186', 12),
(1819, 'Lócs', '9634', 17),
(1820, 'Lőkösháza', '5743', 3),
(1821, 'Lókút', '8425', 18),
(1822, 'Lónya', '4836', 15),
(1823, 'Lórév', '2309', 13),
(1824, 'Lőrinci', '3021', 9),
(1825, 'Lőrinci', '3022', 9),
(1826, 'Lőrinci', '3024', 9),
(1827, 'Lothárd', '7761', 2),
(1828, 'Lovas', '8228', 18),
(1829, 'Lovasberény', '8093', 6),
(1830, 'Lovászhetény', '7720', 2),
(1831, 'Lovászi', '8878', 19),
(1832, 'Lovászpatona', '8553', 18),
(1833, 'Lövő', '9461', 7),
(1834, 'Lövőpetri', '4633', 15),
(1835, 'Lucfalva', '3129', 12),
(1836, 'Ludányhalászi', '3188', 12),
(1837, 'Ludas', '3274', 9),
(1838, 'Lukácsháza', '9724', 17),
(1839, 'Lulla', '8660', 14),
(1840, 'Lúzsok', '7838', 2),
(1841, 'Mád', '3909', 4),
(1842, 'Madaras', '6456', 1),
(1843, 'Madocsa', '7026', 16),
(1844, 'Maglóca', '9169', 7),
(1845, 'Maglód', '2234', 13),
(1846, 'Mágocs', '7342', 2),
(1847, 'Magosliget', '4953', 15),
(1848, 'Magy', '4556', 15),
(1849, 'Magyaralmás', '8071', 6),
(1850, 'Magyaratád', '7463', 14),
(1851, 'Magyarbánhegyes', '5667', 3),
(1852, 'Magyarbóly', '7775', 2),
(1853, 'Magyarcsanád', '6932', 5),
(1854, 'Magyardombegyház', '5838', 3),
(1855, 'Magyaregregy', '7332', 2),
(1856, 'Magyaregres', '7441', 14),
(1857, 'Magyarföld', '8973', 19),
(1858, 'Magyargéc', '3133', 12),
(1859, 'Magyargencs', '8517', 18),
(1860, 'Magyarhertelend', '7394', 2),
(1861, 'Magyarhomorog', '4137', 8),
(1862, 'Magyarkeresztúr', '9346', 7),
(1863, 'Magyarkeszi', '7098', 16),
(1864, 'Magyarlak', '9962', 17),
(1865, 'Magyarlukafa', '7925', 2),
(1866, 'Magyarmecske', '7954', 2),
(1867, 'Magyarnádalja', '9909', 17),
(1868, 'Magyarnándor', '2694', 12),
(1869, 'Magyarpolány', '8449', 18),
(1870, 'Magyarsarlós', '7761', 2),
(1871, 'Magyarszecsőd', '9912', 17),
(1872, 'Magyarszék', '7396', 2),
(1873, 'Magyarszentmiklós', '8776', 19),
(1874, 'Magyarszerdahely', '8776', 19),
(1875, 'Magyarszombatfa', '9946', 17),
(1876, 'Magyartelek', '7954', 2),
(1877, 'Majosháza', '2339', 13),
(1878, 'Majs', '7783', 2),
(1879, 'Makád', '2322', 13),
(1880, 'Makkoshotyka', '3959', 4),
(1881, 'Maklár', '3397', 9),
(1882, 'Makó', '6900', 5),
(1883, 'Makó', '6903', 5),
(1884, 'Malomsok', '8533', 18),
(1885, 'Mályi', '3434', 4),
(1886, 'Mályinka', '3645', 4),
(1887, 'Mánd', '4942', 15),
(1888, 'Mándok', '4644', 15),
(1889, 'Mánfa', '7304', 2),
(1890, 'Mány', '2065', 6),
(1891, 'Maráza', '7733', 2),
(1892, 'Marcalgergelyi', '9534', 18),
(1893, 'Marcali', '8700', 14),
(1894, 'Marcali', '8709', 14),
(1895, 'Marcali', '8714', 14),
(1896, 'Marcaltő', '8531', 18),
(1897, 'Marcaltő', '8532', 18),
(1898, 'Márfa', '7817', 2),
(1899, 'Máriahalom', '2527', 11),
(1900, 'Máriakálnok', '9231', 7),
(1901, 'Máriakéménd', '7663', 2),
(1902, 'Márianosztra', '2629', 13),
(1903, 'Máriapócs', '4326', 15),
(1904, 'Markaz', '3262', 9),
(1905, 'Márkháza', '3075', 12),
(1906, 'Márkó', '8441', 18),
(1907, 'Markóc', '7967', 2),
(1908, 'Markotabödöge', '9164', 7),
(1909, 'Maróc', '8888', 19),
(1910, 'Marócsa', '7960', 2),
(1911, 'Márok', '7774', 2),
(1912, 'Márokföld', '8976', 19),
(1913, 'Márokpapi', '4932', 15),
(1914, 'Maroslele', '6921', 5),
(1915, 'Mártély', '6636', 5),
(1916, 'Martfű', '5435', 10),
(1917, 'Martonfa', '7720', 2),
(1918, 'Martonvásár', '2462', 6),
(1919, 'Martonyi', '3755', 4),
(1920, 'Mátészalka', '4700', 15),
(1921, 'Mátételke', '6452', 1),
(1922, 'Mátraballa', '3247', 9),
(1923, 'Mátraderecske', '3246', 9),
(1924, 'Mátramindszent', '3155', 12),
(1925, 'Mátranovák', '3143', 12),
(1926, 'Mátranovák', '3144', 12),
(1927, 'Mátraszele', '3142', 12),
(1928, 'Mátraszentimre', '3234', 9),
(1929, 'Mátraszentimre', '3235', 9),
(1930, 'Mátraszőlős', '3068', 12),
(1931, 'Mátraterenye', '3145', 12),
(1932, 'Mátraterenye', '3146', 12),
(1933, 'Mátraverebély', '3077', 12),
(1934, 'Matty', '7854', 2),
(1935, 'Mátyásdomb', '8134', 6),
(1936, 'Mátyus', '4835', 15),
(1937, 'Máza', '7351', 2),
(1938, 'Mecseknádasd', '7695', 2),
(1939, 'Mecsekpölöske', '7300', 2),
(1940, 'Mecsér', '9176', 7),
(1941, 'Medgyesbodzás', '5663', 3),
(1942, 'Medgyesbodzás', '5664', 3),
(1943, 'Medgyesegyháza', '5666', 3),
(1944, 'Medgyesegyháza', '5752', 3),
(1945, 'Medina', '7057', 16),
(1946, 'Meggyeskovácsi', '9757', 17),
(1947, 'Megyaszó', '3718', 4),
(1948, 'Megyehid', '9754', 17),
(1949, 'Megyer', '8348', 18),
(1950, 'Méhkerék', '5726', 3),
(1951, 'Méhtelek', '4975', 15),
(1952, 'Mekényes', '7344', 2),
(1953, 'Mélykút', '6449', 1),
(1954, 'Mencshely', '8271', 18),
(1955, 'Mende', '2235', 13),
(1956, 'Méra', '3871', 4),
(1957, 'Merenye', '7981', 2),
(1958, 'Mérges', '9136', 7),
(1959, 'Mérk', '4352', 15),
(1960, 'Mernye', '7453', 14),
(1961, 'Mersevát', '9531', 17),
(1962, 'Mesterháza', '9662', 17),
(1963, 'Mesteri', '9551', 17),
(1964, 'Mesterszállás', '5452', 10),
(1965, 'Meszes', '3754', 4),
(1966, 'Meszlen', '9745', 17),
(1967, 'Mesztegnyő', '8716', 14),
(1968, 'Mezőberény', '5650', 3),
(1969, 'Mezőcsát', '3450', 4),
(1970, 'Mezőcsokonya', '7434', 14),
(1971, 'Meződ', '7370', 2),
(1972, 'Mezőfalva', '2422', 6),
(1973, 'Mezőgyán', '5732', 3),
(1974, 'Mezőhegyes', '5820', 3),
(1975, 'Mezőhék', '5453', 10),
(1976, 'Mezőkeresztes', '3441', 4),
(1977, 'Mezőkomárom', '8137', 6),
(1978, 'Mezőkovácsháza', '5800', 3),
(1979, 'Mezőkövesd', '3400', 4),
(1980, 'Mezőladány', '4641', 15),
(1981, 'Mezőlak', '8514', 18),
(1982, 'Mezőnagymihály', '3443', 4),
(1983, 'Mezőnyárád', '3421', 4),
(1984, 'Mezőörs', '9097', 7),
(1985, 'Mezőörs', '9098', 7),
(1986, 'Mezőpeterd', '4118', 8),
(1987, 'Mezősas', '4134', 8),
(1988, 'Mezőszemere', '3378', 9),
(1989, 'Mezőszentgyörgy', '8133', 6),
(1990, 'Mezőszilas', '7017', 6),
(1991, 'Mezőtárkány', '3375', 9),
(1992, 'Mezőtúr', '5400', 10),
(1993, 'Mezőzombor', '3931', 4),
(1994, 'Miháld', '8825', 19),
(1995, 'Mihályfa', '8341', 19),
(1996, 'Mihálygerge', '3184', 12),
(1997, 'Mihályháza', '8513', 18),
(1998, 'Mihályi', '9342', 7),
(1999, 'Mike', '7512', 14),
(2000, 'Mikebuda', '2736', 13),
(2001, 'Mikekarácsonyfa', '8949', 19),
(2002, 'Mikepércs', '4271', 8),
(2003, 'Miklósi', '7286', 14),
(2004, 'Mikófalva', '3344', 9),
(2005, 'Mikóháza', '3989', 4),
(2006, 'Mikosszéplak', '9835', 17),
(2007, 'Milejszeg', '8917', 19),
(2008, 'Milota', '4948', 15),
(2009, 'Mindszent', '6630', 5),
(2010, 'Mindszentgodisa', '7391', 2),
(2011, 'Mindszentkálla', '8282', 18),
(2012, 'Misefa', '8935', 19),
(2013, 'Miske', '6343', 1),
(2014, 'Miskolc', '3500', 4),
(2015, 'Miskolc', '3501', 4),
(2016, 'Miskolc', '3508', 4),
(2017, 'Miskolc', '3510', 4),
(2018, 'Miskolc', '3515', 4),
(2019, 'Miskolc', '3516', 4),
(2020, 'Miskolc', '3517', 4),
(2021, 'Miskolc', '3518', 4),
(2022, 'Miskolc', '3519', 4),
(2023, 'Miskolc', '3521', 4),
(2024, 'Miskolc', '3524', 4),
(2025, 'Miskolc', '3525', 4),
(2026, 'Miskolc', '3526', 4),
(2027, 'Miskolc', '3527', 4),
(2028, 'Miskolc', '3528', 4),
(2029, 'Miskolc', '3529', 4),
(2030, 'Miskolc', '3530', 4),
(2031, 'Miskolc', '3531', 4),
(2032, 'Miskolc', '3532', 4),
(2033, 'Miskolc', '3533', 4),
(2034, 'Miskolc', '3534', 4),
(2035, 'Miskolc', '3535', 4),
(2036, 'Miszla', '7065', 16),
(2037, 'Mocsa', '2911', 11),
(2038, 'Mőcsény', '7163', 16),
(2039, 'Mogyoród', '2146', 13),
(2040, 'Mogyorósbánya', '2535', 11),
(2041, 'Mogyoróska', '3893', 4),
(2042, 'Moha', '8042', 6),
(2043, 'Mohács', '7700', 2),
(2044, 'Mohács', '7714', 2),
(2045, 'Mohács', '7715', 2),
(2046, 'Mohora', '2698', 12),
(2047, 'Molnári', '8863', 19),
(2048, 'Molnaszecsőd', '9912', 17),
(2049, 'Molvány', '7981', 2),
(2050, 'Monaj', '3812', 4),
(2051, 'Monok', '3905', 4),
(2052, 'Monor', '2200', 13),
(2053, 'Monor', '2213', 13),
(2054, 'Mónosbél', '3345', 9),
(2055, 'Monostorapáti', '8296', 18),
(2056, 'Monostorpályi', '4275', 8),
(2057, 'Monoszló', '8273', 18),
(2058, 'Monyoród', '7751', 2),
(2059, 'Mór', '8060', 6),
(2060, 'Mórágy', '7165', 16),
(2061, 'Mórahalom', '6782', 5),
(2062, 'Móricgát', '6132', 1),
(2063, 'Mórichida', '9131', 7),
(2064, 'Mosdós', '7257', 14),
(2065, 'Mosonmagyaróvár', '9200', 7),
(2066, 'Mosonszentmiklós', '9154', 7),
(2067, 'Mosonszentmiklós', '9183', 7),
(2068, 'Mosonszolnok', '9245', 7),
(2069, 'Mozsgó', '7932', 2),
(2070, 'Mucsfa', '7185', 16),
(2071, 'Mucsi', '7195', 16),
(2072, 'Múcsony', '3744', 4),
(2073, 'Muhi', '3552', 4),
(2074, 'Murakeresztúr', '8834', 19),
(2075, 'Murarátka', '8868', 19),
(2076, 'Muraszemenye', '8872', 19),
(2077, 'Murga', '7176', 16),
(2078, 'Murony', '5672', 3),
(2079, 'Nábrád', '4911', 15),
(2080, 'Nadap', '8097', 6),
(2081, 'Nádasd', '9915', 17),
(2082, 'Nádasdladány', '8145', 6),
(2083, 'Nádudvar', '4181', 8),
(2084, 'Nágocs', '8674', 14),
(2085, 'Nagyacsád', '8521', 18),
(2086, 'Nagyalásony', '8484', 18),
(2087, 'Nagyar', '4922', 15),
(2088, 'Nagyatád', '7500', 14),
(2089, 'Nagybajcs', '9063', 7),
(2090, 'Nagybajom', '7561', 14),
(2091, 'Nagybakónak', '8821', 19),
(2092, 'Nagybánhegyes', '5668', 3),
(2093, 'Nagybaracska', '6527', 1),
(2094, 'Nagybarca', '3641', 4),
(2095, 'Nagybárkány', '3075', 12),
(2096, 'Nagyberény', '8656', 14),
(2097, 'Nagyberki', '7255', 14),
(2098, 'Nagybörzsöny', '2634', 13),
(2099, 'Nagybudmér', '7756', 2),
(2100, 'Nagycenk', '9485', 7),
(2101, 'Nagycsány', '7838', 2),
(2102, 'Nagycsécs', '3598', 4),
(2103, 'Nagycsepely', '8628', 14),
(2104, 'Nagycserkesz', '4445', 15),
(2105, 'Nagydém', '8554', 18),
(2106, 'Nagydobos', '4823', 15),
(2107, 'Nagydobsza', '7985', 2),
(2108, 'Nagydorog', '7044', 16),
(2109, 'Nagyecsed', '4355', 15),
(2110, 'Nagyér', '6917', 5),
(2111, 'Nagyesztergár', '8415', 18),
(2112, 'Nagyfüged', '3282', 9),
(2113, 'Nagygeresd', '9664', 17),
(2114, 'Nagygörbő', '8356', 19),
(2115, 'Nagygyimót', '8551', 18),
(2116, 'Nagyhajmás', '7343', 2),
(2117, 'Nagyhalász', '4485', 15),
(2118, 'Nagyharsány', '7822', 2),
(2119, 'Nagyhegyes', '4064', 8),
(2120, 'Nagyhódos', '4977', 15),
(2121, 'Nagyhuta', '3994', 4),
(2122, 'Nagyigmánd', '2942', 11),
(2123, 'Nagyiván', '5363', 10),
(2124, 'Nagykálló', '4320', 15),
(2125, 'Nagykamarás', '5751', 3),
(2126, 'Nagykanizsa', '8800', 19),
(2127, 'Nagykanizsa', '8808', 19),
(2128, 'Nagykanizsa', '8809', 19),
(2129, 'Nagykanizsa', '8831', 19),
(2130, 'Nagykapornak', '8935', 19),
(2131, 'Nagykarácsony', '2425', 6),
(2132, 'Nagykáta', '2760', 13),
(2133, 'Nagykereki', '4127', 8),
(2134, 'Nagykeresztúr', '3129', 12),
(2135, 'Nagykinizs', '3844', 4),
(2136, 'Nagykökényes', '3012', 9),
(2137, 'Nagykölked', '9784', 17),
(2138, 'Nagykónyi', '7092', 16),
(2139, 'Nagykőrös', '2750', 13),
(2140, 'Nagykorpád', '7545', 14),
(2141, 'Nagykörű', '5065', 10),
(2142, 'Nagykovácsi', '2094', 13),
(2143, 'Nagykozár', '7741', 2),
(2144, 'Nagykutas', '8911', 19),
(2145, 'Nagylak', '6933', 5),
(2146, 'Nagylengyel', '8983', 19),
(2147, 'Nagylóc', '3175', 12),
(2148, 'Nagylók', '2435', 6),
(2149, 'Nagylózs', '9482', 7),
(2150, 'Nagymágocs', '6622', 5),
(2151, 'Nagymányok', '7355', 16),
(2152, 'Nagymaros', '2626', 13),
(2153, 'Nagymizdó', '9913', 17),
(2154, 'Nagynyárád', '7784', 2),
(2155, 'Nagyoroszi', '2645', 12),
(2156, 'Nagypáli', '8912', 19),
(2157, 'Nagypall', '7731', 2),
(2158, 'Nagypeterd', '7912', 2),
(2159, 'Nagypirit', '8496', 18),
(2160, 'Nagyrábé', '4173', 8),
(2161, 'Nagyrada', '8746', 19),
(2162, 'Nagyrákos', '9938', 17),
(2163, 'Nagyrécse', '8756', 19),
(2164, 'Nagyréde', '3214', 9),
(2165, 'Nagyrév', '5463', 10),
(2166, 'Nagyrozvágy', '3965', 4),
(2167, 'Nagysáp', '2524', 11),
(2168, 'Nagysimonyi', '9561', 17),
(2169, 'Nagyszakácsi', '8739', 14),
(2170, 'Nagyszékely', '7085', 16),
(2171, 'Nagyszekeres', '4962', 15),
(2172, 'Nagyszénás', '5931', 3),
(2173, 'Nagyszentjános', '9072', 7),
(2174, 'Nagyszokoly', '7097', 16),
(2175, 'Nagytálya', '3398', 9),
(2176, 'Nagytarcsa', '2142', 13),
(2177, 'Nagytevel', '8562', 18),
(2178, 'Nagytilaj', '9832', 17),
(2179, 'Nagytőke', '6612', 5),
(2180, 'Nagytótfalu', '7800', 2),
(2181, 'Nagyút', '3357', 9),
(2182, 'Nagyvarsány', '4812', 15),
(2183, 'Nagyváty', '7912', 2),
(2184, 'Nagyvázsony', '8291', 18),
(2185, 'Nagyvejke', '7186', 16),
(2186, 'Nagyveleg', '8065', 6),
(2187, 'Nagyvenyim', '2421', 6),
(2188, 'Nagyvisnyó', '3349', 9),
(2189, 'Nak', '7215', 16),
(2190, 'Napkor', '4552', 15),
(2191, 'Nárai', '9797', 17),
(2192, 'Narda', '9793', 17),
(2193, 'Naszály', '2899', 11),
(2194, 'Négyes', '3463', 4),
(2195, 'Nekézseny', '3646', 4),
(2196, 'Nemesapáti', '8923', 19),
(2197, 'Nemesbikk', '3592', 4),
(2198, 'Nemesbőd', '9749', 17),
(2199, 'Nemesborzova', '4942', 15),
(2200, 'Nemesbük', '8371', 19),
(2201, 'Nemescsó', '9739', 17),
(2202, 'Nemesdéd', '8722', 14),
(2203, 'Nemesgörzsöny', '8522', 18),
(2204, 'Nemesgulács', '8284', 18),
(2205, 'Nemeshany', '8471', 18),
(2206, 'Nemeshetés', '8925', 19),
(2207, 'Nemeske', '7981', 2),
(2208, 'Nemeskér', '9471', 7),
(2209, 'Nemeskeresztúr', '9548', 17),
(2210, 'Nemeskisfalud', '8717', 14),
(2211, 'Nemeskocs', '9542', 17),
(2212, 'Nemeskolta', '9775', 17),
(2213, 'Nemesládony', '9663', 17),
(2214, 'Nemesmedves', '9953', 17),
(2215, 'Nemesnádudvar', '6345', 1),
(2216, 'Nemesnép', '8976', 19),
(2217, 'Nemespátró', '8856', 19),
(2218, 'Nemesrádó', '8915', 19),
(2219, 'Nemesrempehollós', '9782', 17),
(2220, 'Nemessándorháza', '8925', 19),
(2221, 'Nemesszalók', '9533', 18),
(2222, 'Nemesszentandrás', '8925', 19),
(2223, 'Nemesvámos', '8248', 18),
(2224, 'Nemesvid', '8738', 14),
(2225, 'Nemesvita', '8311', 18),
(2226, 'Németbánya', '8581', 18),
(2227, 'Németfalu', '8918', 19),
(2228, 'Németkér', '7039', 16),
(2229, 'Nemti', '3152', 12),
(2230, 'Neszmély', '2544', 11),
(2231, 'Nézsa', '2618', 12),
(2232, 'Nick', '9652', 17),
(2233, 'Nikla', '8706', 14),
(2234, 'Nógrád', '2642', 12),
(2235, 'Nógrádkövesd', '2691', 12),
(2236, 'Nógrádmarcal', '2675', 12),
(2237, 'Nógrádmegyer', '3132', 12),
(2238, 'Nógrádsáp', '2685', 12),
(2239, 'Nógrádsipek', '3179', 12),
(2240, 'Nógrádszakál', '3187', 12),
(2241, 'Nóráp', '8591', 18),
(2242, 'Noszlop', '8456', 18),
(2243, 'Noszvaj', '3325', 9),
(2244, 'Nőtincs', '2610', 12),
(2245, 'Nova', '8948', 19),
(2246, 'Novaj', '3327', 9),
(2247, 'Novajidrány', '3872', 4),
(2248, 'Nyalka', '9096', 7),
(2249, 'Nyárád', '8512', 18),
(2250, 'Nyáregyháza', '2723', 13),
(2251, 'Nyárlőrinc', '6032', 1),
(2252, 'Nyársapát', '2712', 13),
(2253, 'Nyékládháza', '3433', 4),
(2254, 'Nyergesújfalu', '2536', 11),
(2255, 'Nyergesújfalu', '2537', 11),
(2256, 'Nyésta', '3809', 4),
(2257, 'Nyim', '8612', 14),
(2258, 'Nyírábrány', '4264', 8),
(2259, 'Nyíracsád', '4262', 8),
(2260, 'Nyirád', '8454', 18),
(2261, 'Nyíradony', '4252', 8),
(2262, 'Nyíradony', '4253', 8),
(2263, 'Nyíradony', '4254', 8),
(2264, 'Nyírbátor', '4300', 15),
(2265, 'Nyírbéltek', '4372', 15),
(2266, 'Nyírbogát', '4361', 15),
(2267, 'Nyírbogdány', '4511', 15),
(2268, 'Nyírcsaholy', '4356', 15),
(2269, 'Nyírcsászári', '4331', 15),
(2270, 'Nyírderzs', '4332', 15),
(2271, 'Nyíregyháza', '4246', 15),
(2272, 'Nyíregyháza', '4400', 15),
(2273, 'Nyíregyháza', '4405', 15),
(2274, 'Nyíregyháza', '4412', 15),
(2275, 'Nyíregyháza', '4431', 15),
(2276, 'Nyíregyháza', '4432', 15),
(2277, 'Nyíregyháza', '4433', 15),
(2278, 'Nyíregyháza', '4481', 15),
(2279, 'Nyíregyháza', '4551', 15),
(2280, 'Nyírgelse', '4362', 15),
(2281, 'Nyírgyulaj', '4311', 15),
(2282, 'Nyíri', '3997', 4),
(2283, 'Nyíribrony', '4535', 15),
(2284, 'Nyírjákó', '4541', 15),
(2285, 'Nyírkarász', '4544', 15),
(2286, 'Nyírkáta', '4333', 15),
(2287, 'Nyírkércs', '4537', 15),
(2288, 'Nyírlövő', '4632', 15),
(2289, 'Nyírlugos', '4371', 15),
(2290, 'Nyírmada', '4564', 15),
(2291, 'Nyírmártonfalva', '4263', 8),
(2292, 'Nyírmeggyes', '4722', 15),
(2293, 'Nyírmihálydi', '4363', 15),
(2294, 'Nyírparasznya', '4822', 15),
(2295, 'Nyírpazony', '4531', 15),
(2296, 'Nyírpilis', '4376', 15),
(2297, 'Nyírtass', '4522', 15),
(2298, 'Nyírtelek', '4461', 15),
(2299, 'Nyírtét', '4554', 15),
(2300, 'Nyírtura', '4532', 15),
(2301, 'Nyírvasvári', '4341', 15),
(2302, 'Nyőgér', '9682', 17),
(2303, 'Nyomár', '3795', 4),
(2304, 'Nyugotszenterzsébet', '7912', 2),
(2305, 'Nyúl', '9082', 7),
(2306, 'Óbánya', '7695', 2),
(2307, 'Óbarok', '2063', 6),
(2308, 'Óbudavár', '8272', 18),
(2309, 'Öcs', '8292', 18),
(2310, 'Ócsa', '2364', 13),
(2311, 'Ócsárd', '7814', 2),
(2312, 'Őcsény', '7143', 16),
(2313, 'Öcsöd', '5451', 10),
(2314, 'Ófalu', '7695', 2),
(2315, 'Ófehértó', '4558', 15),
(2316, 'Óföldeák', '6923', 5),
(2317, 'Óhid', '8342', 19),
(2318, 'Okány', '5534', 3),
(2319, 'Okorág', '7957', 2),
(2320, 'Ököritófülpös', '4755', 15),
(2321, 'Okorvölgy', '7681', 2),
(2322, 'Olasz', '7745', 2),
(2323, 'Olaszfa', '9824', 17),
(2324, 'Olaszfalu', '8414', 18),
(2325, 'Olaszliszka', '3933', 4),
(2326, 'Ölbő', '9621', 17),
(2327, 'Olcsva', '4826', 15),
(2328, 'Olcsvaapáti', '4914', 15),
(2329, 'Old', '7824', 2),
(2330, 'Ólmod', '9733', 17),
(2331, 'Oltárc', '8886', 19),
(2332, 'Ömböly', '4373', 15),
(2333, 'Onga', '3562', 4),
(2334, 'Ónod', '3551', 4),
(2335, 'Ópályi', '4821', 15),
(2336, 'Ópusztaszer', '6767', 5),
(2337, 'Őr', '4336', 15),
(2338, 'Orbányosfa', '8935', 19),
(2339, 'Őrbottyán', '2162', 13),
(2340, 'Orci', '7400', 14),
(2341, 'Ordacsehi', '8635', 14),
(2342, 'Ordas', '6335', 1),
(2343, 'Öregcsertő', '6311', 1),
(2344, 'Öreglak', '8697', 14),
(2345, 'Orfalu', '9982', 17),
(2346, 'Orfű', '7677', 2),
(2347, 'Orgovány', '6077', 1),
(2348, 'Őrhalom', '2671', 12),
(2349, 'Őrimagyarósd', '9933', 17),
(2350, 'Őriszentpéter', '9941', 17),
(2351, 'Örkény', '2377', 13),
(2352, 'Ormándlak', '8983', 19),
(2353, 'Örményes', '5222', 10),
(2354, 'Örménykút', '5556', 3),
(2355, 'Ormosbánya', '3743', 4),
(2356, 'Orosháza', '5900', 3),
(2357, 'Orosháza', '5903', 3),
(2358, 'Orosháza', '5904', 3),
(2359, 'Orosháza', '5905', 3),
(2360, 'Oroszi', '8458', 18),
(2361, 'Oroszlány', '2840', 11),
(2362, 'Oroszló', '7370', 2),
(2363, 'Orosztony', '8744', 19),
(2364, 'Ortaháza', '8954', 19),
(2365, 'Őrtilos', '8854', 14),
(2366, 'Örvényes', '8242', 18),
(2367, 'Ősagárd', '2610', 12),
(2368, 'Ősi', '8161', 18),
(2369, 'Öskü', '8191', 18),
(2370, 'Osli', '9354', 7),
(2371, 'Ostffyasszonyfa', '9512', 17),
(2372, 'Ostoros', '3326', 9),
(2373, 'Oszkó', '9825', 17),
(2374, 'Oszlár', '3591', 4),
(2375, 'Osztopán', '7444', 14),
(2376, 'Öttevény', '9153', 7),
(2377, 'Öttömös', '6784', 5),
(2378, 'Ötvöskónyi', '7511', 14),
(2379, 'Ózd', '3600', 4),
(2380, 'Ózd', '3603', 4),
(2381, 'Ózd', '3604', 4),
(2382, 'Ózd', '3621', 4),
(2383, 'Ózd', '3625', 4),
(2384, 'Ózd', '3651', 4),
(2385, 'Ózd', '3661', 4),
(2386, 'Ózd', '3662', 4),
(2387, 'Ózdfalu', '7836', 2),
(2388, 'Ozmánbük', '8998', 19),
(2389, 'Ozora', '7086', 16),
(2390, 'Pácin', '3964', 4),
(2391, 'Pacsa', '8761', 19),
(2392, 'Pácsony', '9823', 17),
(2393, 'Padár', '8935', 19),
(2394, 'Páhi', '6075', 1),
(2395, 'Páka', '8956', 19),
(2396, 'Pakod', '8799', 19),
(2397, 'Pákozd', '8095', 6),
(2398, 'Paks', '7027', 16),
(2399, 'Paks', '7030', 16),
(2400, 'Palé', '7370', 2),
(2401, 'Pálfa', '7042', 16),
(2402, 'Pálfiszeg', '8990', 19),
(2403, 'Pálháza', '3994', 4),
(2404, 'Páli', '9345', 7),
(2405, 'Palkonya', '7771', 2),
(2406, 'Pálmajor', '7561', 14),
(2407, 'Pálmonostora', '6112', 1),
(2408, 'Palotabozsok', '7727', 2),
(2409, 'Palotás', '3042', 12),
(2410, 'Paloznak', '8229', 18),
(2411, 'Pamlény', '3821', 4),
(2412, 'Pamuk', '8698', 14),
(2413, 'Pánd', '2214', 13),
(2414, 'Pankasz', '9937', 17),
(2415, 'Pannonhalma', '9090', 7),
(2416, 'Pányok', '3898', 4),
(2417, 'Panyola', '4913', 15),
(2418, 'Pap', '4631', 15),
(2419, 'Pápa', '8500', 18),
(2420, 'Pápa', '8511', 18),
(2421, 'Pápa', '8591', 18),
(2422, 'Pápa', '8598', 18),
(2423, 'Pápadereske', '8593', 18),
(2424, 'Pápakovácsi', '8596', 18),
(2425, 'Pápasalamon', '8594', 18),
(2426, 'Pápateszér', '8556', 18),
(2427, 'Papkeszi', '8183', 18),
(2428, 'Pápoc', '9515', 17),
(2429, 'Papos', '4338', 15),
(2430, 'Páprád', '7838', 2),
(2431, 'Parád', '3240', 9),
(2432, 'Parád', '3244', 9),
(2433, 'Parádsasvár', '3242', 9),
(2434, 'Parasznya', '3777', 4),
(2435, 'Paszab', '4475', 15),
(2436, 'Pásztó', '3060', 12),
(2437, 'Pásztó', '3065', 12),
(2438, 'Pásztó', '3082', 12),
(2439, 'Pásztori', '9311', 7),
(2440, 'Pat', '8825', 19),
(2441, 'Patak', '2648', 12),
(2442, 'Patalom', '7463', 14),
(2443, 'Patapoklosi', '7923', 2),
(2444, 'Patca', '7477', 14),
(2445, 'Pátka', '8092', 6),
(2446, 'Patosfa', '7536', 14),
(2447, 'Pátroha', '4523', 15),
(2448, 'Patvarc', '2668', 12),
(2449, 'Páty', '2071', 13),
(2450, 'Pátyod', '4766', 15),
(2451, 'Pázmánd', '2476', 6),
(2452, 'Pázmándfalu', '9085', 7),
(2453, 'Pécel', '2119', 13),
(2454, 'Pecöl', '9754', 17),
(2455, 'Pécs', '7600', 2),
(2456, 'Pécs', '7621', 2),
(2457, 'Pécs', '7622', 2),
(2458, 'Pécs', '7623', 2),
(2459, 'Pécs', '7624', 2),
(2460, 'Pécs', '7625', 2),
(2461, 'Pécs', '7626', 2),
(2462, 'Pécs', '7627', 2),
(2463, 'Pécs', '7628', 2),
(2464, 'Pécs', '7629', 2),
(2465, 'Pécs', '7630', 2),
(2466, 'Pécs', '7631', 2),
(2467, 'Pécs', '7632', 2),
(2468, 'Pécs', '7633', 2),
(2469, 'Pécs', '7634', 2),
(2470, 'Pécs', '7635', 2),
(2471, 'Pécs', '7636', 2),
(2472, 'Pécs', '7691', 2),
(2473, 'Pécs', '7693', 2),
(2474, 'Pécsbagota', '7951', 2),
(2475, 'Pécsdevecser', '7766', 2),
(2476, 'Pécsely', '8245', 18),
(2477, 'Pécsudvard', '7762', 2),
(2478, 'Pécsvárad', '7720', 2),
(2479, 'Pellérd', '7831', 2),
(2480, 'Pély', '3381', 9),
(2481, 'Penc', '2614', 13),
(2482, 'Penészlek', '4267', 15),
(2483, 'Penyige', '4941', 15),
(2484, 'Pénzesgyőr', '8426', 18),
(2485, 'Pér', '9099', 7),
(2486, 'Perbál', '2074', 13),
(2487, 'Pere', '3853', 4),
(2488, 'Perecse', '3821', 4),
(2489, 'Pereked', '7664', 2),
(2490, 'Perenye', '9722', 17),
(2491, 'Peresznye', '9734', 17),
(2492, 'Pereszteg', '9484', 7),
(2493, 'Perkáta', '2431', 6),
(2494, 'Perkupa', '3756', 4),
(2495, 'Perőcsény', '2637', 13),
(2496, 'Peterd', '7766', 2),
(2497, 'Péterhida', '7582', 14),
(2498, 'Péteri', '2209', 13),
(2499, 'Pétervására', '3250', 9),
(2500, 'Pétfürdő', '8105', 18),
(2501, 'Pethőhenye', '8921', 19),
(2502, 'Petneháza', '4542', 15),
(2503, 'Petőfibánya', '3023', 9),
(2504, 'Petőfiszállás', '6113', 1),
(2505, 'Petőháza', '9443', 7),
(2506, 'Petőmihályfa', '9826', 17),
(2507, 'Petrikeresztúr', '8984', 19),
(2508, 'Petrivente', '8866', 19),
(2509, 'Pettend', '7980', 2),
(2510, 'Piliny', '3134', 12),
(2511, 'Pilis', '2721', 13),
(2512, 'Pilisborosjenő', '2097', 13),
(2513, 'Piliscsaba', '2081', 13),
(2514, 'Piliscsaba', '2087', 13),
(2515, 'Piliscsév', '2519', 11),
(2516, 'Pilisjászfalu', '2080', 13),
(2517, 'Pilismarót', '2028', 11),
(2518, 'Pilisszántó', '2095', 13),
(2519, 'Pilisszentiván', '2084', 13),
(2520, 'Pilisszentkereszt', '2098', 13),
(2521, 'Pilisszentkereszt', '2099', 13),
(2522, 'Pilisszentlászló', '2009', 13),
(2523, 'Pilisvörösvár', '2085', 13),
(2524, 'Pincehely', '7084', 16),
(2525, 'Pinkamindszent', '9922', 17),
(2526, 'Pinnye', '9481', 7),
(2527, 'Piricse', '4375', 15),
(2528, 'Pirtó', '6414', 1),
(2529, 'Piskó', '7838', 2),
(2530, 'Pitvaros', '6914', 5),
(2531, 'Pócsa', '7756', 2),
(2532, 'Pocsaj', '4125', 8),
(2533, 'Pócsmegyer', '2017', 13),
(2534, 'Pócspetri', '4327', 15),
(2535, 'Pogány', '7666', 2),
(2536, 'Pogányszentpéter', '8728', 14),
(2537, 'Pókaszepetk', '8932', 19),
(2538, 'Polány', '7458', 14),
(2539, 'Polgár', '4090', 8),
(2540, 'Polgárdi', '8153', 6),
(2541, 'Polgárdi', '8154', 6),
(2542, 'Polgárdi', '8155', 6),
(2543, 'Pölöske', '8929', 19),
(2544, 'Pölöskefő', '8773', 19),
(2545, 'Pomáz', '2013', 13),
(2546, 'Pörböly', '7142', 16),
(2547, 'Porcsalma', '4761', 15),
(2548, 'Pördefölde', '8956', 19),
(2549, 'Pornóapáti', '9796', 17),
(2550, 'Poroszló', '3388', 9),
(2551, 'Porpác', '9612', 17),
(2552, 'Porrog', '8858', 14),
(2553, 'Porrogszentkirály', '8858', 14),
(2554, 'Porrogszentpál', '8858', 14),
(2555, 'Pórszombat', '8986', 19),
(2556, 'Porva', '8429', 18),
(2557, 'Pósfa', '9636', 17),
(2558, 'Potony', '7977', 14),
(2559, 'Pötréte', '8767', 19),
(2560, 'Potyond', '9324', 7),
(2561, 'Prügy', '3925', 4),
(2562, 'Pula', '8291', 18),
(2563, 'Püski', '9235', 7),
(2564, 'Püspökhatvan', '2682', 13),
(2565, 'Püspökladány', '4150', 8),
(2566, 'Püspökmolnári', '9776', 17),
(2567, 'Püspökszilágy', '2166', 13),
(2568, 'Pusztaapáti', '8986', 19),
(2569, 'Pusztaberki', '2658', 12),
(2570, 'Pusztacsalád', '9373', 7),
(2571, 'Pusztacsó', '9739', 17),
(2572, 'Pusztadobos', '4565', 15),
(2573, 'Pusztaederics', '8946', 19),
(2574, 'Pusztafalu', '3995', 4),
(2575, 'Pusztaföldvár', '5919', 3),
(2576, 'Pusztahencse', '7038', 16),
(2577, 'Pusztakovácsi', '8707', 14),
(2578, 'Pusztamagyaród', '8895', 19),
(2579, 'Pusztamérges', '6785', 5),
(2580, 'Pusztamiske', '8455', 18),
(2581, 'Pusztamonostor', '5125', 10),
(2582, 'Pusztaottlaka', '5665', 3),
(2583, 'Pusztaradvány', '3874', 4),
(2584, 'Pusztaszabolcs', '2490', 6),
(2585, 'Pusztaszemes', '8619', 14),
(2586, 'Pusztaszentlászló', '8896', 19),
(2587, 'Pusztaszer', '6769', 5),
(2588, 'Pusztavacs', '2378', 13),
(2589, 'Pusztavám', '8066', 6),
(2590, 'Pusztazámor', '2039', 13),
(2591, 'Putnok', '3630', 4),
(2592, 'Rábacsanak', '9313', 7),
(2593, 'Rábacsécsény', '9136', 7),
(2594, 'Rábagyarmat', '9961', 17),
(2595, 'Rábahidvég', '9777', 17),
(2596, 'Rábakecöl', '9344', 7),
(2597, 'Rábapatona', '9142', 7),
(2598, 'Rábapaty', '9641', 17),
(2599, 'Rábapordány', '9146', 7),
(2600, 'Rábasebes', '9327', 7),
(2601, 'Rábaszentandrás', '9316', 7),
(2602, 'Rábaszentmihály', '9135', 7),
(2603, 'Rábaszentmiklós', '9133', 7),
(2604, 'Rábatamási', '9322', 7),
(2605, 'Rábatöttös', '9766', 17),
(2606, 'Rábcakapi', '9165', 7),
(2607, 'Rácalmás', '2459', 6),
(2608, 'Ráckeresztúr', '2465', 6),
(2609, 'Ráckeve', '2300', 13),
(2610, 'Rád', '2613', 13),
(2611, 'Rádfalva', '7817', 2),
(2612, 'Rádóckölked', '9784', 17),
(2613, 'Radostyán', '3776', 4),
(2614, 'Ragály', '3724', 4),
(2615, 'Rajka', '9224', 7),
(2616, 'Rakaca', '3825', 4),
(2617, 'Rakacaszend', '3826', 4),
(2618, 'Rakamaz', '4465', 15),
(2619, 'Rákóczibánya', '3151', 12),
(2620, 'Rákóczifalva', '5085', 10),
(2621, 'Rákócziújfalu', '5084', 10),
(2622, 'Ráksi', '7464', 14),
(2623, 'Ramocsa', '8973', 19),
(2624, 'Ramocsaháza', '4536', 15),
(2625, 'Rápolt', '4756', 15),
(2626, 'Raposka', '8300', 18),
(2627, 'Rásonysápberencs', '3833', 4),
(2628, 'Rátka', '3908', 4),
(2629, 'Rátót', '9951', 17),
(2630, 'Ravazd', '9091', 7),
(2631, 'Recsk', '3245', 9),
(2632, 'Réde', '2886', 11),
(2633, 'Rédics', '8978', 19),
(2634, 'Regéc', '3893', 4),
(2635, 'Regenye', '7833', 2),
(2636, 'Regöly', '7193', 16),
(2637, 'Rém', '6446', 1),
(2638, 'Remeteszőlős', '2090', 13),
(2639, 'Répáshuta', '3559', 4),
(2640, 'Répcelak', '9653', 17),
(2641, 'Répceszemere', '9375', 7),
(2642, 'Répceszentgyörgy', '9623', 17),
(2643, 'Répcevis', '9475', 7),
(2644, 'Resznek', '8977', 19),
(2645, 'Rétalap', '9074', 7),
(2646, 'Rétközberencs', '4525', 15),
(2647, 'Rétság', '2651', 12),
(2648, 'Révfülöp', '8253', 18),
(2649, 'Révleányvár', '3976', 4),
(2650, 'Rezi', '8373', 19),
(2651, 'Ricse', '3974', 4),
(2652, 'Rigács', '8348', 18),
(2653, 'Rigyác', '8883', 19),
(2654, 'Rimóc', '3177', 12),
(2655, 'Rinyabesenyő', '7552', 14),
(2656, 'Rinyakovácsi', '7527', 14),
(2657, 'Rinyaszentkirály', '7513', 14),
(2658, 'Rinyaújlak', '7556', 14),
(2659, 'Rinyaújnép', '7584', 14),
(2660, 'Rohod', '4563', 15),
(2661, 'Röjtökmuzsaj', '9451', 7),
(2662, 'Románd', '8434', 7),
(2663, 'Romhány', '2654', 12),
(2664, 'Romonya', '7743', 2),
(2665, 'Rönök', '9954', 17),
(2666, 'Röszke', '6758', 5),
(2667, 'Rózsafa', '7914', 2),
(2668, 'Rozsály', '4971', 15),
(2669, 'Rózsaszentmárton', '3033', 9),
(2670, 'Rudabánya', '3733', 4),
(2671, 'Rudolftelep', '3742', 4),
(2672, 'Rum', '9766', 17),
(2673, 'Ruzsa', '6786', 5),
(2674, 'Ságújfalu', '3162', 12),
(2675, 'Ságvár', '8654', 14),
(2676, 'Sajóbábony', '3792', 4),
(2677, 'Sajóecseg', '3793', 4),
(2678, 'Sajógalgóc', '3636', 4),
(2679, 'Sajóhidvég', '3576', 4),
(2680, 'Sajóivánka', '3720', 4),
(2681, 'Sajókápolna', '3773', 4),
(2682, 'Sajókaza', '3720', 4),
(2683, 'Sajókeresztúr', '3791', 4),
(2684, 'Sajólád', '3572', 4),
(2685, 'Sajólászlófalva', '3773', 4),
(2686, 'Sajómercse', '3656', 4),
(2687, 'Sajónémeti', '3652', 4),
(2688, 'Sajóörös', '3586', 4),
(2689, 'Sajópálfala', '3714', 4),
(2690, 'Sajópetri', '3573', 4),
(2691, 'Sajópüspöki', '3653', 4),
(2692, 'Sajósenye', '3712', 4),
(2693, 'Sajószentpéter', '3770', 4),
(2694, 'Sajószöged', '3599', 4),
(2695, 'Sajóvámos', '3712', 4),
(2696, 'Sajóvelezd', '3656', 4),
(2697, 'Sajtoskál', '9632', 17),
(2698, 'Salföld', '8256', 18),
(2699, 'Salgótarján', '3100', 12),
(2700, 'Salgótarján', '3102', 12),
(2701, 'Salgótarján', '3104', 12),
(2702, 'Salgótarján', '3109', 12),
(2703, 'Salgótarján', '3121', 12),
(2704, 'Salgótarján', '3141', 12),
(2705, 'Salköveskút', '9742', 17),
(2706, 'Salomvár', '8995', 19),
(2707, 'Sály', '3425', 4),
(2708, 'Sámod', '7841', 2),
(2709, 'Sámsonháza', '3074', 12),
(2710, 'Sand', '8824', 19),
(2711, 'Sándorfalva', '6762', 5),
(2712, 'Sántos', '7479', 14),
(2713, 'Sáp', '4176', 8),
(2714, 'Sáránd', '4272', 8),
(2715, 'Sárazsadány', '3942', 4),
(2716, 'Sárbogárd', '7000', 6),
(2717, 'Sárbogárd', '7003', 6),
(2718, 'Sárbogárd', '7018', 6),
(2719, 'Sárbogárd', '7019', 6),
(2720, 'Sáregres', '7014', 6),
(2721, 'Sárfimizdó', '9813', 17),
(2722, 'Sárhida', '8944', 19),
(2723, 'Sárisáp', '2523', 11),
(2724, 'Sarkad', '5720', 3),
(2725, 'Sarkadkeresztúr', '5731', 3),
(2726, 'Sárkeresztes', '8051', 6),
(2727, 'Sárkeresztúr', '8125', 6),
(2728, 'Sárkeszi', '8144', 6),
(2729, 'Sármellék', '8391', 19),
(2730, 'Sárok', '7781', 2),
(2731, 'Sárosd', '2433', 6),
(2732, 'Sárospatak', '3950', 4),
(2733, 'Sárospatak', '3952', 4),
(2734, 'Sárpilis', '7145', 16),
(2735, 'Sárrétudvari', '4171', 8),
(2736, 'Sarród', '9434', 7),
(2737, 'Sarród', '9435', 7),
(2738, 'Sárszentágota', '8126', 6),
(2739, 'Sárszentlőrinc', '7047', 16),
(2740, 'Sárszentmihály', '8141', 6),
(2741, 'Sárszentmihály', '8143', 6),
(2742, 'Sarud', '3386', 9),
(2743, 'Sárvár', '9600', 17),
(2744, 'Sárvár', '9608', 17),
(2745, 'Sárvár', '9609', 17),
(2746, 'Sásd', '7370', 2),
(2747, 'Sáska', '8308', 18),
(2748, 'Sáta', '3659', 4),
(2749, 'Sátoraljaújhely', '3944', 4),
(2750, 'Sátoraljaújhely', '3945', 4),
(2751, 'Sátoraljaújhely', '3980', 4),
(2752, 'Sátoraljaújhely', '3988', 4),
(2753, 'Sátorhely', '7785', 2),
(2754, 'Sávoly', '8732', 14),
(2755, 'Sé', '9789', 17),
(2756, 'Segesd', '7562', 14),
(2757, 'Sellye', '7960', 2),
(2758, 'Selyeb', '3809', 4),
(2759, 'Semjén', '3974', 4),
(2760, 'Semjénháza', '8862', 19),
(2761, 'Sénye', '8788', 19),
(2762, 'Sényő', '4533', 15),
(2763, 'Seregélyes', '8111', 6),
(2764, 'Serényfalva', '3729', 4),
(2765, 'Sérsekszőlős', '8660', 14),
(2766, 'Sikátor', '8439', 7),
(2767, 'Siklós', '7800', 2),
(2768, 'Siklós', '7818', 2),
(2769, 'Siklósbodony', '7814', 2),
(2770, 'Siklósnagyfalu', '7823', 2),
(2771, 'Sima', '3881', 4),
(2772, 'Simaság', '9633', 17),
(2773, 'Simonfa', '7474', 14),
(2774, 'Simontornya', '7081', 16),
(2775, 'Sióagárd', '7171', 16),
(2776, 'Siófok', '8600', 14),
(2777, 'Siófok', '8609', 14),
(2778, 'Siófok', '8611', 14),
(2779, 'Siójut', '8652', 14),
(2780, 'Sirok', '3332', 9),
(2781, 'Sitke', '9671', 17),
(2782, 'Sobor', '9315', 7),
(2783, 'Söjtör', '8897', 19),
(2784, 'Sokorópátka', '9112', 7),
(2785, 'Solt', '6320', 1),
(2786, 'Soltszentimre', '6223', 1),
(2787, 'Soltvadkert', '6230', 1),
(2788, 'Sóly', '8193', 18),
(2789, 'Solymár', '2083', 13),
(2790, 'Som', '8655', 14),
(2791, 'Somberek', '7728', 2),
(2792, 'Somlójenő', '8478', 18),
(2793, 'Somlószőlős', '8483', 18),
(2794, 'Somlóvásárhely', '8481', 18),
(2795, 'Somlóvecse', '8484', 18),
(2796, 'Somodor', '7454', 14),
(2797, 'Somogyacsa', '7283', 14),
(2798, 'Somogyapáti', '7922', 2),
(2799, 'Somogyaracs', '7584', 14),
(2800, 'Somogyaszaló', '7452', 14),
(2801, 'Somogybabod', '8684', 14),
(2802, 'Somogybükkösd', '8858', 14),
(2803, 'Somogycsicsó', '8726', 14),
(2804, 'Somogydöröcske', '7284', 14),
(2805, 'Somogyegres', '8666', 14),
(2806, 'Somogyfajsz', '8708', 14),
(2807, 'Somogygeszti', '7455', 14),
(2808, 'Somogyhárságy', '7925', 2),
(2809, 'Somogyhatvan', '7921', 2),
(2810, 'Somogyjád', '7443', 14),
(2811, 'Somogymeggyes', '8673', 14),
(2812, 'Somogysámson', '8733', 14),
(2813, 'Somogysárd', '7435', 14),
(2814, 'Somogysimonyi', '8737', 14),
(2815, 'Somogyszentpál', '8705', 14),
(2816, 'Somogyszil', '7276', 14),
(2817, 'Somogyszob', '7563', 14),
(2818, 'Somogytúr', '8683', 14),
(2819, 'Somogyudvarhely', '7515', 14),
(2820, 'Somogyvámos', '8699', 14),
(2821, 'Somogyvár', '8698', 14),
(2822, 'Somogyviszló', '7924', 2),
(2823, 'Somogyzsitfa', '8734', 14),
(2824, 'Sonkád', '4954', 15),
(2825, 'Soponya', '8123', 6),
(2826, 'Sopron', '9400', 7),
(2827, 'Sopron', '9407', 7),
(2828, 'Sopron', '9408', 7),
(2829, 'Sopron', '9494', 7),
(2830, 'Sopronhorpács', '9463', 7),
(2831, 'Sopronkövesd', '9483', 7),
(2832, 'Sopronnémeti', '9325', 7),
(2833, 'Söpte', '9743', 17),
(2834, 'Söréd', '8072', 6),
(2835, 'Sorkifalud', '9774', 17),
(2836, 'Sorkikápolna', '9774', 17),
(2837, 'Sormás', '8881', 19),
(2838, 'Sorokpolány', '9773', 17),
(2839, 'Sóshartyán', '3131', 12),
(2840, 'Sóskút', '2038', 13),
(2841, 'Sóstófalva', '3716', 4),
(2842, 'Sósvertike', '7960', 2),
(2843, 'Sótony', '9681', 17),
(2844, 'Sukoró', '8096', 6),
(2845, 'Sükösd', '6346', 1),
(2846, 'Sülysáp', '2241', 13),
(2847, 'Sülysáp', '2242', 13),
(2848, 'Sümeg', '8330', 18),
(2849, 'Sümegcsehi', '8357', 19),
(2850, 'Sümegprága', '8351', 18),
(2851, 'Sumony', '7960', 2),
(2852, 'Súr', '2889', 11),
(2853, 'Surd', '8856', 19),
(2854, 'Süttő', '2543', 11),
(2855, 'Szabadbattyán', '8151', 6),
(2856, 'Szabadegyháza', '2432', 6),
(2857, 'Szabadhidvég', '8138', 6),
(2858, 'Szabadhidvég', '8139', 6),
(2859, 'Szabadi', '7253', 14),
(2860, 'Szabadkígyós', '5712', 3),
(2861, 'Szabadszállás', '6080', 1),
(2862, 'Szabadszentkirály', '7951', 2),
(2863, 'Szabás', '7544', 14),
(2864, 'Szabolcs', '4467', 15),
(2865, 'Szabolcsbáka', '4547', 15),
(2866, 'Szabolcsveresmart', '4496', 15),
(2867, 'Szada', '2111', 13),
(2868, 'Szágy', '7383', 2),
(2869, 'Szajk', '7753', 2),
(2870, 'Szajla', '3334', 9),
(2871, 'Szajol', '5081', 10),
(2872, 'Szakácsi', '3786', 4),
(2873, 'Szakadát', '7071', 16),
(2874, 'Szakáld', '3596', 4),
(2875, 'Szakály', '7192', 16),
(2876, 'Szakcs', '7213', 16),
(2877, 'Szakmár', '6336', 1),
(2878, 'Szaknyér', '9934', 17),
(2879, 'Szakoly', '4234', 15),
(2880, 'Szakony', '9474', 7),
(2881, 'Szakonyfalu', '9983', 17),
(2882, 'Szákszend', '2856', 11),
(2883, 'Szalafő', '9942', 17),
(2884, 'Szalánta', '7811', 2),
(2885, 'Szalapa', '8341', 19),
(2886, 'Szalaszend', '3863', 4),
(2887, 'Szalatnak', '7334', 2),
(2888, 'Szálka', '7121', 16),
(2889, 'Szalkszentmárton', '6086', 1),
(2890, 'Szalmatercs', '3163', 12),
(2891, 'Szalonna', '3754', 4),
(2892, 'Szamosangyalos', '4767', 15),
(2893, 'Szamosbecs', '4745', 15),
(2894, 'Szamoskér', '4721', 15),
(2895, 'Szamossályi', '4735', 15),
(2896, 'Szamosszeg', '4824', 15),
(2897, 'Szamostatárfalva', '4746', 15),
(2898, 'Szamosújlak', '4734', 15),
(2899, 'Szanda', '2697', 12),
(2900, 'Szank', '6131', 1),
(2901, 'Szántód', '8622', 14),
(2902, 'Szany', '9317', 7),
(2903, 'Szápár', '8423', 18),
(2904, 'Szaporca', '7843', 2),
(2905, 'Szár', '2066', 6),
(2906, 'Szárász', '7184', 2),
(2907, 'Szárazd', '7063', 16),
(2908, 'Szárföld', '9353', 7),
(2909, 'Szárliget', '2067', 11),
(2910, 'Szarvas', '5540', 3),
(2911, 'Szarvasgede', '3051', 12),
(2912, 'Szarvaskend', '9913', 17),
(2913, 'Szarvaskő', '3323', 9),
(2914, 'Szászberek', '5053', 10),
(2915, 'Szászfa', '3821', 4),
(2916, 'Szászvár', '7349', 2),
(2917, 'Szatmárcseke', '4945', 15),
(2918, 'Szátok', '2656', 12),
(2919, 'Szatta', '9938', 17),
(2920, 'Szatymaz', '6763', 5),
(2921, 'Szava', '7813', 2),
(2922, 'Százhalombatta', '2440', 13),
(2923, 'Szebény', '7725', 2),
(2924, 'Szécsénke', '2692', 12),
(2925, 'Szécsény', '3170', 12),
(2926, 'Szécsényfelfalu', '3135', 12),
(2927, 'Szécsisziget', '8879', 19),
(2928, 'Szederkény', '7751', 2),
(2929, 'Szedres', '7056', 16),
(2930, 'Szeged', '6700', 5),
(2931, 'Szeged', '6710', 5),
(2932, 'Szeged', '6720', 5),
(2933, 'Szeged', '6721', 5),
(2934, 'Szeged', '6722', 5),
(2935, 'Szeged', '6723', 5),
(2936, 'Szeged', '6724', 5),
(2937, 'Szeged', '6725', 5),
(2938, 'Szeged', '6726', 5),
(2939, 'Szeged', '6727', 5),
(2940, 'Szeged', '6728', 5),
(2941, 'Szeged', '6729', 5),
(2942, 'Szeged', '6753', 5),
(2943, 'Szeged', '6757', 5),
(2944, 'Szeged', '6771', 5),
(2945, 'Szeged', '6791', 5),
(2946, 'Szegerdő', '8732', 14),
(2947, 'Szeghalom', '5520', 3),
(2948, 'Szegi', '3918', 4),
(2949, 'Szegilong', '3918', 4),
(2950, 'Szegvár', '6635', 5),
(2951, 'Székely', '4534', 15),
(2952, 'Székelyszabar', '7737', 2),
(2953, 'Székesfehérvár', '8000', 6),
(2954, 'Székesfehérvár', '8019', 6),
(2955, 'Székkutas', '6821', 5),
(2956, 'Szekszárd', '7100', 16),
(2957, 'Szeleste', '9622', 17),
(2958, 'Szelevény', '5476', 10),
(2959, 'Szellő', '7661', 2),
(2960, 'Szemely', '7763', 2),
(2961, 'Szemenye', '9685', 17),
(2962, 'Szemere', '3866', 4),
(2963, 'Szendehely', '2640', 12),
(2964, 'Szendrő', '3752', 4),
(2965, 'Szendrőlád', '3751', 4),
(2966, 'Szenna', '7477', 14),
(2967, 'Szenta', '8849', 14),
(2968, 'Szentantalfa', '8272', 18),
(2969, 'Szentbalázs', '7472', 14),
(2970, 'Szentbékkálla', '8281', 18),
(2971, 'Szentborbás', '7918', 14),
(2972, 'Szentdénes', '7913', 2),
(2973, 'Szentdomonkos', '3259', 9),
(2974, 'Szente', '2655', 12),
(2975, 'Szentegát', '7915', 2),
(2976, 'Szentendre', '2000', 13),
(2977, 'Szentes', '6600', 5),
(2978, 'Szentgál', '8444', 18),
(2979, 'Szentgáloskér', '7465', 14),
(2980, 'Szentgotthárd', '9955', 17),
(2981, 'Szentgotthárd', '9970', 17),
(2982, 'Szentgotthárd', '9981', 17),
(2983, 'Szentgyörgyvár', '8393', 19),
(2984, 'Szentgyörgyvölgy', '8975', 19),
(2985, 'Szentimrefalva', '8475', 18),
(2986, 'Szentistván', '3418', 4),
(2987, 'Szentistvánbaksa', '3844', 4),
(2988, 'Szentjakabfa', '8272', 18),
(2989, 'Szentkatalin', '7681', 2),
(2990, 'Szentkirály', '6031', 1),
(2991, 'Szentkirályszabadja', '8225', 18),
(2992, 'Szentkozmadombja', '8947', 19),
(2993, 'Szentlászló', '7936', 2),
(2994, 'Szentliszló', '8893', 19),
(2995, 'Szentlőrinc', '7940', 2),
(2996, 'Szentlőrinckáta', '2255', 13),
(2997, 'Szentmargitfalva', '8872', 19),
(2998, 'Szentmártonkáta', '2254', 13),
(2999, 'Szentpéterfa', '9799', 17),
(3000, 'Szentpéterfölde', '8953', 19),
(3001, 'Szentpéterszeg', '4121', 8),
(3002, 'Szentpéterúr', '8762', 19),
(3003, 'Szenyér', '8717', 14),
(3004, 'Szepetnek', '8861', 19),
(3005, 'Szerecseny', '9125', 7),
(3006, 'Szeremle', '6512', 1),
(3007, 'Szerencs', '3900', 4),
(3008, 'Szerep', '4162', 8),
(3009, 'Szerep', '4163', 8),
(3010, 'Szergény', '9523', 17),
(3011, 'Szigetbecse', '2321', 13),
(3012, 'Szigetcsép', '2317', 13),
(3013, 'Szigethalom', '2315', 13),
(3014, 'Szigetmonostor', '2015', 13),
(3015, 'Szigetszentmárton', '2318', 13),
(3016, 'Szigetszentmiklós', '2310', 13),
(3017, 'Szigetújfalu', '2319', 13),
(3018, 'Szigetvár', '7900', 2),
(3019, 'Szigliget', '8264', 18),
(3020, 'Szihalom', '3377', 9),
(3021, 'Szijártóháza', '8969', 19),
(3022, 'Szikszó', '3800', 4),
(3023, 'Szil', '9326', 7),
(3024, 'Szilágy', '7664', 2),
(3025, 'Szilaspogony', '3125', 12),
(3026, 'Szilsárkány', '9312', 7),
(3027, 'Szilvágy', '8986', 19),
(3028, 'Szilvás', '7811', 2),
(3029, 'Szilvásszentmárton', '7477', 14),
(3030, 'Szilvásvárad', '3348', 9),
(3031, 'Szin', '3761', 4),
(3032, 'Szinpetri', '3761', 4),
(3033, 'Szirák', '3044', 12),
(3034, 'Szirmabesenyő', '3711', 4),
(3035, 'Szob', '2628', 13),
(3036, 'Szőc', '8452', 18),
(3037, 'Szőce', '9935', 17),
(3038, 'Sződ', '2134', 13),
(3039, 'Sződliget', '2133', 13),
(3040, 'Szögliget', '3762', 4),
(3041, 'Szőke', '7833', 2),
(3042, 'Szőkéd', '7763', 2),
(3043, 'Szőkedencs', '8736', 14),
(3044, 'Szokolya', '2624', 13),
(3045, 'Szólád', '8625', 14),
(3046, 'Szolnok', '5000', 10),
(3047, 'Szolnok', '5008', 10),
(3048, 'Szőlősardó', '3757', 4),
(3049, 'Szőlősgyörök', '8692', 14),
(3050, 'Szombathely', '9700', 17),
(3051, 'Szombathely', '9707', 17),
(3052, 'Szombathely', '9719', 17),
(3053, 'Szomód', '2896', 11),
(3054, 'Szomolya', '3411', 4),
(3055, 'Szomor', '2822', 11),
(3056, 'Szörény', '7976', 2),
(3057, 'Szorgalmatos', '4441', 15),
(3058, 'Szorosad', '7285', 14),
(3059, 'Szúcs', '3341', 9),
(3060, 'Szűcsi', '3034', 9),
(3061, 'Szügy', '2699', 12),
(3062, 'Szuha', '3154', 12),
(3063, 'Szuhafő', '3726', 4),
(3064, 'Szuhakálló', '3731', 4),
(3065, 'Szuhogy', '3734', 4),
(3066, 'Szulimán', '7932', 2),
(3067, 'Szulok', '7539', 14),
(3068, 'Szűr', '7735', 2),
(3069, 'Szurdokpüspöki', '3064', 12),
(3070, 'Tab', '8660', 14),
(3071, 'Tabajd', '8088', 6),
(3072, 'Tabdi', '6224', 1),
(3073, 'Táborfalva', '2381', 13),
(3074, 'Tác', '8121', 6),
(3075, 'Tagyon', '8272', 18),
(3076, 'Tahitótfalu', '2021', 13),
(3077, 'Tahitótfalu', '2022', 13),
(3078, 'Takácsi', '8541', 18),
(3079, 'Tákos', '4845', 15),
(3080, 'Taksony', '2335', 13),
(3081, 'Taktabáj', '3926', 4),
(3082, 'Taktaharkány', '3922', 4),
(3083, 'Taktakenéz', '3924', 4),
(3084, 'Taktaszada', '3921', 4),
(3085, 'Taliándörögd', '8295', 18),
(3086, 'Tállya', '3907', 4),
(3087, 'Tamási', '7090', 16),
(3088, 'Tamási', '7091', 16),
(3089, 'Tanakajd', '9762', 17),
(3090, 'Táp', '9095', 7),
(3091, 'Tápióbicske', '2764', 13),
(3092, 'Tápiógyörgye', '2767', 13),
(3093, 'Tápióság', '2253', 13),
(3094, 'Tápiószecső', '2251', 13),
(3095, 'Tápiószele', '2766', 13),
(3096, 'Tápiószentmárton', '2711', 13),
(3097, 'Tápiószőlős', '2769', 13),
(3098, 'Táplánszentkereszt', '9761', 17),
(3099, 'Tapolca', '8297', 18),
(3100, 'Tapolca', '8300', 18),
(3101, 'Tapsony', '8718', 14),
(3102, 'Tápszentmiklós', '9094', 7),
(3103, 'Tar', '3073', 12),
(3104, 'Tarany', '7514', 14),
(3105, 'Tarcal', '3915', 4),
(3106, 'Tard', '3416', 4),
(3107, 'Tardona', '3644', 4),
(3108, 'Tardos', '2834', 11),
(3109, 'Tarhos', '5641', 3),
(3110, 'Tarján', '2831', 11),
(3111, 'Tarjánpuszta', '9092', 7),
(3112, 'Tárkány', '2945', 11),
(3113, 'Tarnabod', '3369', 9),
(3114, 'Tarnalelesz', '3258', 9),
(3115, 'Tarnaméra', '3284', 9),
(3116, 'Tarnaörs', '3294', 9),
(3117, 'Tarnaszentmária', '3331', 9),
(3118, 'Tarnaszentmiklós', '3382', 9),
(3119, 'Tarnazsadány', '3283', 9),
(3120, 'Tárnok', '2461', 13),
(3121, 'Tárnokréti', '9165', 7),
(3122, 'Tarpa', '4931', 15),
(3123, 'Tarrós', '7362', 2),
(3124, 'Táska', '8696', 14),
(3125, 'Tass', '6098', 1),
(3126, 'Taszár', '7261', 14),
(3127, 'Tát', '2534', 11),
(3128, 'Tata', '2835', 11),
(3129, 'Tata', '2890', 11),
(3130, 'Tatabánya', '2800', 11),
(3131, 'Tataháza', '6451', 1),
(3132, 'Tatárszentgyörgy', '2375', 13),
(3133, 'Tázlár', '6236', 1),
(3134, 'Téglás', '4243', 8),
(3135, 'Tékes', '7381', 2),
(3136, 'Teklafalu', '7973', 2),
(3137, 'Telekes', '9812', 17),
(3138, 'Telekgerendás', '5675', 3),
(3139, 'Teleki', '8626', 14),
(3140, 'Telki', '2089', 13),
(3141, 'Telkibánya', '3896', 4),
(3142, 'Tengelic', '7054', 16),
(3143, 'Tengeri', '7834', 2),
(3144, 'Tengőd', '8668', 14),
(3145, 'Tenk', '3359', 9),
(3146, 'Tényő', '9111', 7),
(3147, 'Tépe', '4132', 8),
(3148, 'Terem', '4342', 15),
(3149, 'Terény', '2696', 12),
(3150, 'Tereske', '2652', 12),
(3151, 'Teresztenye', '3757', 4),
(3152, 'Terpes', '3334', 9),
(3153, 'Tés', '8109', 18),
(3154, 'Tésa', '2635', 13),
(3155, 'Tésenfa', '7843', 2),
(3156, 'Téseny', '7834', 2),
(3157, 'Teskánd', '8991', 19),
(3158, 'Tét', '9100', 7),
(3159, 'Tetétlen', '4184', 8),
(3160, 'Tevel', '7181', 16),
(3161, 'Tibolddaróc', '3423', 4),
(3162, 'Tiborszállás', '4353', 15),
(3163, 'Tihany', '8237', 18),
(3164, 'Tikos', '8731', 14),
(3165, 'Tilaj', '8782', 19),
(3166, 'Timár', '4466', 15),
(3167, 'Tinnye', '2086', 13),
(3168, 'Tiszaadony', '4833', 15),
(3169, 'Tiszaalpár', '6066', 1),
(3170, 'Tiszaalpár', '6067', 1),
(3171, 'Tiszabábolna', '3465', 4),
(3172, 'Tiszabecs', '4951', 15),
(3173, 'Tiszabercel', '4474', 15),
(3174, 'Tiszabezdéd', '4624', 15),
(3175, 'Tiszabő', '5232', 10),
(3176, 'Tiszabura', '5235', 10),
(3177, 'Tiszacsécse', '4947', 15),
(3178, 'Tiszacsege', '4066', 8),
(3179, 'Tiszacsermely', '3972', 4),
(3180, 'Tiszadada', '4455', 15),
(3181, 'Tiszaderzs', '5243', 10),
(3182, 'Tiszadob', '4456', 15),
(3183, 'Tiszadorogma', '3466', 4),
(3184, 'Tiszaeszlár', '4446', 15),
(3185, 'Tiszaeszlár', '4464', 15),
(3186, 'Tiszaföldvár', '5430', 10),
(3187, 'Tiszaföldvár', '5461', 10),
(3188, 'Tiszafüred', '5350', 10),
(3189, 'Tiszafüred', '5358', 10),
(3190, 'Tiszafüred', '5359', 10),
(3191, 'Tiszagyenda', '5233', 10),
(3192, 'Tiszagyulaháza', '4097', 8),
(3193, 'Tiszaigar', '5361', 10),
(3194, 'Tiszainoka', '5464', 10),
(3195, 'Tiszajenő', '5094', 10),
(3196, 'Tiszakanyár', '4493', 15),
(3197, 'Tiszakarád', '3971', 4),
(3198, 'Tiszakécske', '6060', 1),
(3199, 'Tiszakécske', '6062', 1),
(3200, 'Tiszakerecseny', '4834', 15),
(3201, 'Tiszakeszi', '3458', 4),
(3202, 'Tiszakóród', '4946', 15),
(3203, 'Tiszakürt', '5471', 10),
(3204, 'Tiszakürt', '5472', 10),
(3205, 'Tiszaladány', '3929', 4),
(3206, 'Tiszalök', '4447', 15),
(3207, 'Tiszalök', '4450', 15),
(3208, 'Tiszalúc', '3565', 4),
(3209, 'Tiszamogyorós', '4645', 15),
(3210, 'Tiszanagyfalu', '4463', 15),
(3211, 'Tiszanána', '3385', 9),
(3212, 'Tiszaörs', '5362', 10),
(3213, 'Tiszapalkonya', '3587', 4),
(3214, 'Tiszapüspöki', '5211', 10),
(3215, 'Tiszarád', '4503', 15),
(3216, 'Tiszaroff', '5234', 10),
(3217, 'Tiszasas', '5474', 10),
(3218, 'Tiszasüly', '5061', 10),
(3219, 'Tiszaszalka', '4831', 15),
(3220, 'Tiszaszentimre', '5322', 10),
(3221, 'Tiszaszentimre', '5323', 10),
(3222, 'Tiszaszentmárton', '4628', 15),
(3223, 'Tiszasziget', '6756', 5),
(3224, 'Tiszaszőlős', '5244', 10),
(3225, 'Tiszatardos', '3928', 4),
(3226, 'Tiszatarján', '3589', 4),
(3227, 'Tiszatelek', '4486', 15),
(3228, 'Tiszatelek', '4487', 15),
(3229, 'Tiszatenyő', '5082', 10),
(3230, 'Tiszaug', '6064', 1),
(3231, 'Tiszaújváros', '3580', 4),
(3232, 'Tiszavalk', '3464', 4),
(3233, 'Tiszavárkony', '5092', 10),
(3234, 'Tiszavárkony', '5095', 10),
(3235, 'Tiszavasvári', '4440', 15),
(3236, 'Tiszavid', '4832', 15),
(3237, 'Tisztaberek', '4969', 15),
(3238, 'Tivadar', '4921', 15),
(3239, 'Tóalmás', '2252', 13),
(3240, 'Tófalu', '3354', 9),
(3241, 'Tófej', '8946', 19),
(3242, 'Tófű', '7348', 2),
(3243, 'Tök', '2073', 13),
(3244, 'Tokaj', '3910', 4),
(3245, 'Tokod', '2531', 11),
(3246, 'Tokodaltáró', '2532', 11),
(3247, 'Tököl', '2316', 13),
(3248, 'Tokorcs', '9561', 17),
(3249, 'Tolcsva', '3934', 4),
(3250, 'Told', '4117', 8),
(3251, 'Tolmács', '2657', 12),
(3252, 'Tolna', '7130', 16),
(3253, 'Tolna', '7131', 16),
(3254, 'Tolnanémedi', '7083', 16),
(3255, 'Töltéstava', '9086', 7),
(3256, 'Tomajmonostora', '5324', 10),
(3257, 'Tomor', '3787', 4),
(3258, 'Tömörd', '9738', 17),
(3259, 'Tömörkény', '6646', 5),
(3260, 'Tompa', '6422', 1),
(3261, 'Tompaládony', '9662', 17),
(3262, 'Tordas', '2463', 6),
(3263, 'Tormafölde', '8876', 19),
(3264, 'Tormás', '7383', 2),
(3265, 'Tormásliget', '9736', 17),
(3266, 'Tornabarakony', '3765', 4),
(3267, 'Tornakápolna', '3761', 4),
(3268, 'Tornanádaska', '3767', 4),
(3269, 'Tornaszentandrás', '3765', 4),
(3270, 'Tornaszentjakab', '3769', 4),
(3271, 'Tornyiszentmiklós', '8877', 19),
(3272, 'Tornyosnémeti', '3877', 4),
(3273, 'Tornyospálca', '4642', 15),
(3274, 'Törökbálint', '2045', 13),
(3275, 'Törökkoppány', '7285', 14),
(3276, 'Törökszentmiklós', '5200', 10),
(3277, 'Törökszentmiklós', '5212', 10),
(3278, 'Torony', '9791', 17),
(3279, 'Törtel', '2747', 13),
(3280, 'Torvaj', '8660', 14),
(3281, 'Tószeg', '5091', 10),
(3282, 'Tótkomlós', '5940', 3),
(3283, 'Tótszentgyörgy', '7981', 2),
(3284, 'Tótszentmárton', '8865', 19),
(3285, 'Tótszerdahely', '8864', 19),
(3286, 'Töttös', '7755', 2),
(3287, 'Tótújfalu', '7918', 14),
(3288, 'Tótvázsony', '8246', 18),
(3289, 'Trizs', '3724', 4),
(3290, 'Tunyogmatolcs', '4731', 15),
(3291, 'Tura', '2194', 13),
(3292, 'Túristvándi', '4944', 15),
(3293, 'Türje', '8796', 19),
(3294, 'Túrkeve', '5420', 10),
(3295, 'Túrony', '7811', 2),
(3296, 'Túrricse', '4968', 15),
(3297, 'Tüskevár', '8477', 18),
(3298, 'Tuzsér', '4623', 15),
(3299, 'Tyukod', '4762', 15),
(3300, 'Udvar', '7718', 2),
(3301, 'Udvari', '7066', 16),
(3302, 'Ugod', '8564', 18),
(3303, 'Újbarok', '2066', 6),
(3304, 'Újcsanálos', '3716', 4),
(3305, 'Újdombrád', '4491', 15),
(3306, 'Újfehértó', '4244', 15),
(3307, 'Újhartyán', '2367', 13),
(3308, 'Újiráz', '4146', 8),
(3309, 'Újireg', '7095', 16),
(3310, 'Újkenéz', '4635', 15),
(3311, 'Újkér', '9472', 7),
(3312, 'Újkígyós', '5661', 3),
(3313, 'Újlengyel', '2724', 13),
(3314, 'Újléta', '4288', 8),
(3315, 'Újlőrincfalva', '3387', 9),
(3316, 'Újpetre', '7766', 2),
(3317, 'Újrónafő', '9244', 7),
(3318, 'Újsolt', '6320', 1),
(3319, 'Újszalonta', '5727', 3),
(3320, 'Újszász', '5052', 10),
(3321, 'Újszentiván', '6754', 5),
(3322, 'Újszentmargita', '4065', 8),
(3323, 'Újszilvás', '2768', 13),
(3324, 'Újtelek', '6337', 1),
(3325, 'Újtikos', '4096', 8),
(3326, 'Újudvar', '8778', 19),
(3327, 'Újvárfalva', '7436', 14),
(3328, 'Ukk', '8347', 18),
(3329, 'Üllés', '6794', 5),
(3330, 'Üllő', '2225', 13),
(3331, 'Und', '9464', 7),
(3332, 'Úny', '2528', 11),
(3333, 'Uppony', '3622', 4),
(3334, 'Ura', '4763', 15),
(3335, 'Uraiújfalu', '9651', 17),
(3336, 'Úrhida', '8142', 6),
(3337, 'Úri', '2244', 13),
(3338, 'Úrkút', '8409', 18),
(3339, 'Üröm', '2096', 13),
(3340, 'Uszka', '4952', 15),
(3341, 'Uszód', '6332', 1),
(3342, 'Uzsa', '8321', 18),
(3343, 'Vác', '2600', 13),
(3344, 'Vácduka', '2167', 13),
(3345, 'Vácegres', '2184', 13),
(3346, 'Váchartyán', '2164', 13),
(3347, 'Váckisújfalu', '2185', 13),
(3348, 'Vácrátót', '2163', 13),
(3349, 'Vácszentlászló', '2115', 13),
(3350, 'Vadna', '3636', 4),
(3351, 'Vadosfa', '9346', 7),
(3352, 'Vág', '9327', 7),
(3353, 'Vágáshuta', '3992', 4),
(3354, 'Vaja', '4562', 15),
(3355, 'Vajdácska', '3961', 4),
(3356, 'Vajszló', '7838', 2),
(3357, 'Vajta', '7041', 6),
(3358, 'Vál', '2473', 6),
(3359, 'Valkó', '2114', 13),
(3360, 'Valkonya', '8885', 19);
INSERT INTO `city` (`city_id`, `city_name`, `postal_code`, `region_id`) VALUES
(3361, 'Vállaj', '4351', 15),
(3362, 'Vállus', '8316', 19),
(3363, 'Vámosatya', '4936', 15),
(3364, 'Vámoscsalád', '9665', 17),
(3365, 'Vámosgyörk', '3291', 9),
(3366, 'Vámosmikola', '2635', 13),
(3367, 'Vámosoroszi', '4966', 15),
(3368, 'Vámospércs', '4287', 8),
(3369, 'Vámosszabadi', '9061', 7),
(3370, 'Vámosújfalu', '3941', 4),
(3371, 'Váncsod', '4119', 8),
(3372, 'Vanyarc', '2688', 12),
(3373, 'Vanyola', '8552', 18),
(3374, 'Várad', '7973', 2),
(3375, 'Váralja', '7354', 16),
(3376, 'Varászló', '8723', 14),
(3377, 'Váraszó', '3254', 9),
(3378, 'Várbalog', '9243', 7),
(3379, 'Varbó', '3778', 4),
(3380, 'Varbóc', '3756', 4),
(3381, 'Várda', '7442', 14),
(3382, 'Várdomb', '7146', 16),
(3383, 'Várfölde', '8891', 19),
(3384, 'Varga', '7370', 2),
(3385, 'Várgesztes', '2824', 11),
(3386, 'Várkesző', '8523', 18),
(3387, 'Várong', '7214', 16),
(3388, 'Városföld', '6033', 1),
(3389, 'Városlőd', '8445', 18),
(3390, 'Várpalota', '8100', 18),
(3391, 'Várpalota', '8103', 18),
(3392, 'Várpalota', '8104', 18),
(3393, 'Varsád', '7067', 16),
(3394, 'Varsány', '3178', 12),
(3395, 'Várvölgy', '8316', 19),
(3396, 'Vasad', '2211', 13),
(3397, 'Vasalja', '9921', 17),
(3398, 'Vásárosbéc', '7926', 2),
(3399, 'Vásárosdombó', '7362', 2),
(3400, 'Vásárosfalu', '9343', 7),
(3401, 'Vásárosmiske', '9552', 17),
(3402, 'Vásárosnamény', '4800', 15),
(3403, 'Vásárosnamény', '4803', 15),
(3404, 'Vásárosnamény', '4804', 15),
(3405, 'Vasasszonyfa', '9744', 17),
(3406, 'Vasboldogasszony', '8914', 19),
(3407, 'Vasegerszeg', '9661', 17),
(3408, 'Vashosszúfalu', '9674', 17),
(3409, 'Vaskeresztes', '9795', 17),
(3410, 'Vaskút', '6521', 1),
(3411, 'Vasmegyer', '4502', 15),
(3412, 'Vaspör', '8998', 19),
(3413, 'Vassurány', '9741', 17),
(3414, 'Vasszécseny', '9763', 17),
(3415, 'Vasszentmihály', '9953', 17),
(3416, 'Vasszilvágy', '9747', 17),
(3417, 'Vasvár', '9800', 17),
(3418, 'Vaszar', '8542', 18),
(3419, 'Vászoly', '8245', 18),
(3420, 'Vát', '9748', 17),
(3421, 'Vatta', '3431', 4),
(3422, 'Vázsnok', '7370', 2),
(3423, 'Vécs', '3265', 9),
(3424, 'Vecsés', '2220', 13),
(3425, 'Végegyháza', '5811', 3),
(3426, 'Vejti', '7838', 2),
(3427, 'Vékény', '7333', 2),
(3428, 'Vekerd', '4143', 8),
(3429, 'Velem', '9726', 17),
(3430, 'Velemér', '9946', 17),
(3431, 'Velence', '2481', 6),
(3432, 'Velény', '7951', 2),
(3433, 'Véménd', '7726', 2),
(3434, 'Vének', '9062', 7),
(3435, 'Vép', '9751', 17),
(3436, 'Vereb', '2477', 6),
(3437, 'Veresegyház', '2112', 13),
(3438, 'Verőce', '2621', 13),
(3439, 'Verpelét', '3351', 9),
(3440, 'Verseg', '2174', 13),
(3441, 'Versend', '7752', 2),
(3442, 'Vértesacsa', '8089', 6),
(3443, 'Vértesboglár', '8085', 6),
(3444, 'Vérteskethely', '2859', 11),
(3445, 'Vértessomló', '2823', 11),
(3446, 'Vértesszőlős', '2837', 11),
(3447, 'Vértestolna', '2833', 11),
(3448, 'Vése', '8721', 14),
(3449, 'Veszkény', '9352', 7),
(3450, 'Veszprém', '8200', 18),
(3451, 'Veszprém', '8411', 18),
(3452, 'Veszprém', '8412', 18),
(3453, 'Veszprémfajsz', '8248', 18),
(3454, 'Veszprémgalsa', '8475', 18),
(3455, 'Veszprémvarsány', '8438', 7),
(3456, 'Vésztő', '5530', 3),
(3457, 'Vezseny', '5093', 10),
(3458, 'Vid', '8484', 18),
(3459, 'Vigántpetend', '8294', 18),
(3460, 'Villány', '7773', 2),
(3461, 'Villánykövesd', '7772', 2),
(3462, 'Vilmány', '3891', 4),
(3463, 'Vilonya', '8194', 18),
(3464, 'Vilyvitány', '3991', 4),
(3465, 'Vinár', '9535', 18),
(3466, 'Vindornyafok', '8354', 19),
(3467, 'Vindornyalak', '8353', 19),
(3468, 'Vindornyaszőlős', '8355', 19),
(3469, 'Visegrád', '2025', 13),
(3470, 'Visegrád', '2026', 13),
(3471, 'Visnye', '7533', 14),
(3472, 'Visonta', '3271', 9),
(3473, 'Visonta', '3272', 9),
(3474, 'Viss', '3956', 4),
(3475, 'Visz', '8681', 14),
(3476, 'Viszák', '9932', 17),
(3477, 'Viszló', '3825', 4),
(3478, 'Visznek', '3293', 9),
(3479, 'Vitnyéd', '9371', 7),
(3480, 'Vizslás', '3128', 12),
(3481, 'Vizsoly', '3888', 4),
(3482, 'Vízvár', '7588', 14),
(3483, 'Vöckönd', '8931', 19),
(3484, 'Vokány', '7768', 2),
(3485, 'Völcsej', '9462', 7),
(3486, 'Vönöck', '9516', 17),
(3487, 'Vonyarcvashegy', '8314', 19),
(3488, 'Vöröstó', '8291', 18),
(3489, 'Vörs', '8711', 14),
(3490, 'Zabar', '3124', 12),
(3491, 'Zádor', '7976', 2),
(3492, 'Zádorfalva', '3726', 4),
(3493, 'Zagyvarékas', '5051', 10),
(3494, 'Zagyvaszántó', '3031', 9),
(3495, 'Záhony', '4625', 15),
(3496, 'Zajk', '8868', 19),
(3497, 'Zajta', '4974', 15),
(3498, 'Zákány', '8852', 14),
(3499, 'Zákányfalu', '8853', 14),
(3500, 'Zákányszék', '6787', 5),
(3501, 'Zala', '8660', 14),
(3502, 'Zalaapáti', '8741', 19),
(3503, 'Zalabaksa', '8971', 19),
(3504, 'Zalabér', '8798', 19),
(3505, 'Zalaboldogfa', '8992', 19),
(3506, 'Zalacsány', '8782', 19),
(3507, 'Zalacséb', '8996', 19),
(3508, 'Zalaegerszeg', '8900', 19),
(3509, 'Zalaerdőd', '8344', 18),
(3510, 'Zalagyömörő', '8349', 18),
(3511, 'Zalahaláp', '8308', 18),
(3512, 'Zalaháshágy', '8997', 19),
(3513, 'Zalaigrice', '8761', 19),
(3514, 'Zalaistvánd', '8932', 19),
(3515, 'Zalakaros', '8749', 19),
(3516, 'Zalakomár', '8751', 19),
(3517, 'Zalakomár', '8752', 19),
(3518, 'Zalaköveskút', '8354', 19),
(3519, 'Zalalövő', '8999', 19),
(3520, 'Zalameggyes', '8348', 18),
(3521, 'Zalamerenye', '8747', 19),
(3522, 'Zalasárszeg', '8756', 19),
(3523, 'Zalaszabar', '8743', 19),
(3524, 'Zalaszántó', '8353', 19),
(3525, 'Zalaszegvár', '8476', 18),
(3526, 'Zalaszentbalázs', '8772', 19),
(3527, 'Zalaszentgrót', '8785', 19),
(3528, 'Zalaszentgrót', '8789', 19),
(3529, 'Zalaszentgrót', '8790', 19),
(3530, 'Zalaszentgrót', '8793', 19),
(3531, 'Zalaszentgrót', '8795', 19),
(3532, 'Zalaszentgyörgy', '8994', 19),
(3533, 'Zalaszentiván', '8921', 19),
(3534, 'Zalaszentjakab', '8827', 19),
(3535, 'Zalaszentlászló', '8788', 19),
(3536, 'Zalaszentlőrinc', '8921', 19),
(3537, 'Zalaszentmárton', '8764', 19),
(3538, 'Zalaszentmihály', '8936', 19),
(3539, 'Zalaszombatfa', '8969', 19),
(3540, 'Zaláta', '7839', 2),
(3541, 'Zalatárnok', '8947', 19),
(3542, 'Zalaújlak', '8822', 19),
(3543, 'Zalavár', '8392', 19),
(3544, 'Zalavég', '8792', 19),
(3545, 'Zalkod', '3957', 4),
(3546, 'Zamárdi', '8621', 14),
(3547, 'Zámoly', '8081', 6),
(3548, 'Zánka', '8251', 18),
(3549, 'Zaránk', '3296', 9),
(3550, 'Závod', '7182', 16),
(3551, 'Zebecke', '8957', 19),
(3552, 'Zebegény', '2627', 13),
(3553, 'Zemplénagárd', '3977', 4),
(3554, 'Zengővárkony', '7720', 2),
(3555, 'Zichyújfalu', '8112', 6),
(3556, 'Zics', '8672', 14),
(3557, 'Ziliz', '3794', 4),
(3558, 'Zimány', '7471', 14),
(3559, 'Zirc', '8420', 18),
(3560, 'Zók', '7671', 2),
(3561, 'Zomba', '7173', 16),
(3562, 'Zsadány', '5537', 3),
(3563, 'Zsáka', '4142', 8),
(3564, 'Zsámbék', '2072', 13),
(3565, 'Zsámbok', '2116', 13),
(3566, 'Zsana', '6411', 1),
(3567, 'Zsarolyán', '4961', 15),
(3568, 'Zsebeháza', '9346', 7),
(3569, 'Zsédeny', '9635', 17),
(3570, 'Zselickisfalud', '7477', 14),
(3571, 'Zselickislak', '7400', 14),
(3572, 'Zselicszentpál', '7474', 14),
(3573, 'Zsennye', '9766', 17),
(3574, 'Zsira', '9476', 7),
(3575, 'Zsombó', '6792', 5),
(3576, 'Zsujta', '3897', 4),
(3577, 'Zsurk', '4627', 15),
(3578, 'Zubogy', '3723', 4);

-- --------------------------------------------------------

--
-- Table structure for table `follower_relations`
--

CREATE TABLE `follower_relations` (
  `follower_id` int(11) NOT NULL,
  `following_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `material`
--

CREATE TABLE `material` (
  `material_id` int(11) NOT NULL,
  `material_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `material`
--

INSERT INTO `material` (`material_id`, `material_name`) VALUES
(1, 'arany'),
(2, 'ezüst'),
(3, 'ásvány'),
(4, 'nemesfém'),
(5, 'drágakő'),
(6, 'tehéntej'),
(7, 'kecsketej'),
(8, 'liszt'),
(9, 'barack'),
(10, 'cukor'),
(11, 'kakaó'),
(12, 'élesztő');

-- --------------------------------------------------------

--
-- Table structure for table `member`
--

CREATE TABLE `member` (
  `member_id` int(11) NOT NULL,
  `first_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `email` varchar(320) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `password` varchar(64) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `phone` varchar(15) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `about` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `profile_picture_link` varchar(200) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `header_picture_link` varchar(200) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `registered_at` datetime NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `is_vendor` tinyint(1) NOT NULL,
  `is_admin` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `reciver_id` int(11) NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `notification_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `reciver_id` int(11) NOT NULL,
  `content` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `type` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `link` varchar(100) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `seen` tinyint(1) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `product_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `description` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `inventory` int(11) DEFAULT NULL,
  `delivery` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `category` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `discount` int(11) DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  `is_removed` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_material`
--

CREATE TABLE `product_material` (
  `product_material_id` int(11) NOT NULL,
  `material_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_picture`
--

CREATE TABLE `product_picture` (
  `product_picture_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `resource_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `resource_link` varchar(100) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `is_thumbnail` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_tag`
--

CREATE TABLE `product_tag` (
  `product_tag_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `region`
--

CREATE TABLE `region` (
  `region_id` int(11) NOT NULL,
  `region_name` varchar(50) COLLATE utf8mb4_hungarian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `region`
--

INSERT INTO `region` (`region_id`, `region_name`) VALUES
(1, 'Bács-Kiskun'),
(2, 'Baranya'),
(3, 'Békés'),
(4, 'Borsod-Abaúj-Zemplén'),
(5, 'Csongrád-Csanád'),
(6, 'Fejér'),
(7, 'Győr-Moson-Sopron'),
(8, 'Hajdú-Bihar'),
(9, 'Heves'),
(10, 'Jász-Nagykun-Szolnok'),
(11, 'Komárom-Esztergom'),
(12, 'Nógrád'),
(13, 'Pest'),
(14, 'Somogy'),
(15, 'Szabolcs-Szatmár-Bereg'),
(16, 'Tolna'),
(17, 'Vas'),
(18, 'Veszprém'),
(19, 'Zala'),
(20, 'Budapest (főváros)');

-- --------------------------------------------------------

--
-- Table structure for table `review`
--

CREATE TABLE `review` (
  `review_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `title` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `published_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `review_vote`
--

CREATE TABLE `review_vote` (
  `review_vote_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `review_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `vote` varchar(10) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `voted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `session`
--

CREATE TABLE `session` (
  `session_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `jwt` varchar(1000) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `logged_in_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shipping_address`
--

CREATE TABLE `shipping_address` (
  `shipping_address_id` int(11) NOT NULL,
  `member_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `first_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `email` varchar(320) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `country` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `region` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `street_adress` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `postal_code` varchar(4) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tag`
--

CREATE TABLE `tag` (
  `tag_id` int(11) NOT NULL,
  `tag_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `tag`
--

INSERT INTO `tag` (`tag_id`, `tag_name`) VALUES
(1, 'Környezetbarát'),
(2, 'Kézzel készült'),
(3, 'Etikusan beszerzett alapanyagok'),
(4, 'Fenntartható'),
(5, 'Csomagolás mentes'),
(6, 'Vegetáriánus'),
(7, 'Vegán'),
(8, 'Bio');

-- --------------------------------------------------------

--
-- Table structure for table `vendor_detail`
--

CREATE TABLE `vendor_detail` (
  `vendor_detail_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `company_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `site_location` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `website` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `takes_custom_orders` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wish_list`
--

CREATE TABLE `wish_list` (
  `wish_list_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `added_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `shipping_address_id` (`shipping_address_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `cart_product`
--
ALTER TABLE `cart_product`
  ADD PRIMARY KEY (`cart_product_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `cart_id` (`cart_id`);

--
-- Indexes for table `city`
--
ALTER TABLE `city`
  ADD PRIMARY KEY (`city_id`),
  ADD KEY `region_id` (`region_id`);

--
-- Indexes for table `follower_relations`
--
ALTER TABLE `follower_relations`
  ADD PRIMARY KEY (`follower_id`,`following_id`),
  ADD KEY `following_id` (`following_id`);

--
-- Indexes for table `material`
--
ALTER TABLE `material`
  ADD PRIMARY KEY (`material_id`);

--
-- Indexes for table `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`member_id`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `reciver_id` (`reciver_id`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `reciver_id` (`reciver_id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `vendor_id` (`vendor_id`);

--
-- Indexes for table `product_material`
--
ALTER TABLE `product_material`
  ADD PRIMARY KEY (`product_material_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `material_id` (`material_id`);

--
-- Indexes for table `product_picture`
--
ALTER TABLE `product_picture`
  ADD PRIMARY KEY (`product_picture_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `product_tag`
--
ALTER TABLE `product_tag`
  ADD PRIMARY KEY (`product_tag_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `tag_id` (`tag_id`);

--
-- Indexes for table `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`region_id`);

--
-- Indexes for table `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `review_vote`
--
ALTER TABLE `review_vote`
  ADD PRIMARY KEY (`review_vote_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `review_id` (`review_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `session`
--
ALTER TABLE `session`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `session_ibfk_1` (`member_id`);

--
-- Indexes for table `shipping_address`
--
ALTER TABLE `shipping_address`
  ADD PRIMARY KEY (`shipping_address_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `tag`
--
ALTER TABLE `tag`
  ADD PRIMARY KEY (`tag_id`);

--
-- Indexes for table `vendor_detail`
--
ALTER TABLE `vendor_detail`
  ADD PRIMARY KEY (`vendor_detail_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `wish_list`
--
ALTER TABLE `wish_list`
  ADD PRIMARY KEY (`wish_list_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `member_id` (`member_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cart_product`
--
ALTER TABLE `cart_product`
  MODIFY `cart_product_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `city`
--
ALTER TABLE `city`
  MODIFY `city_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3579;

--
-- AUTO_INCREMENT for table `material`
--
ALTER TABLE `material`
  MODIFY `material_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `member`
--
ALTER TABLE `member`
  MODIFY `member_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_material`
--
ALTER TABLE `product_material`
  MODIFY `product_material_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_picture`
--
ALTER TABLE `product_picture`
  MODIFY `product_picture_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_tag`
--
ALTER TABLE `product_tag`
  MODIFY `product_tag_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `review`
--
ALTER TABLE `review`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `review_vote`
--
ALTER TABLE `review_vote`
  MODIFY `review_vote_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `session`
--
ALTER TABLE `session`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shipping_address`
--
ALTER TABLE `shipping_address`
  MODIFY `shipping_address_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag`
--
ALTER TABLE `tag`
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `vendor_detail`
--
ALTER TABLE `vendor_detail`
  MODIFY `vendor_detail_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wish_list`
--
ALTER TABLE `wish_list`
  MODIFY `wish_list_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`shipping_address_id`) REFERENCES `shipping_address` (`shipping_address_id`),
  ADD CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `cart_product`
--
ALTER TABLE `cart_product`
  ADD CONSTRAINT `cart_product_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `cart_product_ibfk_2` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`cart_id`);

--
-- Constraints for table `city`
--
ALTER TABLE `city`
  ADD CONSTRAINT `city_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `region` (`region_id`);

--
-- Constraints for table `follower_relations`
--
ALTER TABLE `follower_relations`
  ADD CONSTRAINT `follower_relations_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `member` (`member_id`),
  ADD CONSTRAINT `follower_relations_ibfk_2` FOREIGN KEY (`following_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `member` (`member_id`),
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`reciver_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `member` (`member_id`),
  ADD CONSTRAINT `notification_ibfk_2` FOREIGN KEY (`reciver_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `product_material`
--
ALTER TABLE `product_material`
  ADD CONSTRAINT `product_material_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `product_material_ibfk_2` FOREIGN KEY (`material_id`) REFERENCES `material` (`material_id`);

--
-- Constraints for table `product_picture`
--
ALTER TABLE `product_picture`
  ADD CONSTRAINT `product_picture_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`);

--
-- Constraints for table `product_tag`
--
ALTER TABLE `product_tag`
  ADD CONSTRAINT `product_tag_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `product_tag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`tag_id`);

--
-- Constraints for table `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `review_vote`
--
ALTER TABLE `review_vote`
  ADD CONSTRAINT `review_vote_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `review_vote_ibfk_2` FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`),
  ADD CONSTRAINT `review_vote_ibfk_3` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `session`
--
ALTER TABLE `session`
  ADD CONSTRAINT `session_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `shipping_address`
--
ALTER TABLE `shipping_address`
  ADD CONSTRAINT `shipping_address_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `vendor_detail`
--
ALTER TABLE `vendor_detail`
  ADD CONSTRAINT `vendor_detail_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `wish_list`
--
ALTER TABLE `wish_list`
  ADD CONSTRAINT `wish_list_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `wish_list_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
