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

    UPDATE `product` SET `name`="Elt??vol??tott term??k",`price`=NULL,`description`=NULL,`inventory`=NULL,`delivery`=NULL,`category`=NULL,`rating`=NULL,`vendor_id`=NULL,`discount`=NULL,`is_published`=FALSE,`is_removed`=TRUE,`created_at`=NULL,`last_updated_at`=NULL,`published_at`=NULL WHERE `product_id` = prodId;

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

    	SET nm = CONCAT(@count, '. sz??ll??t??si c??m');

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

        SET @cont = '??j term??ket tett k??zz??.';

    ELSEIF typ = 'order-tracking' THEN

    	SET @lnk = '/order-tracking';

        SET @cont = 'friss??tette egy rendel??sed ??llapot??t.';

    ELSEIF typ = 'order-arrived' THEN

    	SET @lnk = '/order-management';

        SET @cont = 'megkapott egy t??led rendelt term??ket.';

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

    	SET nm = CONCAT(@count, '. sz??ll??t??si c??m');

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
(3, 'Ab??dszal??k', '5241', 10),
(4, 'Abaliget', '7678', 2),
(5, 'Abas??r', '3261', 9),
(6, 'Aba??jalp??r', '3882', 4),
(7, 'Aba??jk??r', '3882', 4),
(8, 'Aba??jlak', '3815', 4),
(9, 'Aba??jsz??nt??', '3881', 4),
(10, 'Aba??jszolnok', '3809', 4),
(11, 'Aba??jv??r', '3898', 4),
(12, 'Abda', '9151', 7),
(13, 'Abod', '3753', 4),
(14, 'Abony', '2740', 13),
(15, '??brah??mhegy', '8256', 18),
(16, '??cs', '2941', 11),
(17, 'Acsa', '2683', 13),
(18, 'Acs??d', '9746', 17),
(19, 'Acsalag', '9168', 7),
(20, '??cstesz??r', '2887', 11),
(21, 'Ad??cs', '3292', 9),
(22, '??d??nd', '8653', 14),
(23, 'Ad??sztevel', '8561', 18),
(24, 'Adony', '2457', 6),
(25, 'Adorj??nh??za', '8497', 18),
(26, 'Adorj??s', '7841', 2),
(27, '??g', '7381', 2),
(28, '??gasegyh??za', '6076', 1),
(29, '??gfalva', '9423', 7),
(30, 'Aggtelek', '3759', 4),
(31, 'Agyagosszerg??ny', '9441', 7),
(32, 'Ajak', '4524', 15),
(33, 'Ajka', '8400', 18),
(34, 'Ajka', '8447', 18),
(35, 'Ajka', '8448', 18),
(36, 'Ajka', '8451', 18),
(37, 'Aka', '2862', 11),
(38, 'Akaszt??', '6221', 1),
(39, 'Alacska', '3779', 4),
(40, 'Alap', '7011', 6),
(41, 'Alatty??n', '5142', 10),
(42, 'Albertirsa', '2730', 13),
(43, 'Alcs??tdoboz', '8087', 6),
(44, 'Aldebr??', '3353', 9),
(45, 'Algy??', '6750', 5),
(46, 'Alib??nfa', '8921', 19),
(47, 'Almamell??k', '7934', 2),
(48, 'Alm??sf??zit??', '2931', 11),
(49, 'Alm??sh??za', '8935', 19),
(50, 'Alm??skamar??s', '5747', 3),
(51, 'Alm??skereszt??r', '7932', 2),
(52, '??lmosd', '4285', 8),
(53, 'Als??berecki', '3985', 4),
(54, 'Als??bog??t', '7443', 14),
(55, 'Als??dobsza', '3717', 4),
(56, 'Als??gagy', '3837', 4),
(57, 'Als??mocsol??d', '7345', 2),
(58, 'Als??n??na', '7147', 16),
(59, 'Als??n??medi', '2351', 13),
(60, 'Als??nemesap??ti', '8924', 19),
(61, 'Als??ny??k', '7148', 16),
(62, 'Als????rs', '8226', 18),
(63, 'Als??p??hok', '8394', 19),
(64, 'Als??pet??ny', '2617', 12),
(65, 'Als??rajk', '8767', 19),
(66, 'Als??regmec', '3989', 4),
(67, 'Als??szenterzs??bet', '8973', 19),
(68, 'Als??szentiv??n', '7012', 6),
(69, 'Als??szentm??rton', '7826', 2),
(70, 'Als??sz??ln??k', '9983', 17),
(71, 'Als??szuha', '3726', 4),
(72, 'Als??telekes', '3735', 4),
(73, 'Als??told', '3069', 12),
(74, 'Als????jlak', '9842', 17),
(75, 'Als??vad??sz', '3811', 4),
(76, 'Als??zsolca', '3571', 4),
(77, 'Ambr??zfalva', '6916', 5),
(78, 'Anarcs', '4546', 15),
(79, 'Andocs', '8675', 14),
(80, 'Andornakt??lya', '3399', 9),
(81, 'Andr??sfa', '9811', 17),
(82, 'Annav??lgy', '2529', 11),
(83, 'Ap??catorna', '8477', 18),
(84, 'Apagy', '4553', 15),
(85, 'Apaj', '2345', 13),
(86, 'Aparhant', '7186', 16),
(87, 'Ap??tfalva', '6931', 5),
(88, 'Ap??tistv??nfalva', '9982', 17),
(89, 'Ap??tvarasd', '7720', 2),
(90, 'Apc', '3032', 9),
(91, '??porka', '2338', 13),
(92, 'Apostag', '6088', 1),
(93, 'Aranyosap??ti', '4634', 15),
(94, 'Aranyosgad??ny', '7671', 2),
(95, 'Arka', '3885', 4),
(96, 'Arl??', '3663', 4),
(97, 'Arn??t', '3713', 4),
(98, '??rokt??', '3467', 4),
(99, '??rp??dhalom', '6623', 5),
(100, '??rp??s', '9132', 7),
(101, '??rt??nd', '4115', 8),
(102, '??sotthalom', '6783', 5),
(103, '??sv??nyr??r??', '9177', 7),
(104, 'Aszal??', '3841', 4),
(105, '??sz??r', '2881', 11),
(106, 'Asz??d', '2170', 13),
(107, 'Asz??f??', '8241', 18),
(108, '??ta', '7763', 2),
(109, '??t??ny', '3371', 9),
(110, 'Atk??r', '3213', 9),
(111, 'Attala', '7252', 16),
(112, 'Babarc', '7757', 2),
(113, 'Babarcsz??l??s', '7814', 2),
(114, 'Bab??csa', '7584', 14),
(115, 'B??bolna', '2943', 11),
(116, 'B??bonymegyer', '8658', 14),
(117, 'Babosd??br??te', '8983', 19),
(118, 'Bab??t', '9351', 7),
(119, 'B??csalm??s', '6430', 1),
(120, 'B??csbokod', '6453', 1),
(121, 'B??csbors??d', '6454', 1),
(122, 'B??csszentgy??rgy', '6511', 1),
(123, 'B??cssz??l??s', '6425', 1),
(124, 'Badacsonytomaj', '8257', 18),
(125, 'Badacsonytomaj', '8258', 18),
(126, 'Badacsonytomaj', '8261', 18),
(127, 'Badacsonyt??rdemic', '8262', 18),
(128, 'Badacsonyt??rdemic', '8263', 18),
(129, 'Bag', '2191', 13),
(130, 'Bagam??r', '4286', 8),
(131, 'Baglad', '8977', 19),
(132, 'Bagod', '8992', 19),
(133, 'B??gyogszov??t', '9145', 7),
(134, 'Baj', '2836', 11),
(135, 'Baja', '6500', 1),
(136, 'Baja', '6503', 1),
(137, 'Baj??nsenye', '9944', 17),
(138, 'Bajna', '2525', 11),
(139, 'Baj??t', '2533', 11),
(140, 'Bak', '8945', 19),
(141, 'Bakh??za', '7585', 14),
(142, 'Bak??ca', '7393', 2),
(143, 'Bakonszeg', '4164', 8),
(144, 'Bakonya', '7675', 2),
(145, 'Bakonyb??nk', '2885', 11),
(146, 'Bakonyb??l', '8427', 18),
(147, 'Bakonycsernye', '8056', 6),
(148, 'Bakonygyir??t', '8433', 7),
(149, 'Bakonyj??k??', '8581', 18),
(150, 'Bakonykopp??ny', '8571', 18),
(151, 'Bakonyk??ti', '8045', 6),
(152, 'Bakonyn??na', '8422', 18),
(153, 'Bakonyoszlop', '8418', 18),
(154, 'Bakonyp??terd', '9088', 7),
(155, 'Bakonyp??l??ske', '8457', 18),
(156, 'Bakonys??g', '8557', 18),
(157, 'Bakonys??rk??ny', '2861', 11),
(158, 'Bakonyszentiv??n', '8557', 18),
(159, 'Bakonyszentkir??ly', '8430', 18),
(160, 'Bakonyszentl??szl??', '8431', 7),
(161, 'Bakonyszombathely', '2884', 11),
(162, 'Bakonysz??cs', '8572', 18),
(163, 'Bakonytam??si', '8555', 18),
(164, 'Baks', '6768', 5),
(165, 'Baksa', '7834', 2),
(166, 'Baktak??k', '3836', 4),
(167, 'Baktal??r??nth??za', '4561', 15),
(168, 'Bakt??tt??s', '8946', 19),
(169, 'Balajt', '3780', 4),
(170, 'Balassagyarmat', '2660', 12),
(171, 'Bal??stya', '6764', 5),
(172, 'Balaton', '3347', 9),
(173, 'Balatonakali', '8243', 18),
(174, 'Balatonalm??di', '8220', 18),
(175, 'Balatonber??ny', '8649', 14),
(176, 'Balatonbogl??r', '8630', 14),
(177, 'Balatonbogl??r', '8691', 14),
(178, 'Balatoncsics??', '8272', 18),
(179, 'Balatonederics', '8312', 18),
(180, 'Balatonendr??d', '8613', 14),
(181, 'Balatonfenyves', '8646', 14),
(182, 'Balatonf??kaj??r', '8164', 18),
(183, 'Balatonf??ldv??r', '8623', 14),
(184, 'Balatonf??red', '8230', 18),
(185, 'Balatonf??red', '8236', 18),
(186, 'Balatonf??zf??', '8175', 18),
(187, 'Balatonf??zf??', '8184', 18),
(188, 'Balatongy??r??k', '8313', 19),
(189, 'Balatonhenye', '8275', 18),
(190, 'Balatonkenese', '8172', 18),
(191, 'Balatonkenese', '8174', 18),
(192, 'Balatonkereszt??r', '8648', 14),
(193, 'Balatonlelle', '8638', 14),
(194, 'Balatonmagyar??d', '8753', 19),
(195, 'Balatonm??riaf??rd??', '8647', 14),
(196, 'Balaton??sz??d', '8637', 14),
(197, 'Balatonrendes', '8255', 18),
(198, 'Balatonszabadi', '8651', 14),
(199, 'Balatonsz??rsz??', '8624', 14),
(200, 'Balatonszemes', '8636', 14),
(201, 'Balatonszentgy??rgy', '8710', 14),
(202, 'Balatonszepezd', '8252', 18),
(203, 'Balatonsz??l??s', '8233', 18),
(204, 'Balatonudvari', '8242', 18),
(205, 'Balaton??jlak', '8712', 14),
(206, 'Balatonvil??gos', '8171', 18),
(207, 'Balinka', '8054', 6),
(208, 'Balinka', '8055', 6),
(209, 'Balk??ny', '4233', 15),
(210, 'Ball??sz??g', '6035', 1),
(211, 'Balmaz??jv??ros', '4060', 8),
(212, 'Balogunyom', '9771', 17),
(213, 'Balotasz??ll??s', '6412', 1),
(214, 'Balsa', '4468', 15),
(215, 'B??lv??nyos', '8614', 14),
(216, 'Bana', '2944', 11),
(217, 'B??nd', '8443', 18),
(218, 'B??nfa', '7914', 2),
(219, 'B??nhorv??ti', '3642', 4),
(220, 'B??nk', '2653', 12),
(221, 'B??nokszentgy??rgy', '8891', 19),
(222, 'B??nr??ve', '3654', 4),
(223, 'B??r', '7711', 2),
(224, 'Barab??s', '4937', 15),
(225, 'Baracs', '2426', 6),
(226, 'Baracs', '2427', 6),
(227, 'Baracska', '2471', 6),
(228, 'B??r??nd', '4161', 8),
(229, 'Baranyahidv??g', '7841', 2),
(230, 'Baranyajen??', '7384', 2),
(231, 'Baranyaszentgy??rgy', '7383', 2),
(232, 'Barbacs', '9169', 7),
(233, 'Barcs', '7557', 14),
(234, 'Barcs', '7570', 14),
(235, 'B??rdudvarnok', '7478', 14),
(236, 'Barlahida', '8948', 19),
(237, 'B??rna', '3126', 12),
(238, 'Barnag', '8291', 18),
(239, 'B??rsonyos', '2883', 11),
(240, 'Basal', '7923', 2),
(241, 'Bask??', '3881', 4),
(242, 'B??ta', '7149', 16),
(243, 'B??taap??ti', '7164', 16),
(244, 'B??tasz??k', '7140', 16),
(245, 'Bat??', '7258', 14),
(246, 'B??tmonostor', '6528', 1),
(247, 'B??tonyterenye', '3070', 12),
(248, 'B??tonyterenye', '3078', 12),
(249, 'B??tor', '3336', 9),
(250, 'B??torliget', '4343', 15),
(251, 'Battonya', '5830', 3),
(252, 'B??tya', '6351', 1),
(253, 'Batyk', '8797', 19),
(254, 'B??zakerettye', '8887', 19),
(255, 'Bazsi', '8352', 18),
(256, 'B??b', '8565', 18),
(257, 'Becsehely', '8866', 19),
(258, 'Becske', '2693', 12),
(259, 'Becskeh??za', '3768', 4),
(260, 'Becsv??lgye', '8985', 19),
(261, 'Bedegk??r', '8666', 14),
(262, 'Bed??', '4128', 8),
(263, 'Bejcgyerty??nos', '9683', 17),
(264, 'B??k??s', '8515', 18),
(265, 'Bekecs', '3903', 4),
(266, 'B??k??s', '5630', 3),
(267, 'B??k??scsaba', '5600', 3),
(268, 'B??k??scsaba', '5623', 3),
(269, 'B??k??scsaba', '5671', 3),
(270, 'B??k??ss??mson', '5946', 3),
(271, 'B??k??sszentandr??s', '5561', 3),
(272, 'Bek??lce', '3343', 9),
(273, 'B??lap??tfalva', '3346', 9),
(274, 'B??lav??r', '7589', 14),
(275, 'Belecska', '7061', 16),
(276, 'Beled', '9343', 7),
(277, 'Beleg', '7543', 14),
(278, 'Belezna', '8855', 19),
(279, 'B??lmegyer', '5643', 3),
(280, 'Beloiannisz', '2455', 6),
(281, 'Bels??s??rd', '8978', 19),
(282, 'Belv??rdgyula', '7747', 2),
(283, 'Benk', '4643', 15),
(284, 'B??nye', '2216', 13),
(285, 'B??r', '3045', 12),
(286, 'B??rbaltav??r', '9831', 17),
(287, 'Bercel', '2687', 12),
(288, 'Beregdar??c', '4934', 15),
(289, 'Beregsur??ny', '4933', 15),
(290, 'Berekb??sz??rm??ny', '4116', 8),
(291, 'Berekf??rd??', '5309', 10),
(292, 'Beremend', '7827', 2),
(293, 'Berente', '3704', 4),
(294, 'Beret', '3834', 4),
(295, 'Beretty????jfalu', '4100', 8),
(296, 'Beretty????jfalu', '4103', 8),
(297, 'Berhida', '8181', 18),
(298, 'Berhida', '8182', 18),
(299, 'Berkenye', '2641', 12),
(300, 'Berkesd', '7664', 2),
(301, 'Berkesz', '4521', 15),
(302, 'Bernecebar??ti', '2639', 13),
(303, 'Berz??k', '3575', 4),
(304, 'Berzence', '7516', 14),
(305, 'Besence', '7838', 2),
(306, 'Beseny??d', '4557', 15),
(307, 'Beseny??telek', '3373', 9),
(308, 'Besenysz??g', '5071', 10),
(309, 'Besny??', '2456', 6),
(310, 'Beszterec', '4488', 15),
(311, 'Bezedek', '7782', 2),
(312, 'Bezenye', '9223', 7),
(313, 'Bezer??d', '8934', 19),
(314, 'Bezi', '9162', 7),
(315, 'Biatorb??gy', '2051', 13),
(316, 'Bics??rd', '7671', 2),
(317, 'Bicske', '2060', 6),
(318, 'Bihardancsh??za', '4175', 8),
(319, 'Biharkeresztes', '4110', 8),
(320, 'Biharnagybajom', '4172', 8),
(321, 'Bihartorda', '4174', 8),
(322, 'Biharugra', '5538', 3),
(323, 'Bik??cs', '7043', 16),
(324, 'Bikal', '7346', 2),
(325, 'Biri', '4235', 15),
(326, 'Birj??n', '7747', 2),
(327, 'Bisse', '7811', 2),
(328, 'B??', '9625', 17),
(329, 'Boba', '9542', 17),
(330, 'Bocf??lde', '8943', 19),
(331, 'Bocon??d', '3368', 9),
(332, 'B??cs', '3574', 4),
(333, 'B??csa', '6235', 1),
(334, 'Bocska', '8776', 19),
(335, 'Bocskaikert', '4241', 8),
(336, 'Boda', '7672', 2),
(337, 'Bodajk', '8053', 6),
(338, 'B??de', '8991', 19),
(339, 'B??deh??za', '8969', 19),
(340, 'Bodm??r', '8085', 6),
(341, 'Bodolyab??r', '7394', 2),
(342, 'Bodonhely', '9134', 7),
(343, 'Bodony', '3243', 9),
(344, 'Bodorfa', '8471', 18),
(345, 'Bodrog', '7439', 14),
(346, 'Bodroghalom', '3987', 4),
(347, 'Bodrogkereszt??r', '3916', 4),
(348, 'Bodrogkisfalud', '3917', 4),
(349, 'Bodrogolaszi', '3943', 4),
(350, 'B??dvalenke', '3768', 4),
(351, 'B??dvar??k??', '3764', 4),
(352, 'B??dvaszilas', '3763', 4),
(353, 'Bog??cs', '3412', 4),
(354, 'Bog??d', '7742', 2),
(355, 'Bog??dmindszent', '7836', 2),
(356, 'Bogd??sa', '7966', 2),
(357, 'B??g??t', '9612', 17),
(358, 'B??g??te', '9675', 17),
(359, 'Bogyiszl??', '7132', 16),
(360, 'Bogyoszl??', '9324', 7),
(361, 'B??h??nye', '8719', 14),
(362, 'Bojt', '4114', 8),
(363, 'B??kah??za', '8741', 19),
(364, 'Bokod', '2855', 11),
(365, 'B??k??ny', '4231', 15),
(366, 'Bokor', '3066', 12),
(367, 'B??lcske', '7025', 16),
(368, 'Boldog', '3016', 9),
(369, 'Boldogasszonyfa', '7937', 2),
(370, 'Boldogk????jfalu', '3884', 4),
(371, 'Boldogk??v??ralja', '3885', 4),
(372, 'Boldva', '3794', 4),
(373, 'Bolh??s', '7517', 14),
(374, 'Bolh??', '7586', 14),
(375, 'B??ly', '7754', 2),
(376, 'Boncodf??lde', '8992', 19),
(377, 'Bonnya', '7281', 14),
(378, 'B??ny', '9073', 7),
(379, 'Bonyh??d', '7150', 16),
(380, 'Bonyh??d', '7187', 16),
(381, 'Bonyh??dvarasd', '7158', 16),
(382, 'B??rcs', '9152', 7),
(383, 'Bord??ny', '6795', 5),
(384, 'Borg??ta', '9554', 17),
(385, 'Borj??d', '7756', 2),
(386, 'Borota', '6445', 1),
(387, 'Borsfa', '8885', 19),
(388, 'Borsodb??ta', '3658', 4),
(389, 'Borsodgeszt', '3426', 4),
(390, 'Borsodiv??nka', '3462', 4),
(391, 'Borsodn??dasd', '3671', 4),
(392, 'Borsodn??dasd', '3672', 4),
(393, 'Borsodszentgy??rgy', '3623', 4),
(394, 'Borsodszir??k', '3796', 4),
(395, 'Borsosber??ny', '2644', 12),
(396, 'Borsz??rcs??k', '8479', 18),
(397, 'Borzav??r', '8428', 18),
(398, 'B??rz??nce', '8772', 19),
(399, 'B??s??rk??ny', '9167', 7),
(400, 'Bosta', '7811', 2),
(401, 'B??sz??nfa', '7475', 14),
(402, 'Botpal??d', '4955', 15),
(403, 'Botykapeterd', '7900', 2),
(404, 'Bozsok', '9727', 17),
(405, 'B??zsva', '3994', 4),
(406, 'Bozzai', '9752', 17),
(407, 'Bucsa', '5527', 3),
(408, 'Bucsu', '9792', 17),
(409, 'Bucsuszentl??szl??', '8925', 19),
(410, 'Bucsuta', '8893', 19),
(411, 'Budajen??', '2093', 13),
(412, 'Budakal??sz', '2011', 13),
(413, 'Budakeszi', '2092', 13),
(414, 'Buda??rs', '2040', 13),
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
(578, 'Bugacpusztah??za', '6114', 1),
(579, 'Bugyi', '2347', 13),
(580, 'Buj', '4483', 15),
(581, 'Buj??k', '3047', 12),
(582, 'B??k', '9737', 17),
(583, 'B??k', '9740', 17),
(584, 'B??kk??br??ny', '3422', 4),
(585, 'B??kkaranyos', '3554', 4),
(586, 'B??kkmogyor??sd', '3648', 4),
(587, 'B??kk??sd', '7682', 2),
(588, 'B??kksz??k', '3335', 9),
(589, 'B??kkszenterzs??bet', '3257', 9),
(590, 'B??kkszentkereszt', '3557', 4),
(591, 'B??kkszentm??rton', '3346', 9),
(592, 'B??kkzs??rc', '3414', 4),
(593, 'B??r??s', '7973', 2),
(594, 'B??ss??', '7273', 14),
(595, 'B??tt??s', '3821', 4),
(596, 'Buzs??k', '8695', 14),
(597, 'C??k', '9725', 17),
(598, 'Cak??h??za', '9165', 7),
(599, 'Cece', '7013', 6),
(600, 'C??g??nyd??ny??d', '4732', 15),
(601, 'Cegl??d', '2700', 13),
(602, 'Cegl??d', '2738', 13),
(603, 'Cegl??dbercel', '2737', 13),
(604, 'Celld??m??lk', '9500', 17),
(605, 'Celld??m??lk', '9541', 17),
(606, 'Cered', '3123', 12),
(607, 'Chernelh??zadamonya', '9624', 17),
(608, 'Cibakh??za', '5462', 10),
(609, 'Cig??nd', '3973', 4),
(610, 'Cik??', '7161', 16),
(611, 'Cir??k', '9364', 7),
(612, 'Csabacs??d', '5551', 3),
(613, 'Csabaszabadi', '5609', 3),
(614, 'Csabdi', '2064', 6),
(615, 'Csabrendek', '8474', 18),
(616, 'Cs??fordj??nosfa', '9375', 7),
(617, 'Csaholc', '4967', 15),
(618, 'Csaj??g', '8163', 18),
(619, 'Cs??k??ny', '8735', 14),
(620, 'Cs??k??nydoroszl??', '9919', 17),
(621, 'Cs??kber??ny', '8073', 6),
(622, 'Cs??kv??r', '8083', 6),
(623, 'Csan??dalberti', '6915', 5),
(624, 'Csan??dap??ca', '5662', 3),
(625, 'Csan??dpalota', '6913', 5),
(626, 'Cs??nig', '9654', 17),
(627, 'Cs??ny', '3015', 9),
(628, 'Cs??nyoszr??', '7964', 2),
(629, 'Csanytelek', '6647', 5),
(630, 'Csapi', '8756', 19),
(631, 'Csapod', '9372', 7),
(632, 'Cs??rdasz??ll??s', '5621', 3),
(633, 'Csarn??ta', '7811', 2),
(634, 'Csaroda', '4844', 15),
(635, 'Cs??sz??r', '2858', 11),
(636, 'Cs??sz??rt??lt??s', '6239', 1),
(637, 'Cs??szl??', '4973', 15),
(638, 'Cs??talja', '6523', 1),
(639, 'Csat??r', '8943', 19),
(640, 'Csatasz??g', '5064', 10),
(641, 'Csatka', '2888', 11),
(642, 'Cs??voly', '6448', 1),
(643, 'Cseb??ny', '7935', 2),
(644, 'Cs??cse', '3052', 12),
(645, 'Cseg??ld', '4742', 15),
(646, 'Csehb??nya', '8445', 18),
(647, 'Csehi', '9833', 17),
(648, 'Csehimindszent', '9834', 17),
(649, 'Cs??m', '2949', 11),
(650, 'Csem??', '2713', 13),
(651, 'Csempeszkop??cs', '9764', 17),
(652, 'Csengele', '6765', 5),
(653, 'Csenger', '4765', 15),
(654, 'Csengersima', '4743', 15),
(655, 'Csenger??jfalu', '4764', 15),
(656, 'Cseng??d', '6222', 1),
(657, 'Cs??nye', '9611', 17),
(658, 'Cseny??te', '3837', 4),
(659, 'Cs??p', '2946', 11),
(660, 'Cs??pa', '5475', 10),
(661, 'Csepreg', '9735', 17),
(662, 'Cs??r', '9375', 7),
(663, 'Cserdi', '7683', 2),
(664, 'Cser??nfa', '7472', 14),
(665, 'Cser??pfalu', '3413', 4),
(666, 'Cser??pv??ralja', '3417', 4),
(667, 'Cserh??thal??p', '2694', 12),
(668, 'Cserh??tsur??ny', '2676', 12),
(669, 'Cserh??tszentiv??n', '3066', 12),
(670, 'Cserkesz??l??', '5465', 10),
(671, 'Cserk??t', '7673', 2),
(672, 'Csernely', '3648', 4),
(673, 'Cserszegtomaj', '8372', 19),
(674, 'Csertalakos', '8951', 19),
(675, 'Csert??', '7900', 2),
(676, 'Csesznek', '8419', 18),
(677, 'Csesztreg', '8973', 19),
(678, 'Csesztve', '2678', 12),
(679, 'Cset??ny', '8417', 18),
(680, 'Cs??vharaszt', '2212', 13),
(681, 'Csibr??k', '7225', 16),
(682, 'Csik??ria', '6424', 1),
(683, 'Csik??st??tt??s', '7341', 16),
(684, 'Csikv??nd', '9127', 7),
(685, 'Csincse', '3442', 4),
(686, 'Csipkerek', '9836', 17),
(687, 'Csit??r', '2673', 12),
(688, 'Csob??d', '3848', 4),
(689, 'Csobaj', '3927', 4),
(690, 'Csob??nka', '2014', 13),
(691, 'Cs??de', '8999', 19),
(692, 'Cs??gle', '8495', 18),
(693, 'Cs??kak??', '8074', 6),
(694, 'Cs??km??', '4145', 8),
(695, 'Cs??k??ly', '7526', 14),
(696, 'Csokonyavisonta', '7555', 14),
(697, 'Csokvaom??ny', '3647', 4),
(698, 'Csolnok', '2521', 11),
(699, 'Cs??lyosp??los', '6135', 1),
(700, 'Csoma', '7253', 14),
(701, 'Csom??d', '2161', 13),
(702, 'Csomb??rd', '7432', 14),
(703, 'Cs??mend', '8700', 14),
(704, 'Cs??m??d??r', '8957', 19),
(705, 'Cs??m??r', '2141', 13),
(706, 'Cs??nge', '9513', 17),
(707, 'Csongr??d', '6640', 5),
(708, 'Csongr??d', '6648', 5),
(709, 'Csonkahegyh??t', '8918', 19),
(710, 'Csonkamindszent', '7940', 2),
(711, 'Csopak', '8229', 18),
(712, 'Cs??r', '8041', 6),
(713, 'Csorna', '9300', 7),
(714, 'Cs??rnyef??ld', '8873', 19),
(715, 'Cs??r??g', '2135', 13),
(716, 'Cs??r??tnek', '9962', 17),
(717, 'Csorv??s', '5920', 3),
(718, 'Cs??sz', '8122', 6),
(719, 'Cs??t', '8558', 18),
(720, 'Cs??v??r', '2615', 13),
(721, 'Csurg??', '8840', 14),
(722, 'Csurg??nagymarton', '8840', 14),
(723, 'C??n', '7843', 2),
(724, 'Dabas', '2370', 13),
(725, 'Dabas', '2371', 13),
(726, 'Dabas', '2373', 13),
(727, 'Dabronc', '8345', 18),
(728, 'Dabrony', '8485', 18),
(729, 'Dad', '2854', 11),
(730, 'D??g', '2522', 11),
(731, 'D??ka', '8592', 18),
(732, 'Dalmand', '7211', 16),
(733, 'Damak', '3780', 4),
(734, 'D??m??c', '3978', 4),
(735, 'D??nszentmikl??s', '2735', 13),
(736, 'D??ny', '2118', 13),
(737, 'Daraboshegy', '9917', 17),
(738, 'Dar??ny', '7988', 14),
(739, 'Darn??', '4737', 15),
(740, 'Darn??zseli', '9232', 7),
(741, 'Daruszentmikl??s', '2423', 6),
(742, 'Darvas', '4144', 8),
(743, 'D??vod', '6524', 1),
(744, 'Debercs??ny', '2694', 12),
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
(762, 'Debr??te', '3825', 4),
(763, 'Decs', '7144', 16),
(764, 'D??destapolcs??ny', '3643', 4),
(765, 'D??g', '8135', 6),
(766, 'Dejt??r', '2649', 12),
(767, 'D??legyh??za', '2337', 13),
(768, 'Demecser', '4516', 15),
(769, 'Demj??n', '3395', 9),
(770, 'Dencsh??za', '7915', 2),
(771, 'D??nesfa', '9365', 7),
(772, 'Derecske', '4130', 8),
(773, 'Derekegyh??z', '6621', 5),
(774, 'Deszk', '6772', 5),
(775, 'Detek', '3834', 4),
(776, 'Detk', '3275', 9),
(777, 'D??vav??nya', '5510', 3),
(778, 'Devecser', '8460', 18),
(779, 'Dinnyeberki', '7683', 2),
(780, 'Di??sber??ny', '7072', 16),
(781, 'Di??sd', '2049', 13),
(782, 'Di??sjen??', '2643', 12),
(783, 'Di??sk??l', '8764', 19),
(784, 'Di??sviszl??', '7817', 2),
(785, 'Doba', '8482', 18),
(786, 'D??b??rhegy', '9914', 17),
(787, 'Doboz', '5624', 3),
(788, 'Dobri', '8874', 19),
(789, 'D??br??ce', '8357', 19),
(790, 'D??br??k??z', '7228', 16),
(791, 'Dobronhegy', '8989', 19),
(792, 'D??br??nte', '8597', 18),
(793, 'D??c', '6766', 5),
(794, 'D??ge', '4495', 15),
(795, 'Domah??za', '3627', 4),
(796, 'Domasz??k', '6781', 5),
(797, 'Dombegyh??z', '5836', 3),
(798, 'Dombiratos', '5745', 3),
(799, 'Domb??v??r', '7200', 16),
(800, 'Dombr??d', '4492', 15),
(801, 'Domony', '2182', 13),
(802, 'D??m??s', '2027', 11),
(803, 'Domoszl??', '3263', 9),
(804, 'D??ms??d', '2344', 13),
(805, 'D??r', '9147', 7),
(806, 'D??rgicse', '8244', 18),
(807, 'Dorm??nd', '3374', 9),
(808, 'Dorog', '2510', 11),
(809, 'Dorogh??za', '3153', 12),
(810, 'D??r??ske', '9913', 17),
(811, 'D??tk', '8799', 19),
(812, 'D??v??ny', '3721', 4),
(813, 'Dozmat', '9791', 17),
(814, 'Dr??gsz??l', '6342', 1),
(815, 'Dr??vacsehi', '7849', 2),
(816, 'Dr??vacsepely', '7846', 2),
(817, 'Dr??vafok', '7967', 2),
(818, 'Dr??vag??rdony', '7977', 14),
(819, 'Dr??vaiv??nyi', '7960', 2),
(820, 'Dr??vakereszt??r', '7967', 2),
(821, 'Dr??vapalkonya', '7850', 2),
(822, 'Dr??vapiski', '7843', 2),
(823, 'Dr??vaszabolcs', '7851', 2),
(824, 'Dr??vaszerdahely', '7847', 2),
(825, 'Dr??vaszt??ra', '7960', 2),
(826, 'Dr??vatam??si', '7979', 14),
(827, 'Dr??gelypal??nk', '2646', 12),
(828, 'Dubics??ny', '3635', 4),
(829, 'Dudar', '8416', 18),
(830, 'Duka', '9556', 17),
(831, 'Dunaalm??s', '2545', 11),
(832, 'Dunabogd??ny', '2023', 13),
(833, 'Dunaegyh??za', '6323', 1),
(834, 'Dunafalva', '6513', 1),
(835, 'Dunaf??ldv??r', '7020', 16),
(836, 'Dunaharaszti', '2330', 13),
(837, 'Dunakeszi', '2120', 13),
(838, 'Dunakiliti', '9225', 7),
(839, 'Dunapataj', '6328', 1),
(840, 'Dunaremete', '9235', 7),
(841, 'Dunaszeg', '9174', 7),
(842, 'Dunaszekcs??', '7712', 2),
(843, 'Dunaszentbenedek', '6333', 1),
(844, 'Dunaszentgy??rgy', '7135', 16),
(845, 'Dunaszentmikl??s', '2897', 11),
(846, 'Dunaszentp??l', '9175', 7),
(847, 'Dunasziget', '9226', 7),
(848, 'Dunatet??tlen', '6325', 1),
(849, 'Duna??jv??ros', '2400', 6),
(850, 'Duna??jv??ros', '2407', 6),
(851, 'Dunavars??ny', '2336', 13),
(852, 'Dunavecse', '6087', 1),
(853, 'Dusnok', '6353', 1),
(854, 'D??zs', '7224', 16),
(855, 'Eberg??c', '9451', 7),
(856, 'Ebes', '4211', 8),
(857, '??cs', '9083', 7),
(858, 'Ecs??d', '3013', 9),
(859, 'Ecseg', '3053', 12),
(860, 'Ecsegfalva', '5515', 3),
(861, 'Ecseny', '7457', 14),
(862, 'Ecser', '2233', 13),
(863, 'Edde', '7443', 14),
(864, 'Edel??ny', '3780', 4),
(865, 'Edel??ny', '3783', 4),
(866, 'Edve', '9343', 7),
(867, 'Eger', '3300', 9),
(868, 'Eger', '3304', 9),
(869, 'Eger??g', '7763', 2),
(870, 'Egeralja', '8497', 18),
(871, 'Egeraracsa', '8765', 19),
(872, 'Egerbakta', '3321', 9),
(873, 'Egerbocs', '3337', 9),
(874, 'Egercsehi', '3341', 9),
(875, 'Egerfarmos', '3379', 9),
(876, 'Egerl??v??', '3461', 4),
(877, 'Egerszal??k', '3394', 9),
(878, '??gersz??g', '3757', 4),
(879, 'Egersz??l??t', '3328', 9),
(880, 'Egerv??r', '8913', 19),
(881, 'Egerv??lgy', '9684', 17),
(882, 'Egyed', '9314', 7),
(883, 'Egyek', '4067', 8),
(884, 'Egyek', '4069', 8),
(885, 'Egyh??zasdengeleg', '3043', 12),
(886, 'Egyh??zasfalu', '9473', 7),
(887, 'Egyh??zasgerge', '3185', 12),
(888, 'Egyh??zasharaszti', '7824', 2),
(889, 'Egyh??zashetye', '9554', 17),
(890, 'Egyh??zasholl??s', '9781', 17),
(891, 'Egyh??zaskesz??', '8523', 18),
(892, 'Egyh??zaskoz??r', '7347', 2),
(893, 'Egyh??zasr??d??c', '9783', 17),
(894, 'Elek', '5742', 3),
(895, 'Ellend', '7744', 2),
(896, 'El??sz??ll??s', '2424', 6),
(897, 'Em??d', '3432', 4),
(898, 'Encs', '3854', 4),
(899, 'Encs', '3860', 4),
(900, 'Encsencs', '4374', 15),
(901, 'Endrefalva', '3165', 12),
(902, 'Endr??c', '7973', 2),
(903, 'Enese', '9143', 7),
(904, 'Enying', '8130', 6),
(905, 'Enying', '8131', 6),
(906, 'Eperjes', '6624', 5),
(907, 'Eperjeske', '4646', 15),
(908, 'Epl??ny', '8413', 18),
(909, 'Ep??l', '2526', 11),
(910, 'Ercsi', '2451', 6),
(911, 'Ercsi', '2453', 6),
(912, '??rd', '2030', 13),
(913, '??rd', '2035', 13),
(914, '??rd', '2036', 13),
(915, 'Erd??b??nye', '3932', 4),
(916, 'Erd??horv??ti', '3935', 4),
(917, 'Erd??kertes', '2113', 13),
(918, 'Erd??k??vesd', '3252', 9),
(919, 'Erd??k??rt', '2176', 12),
(920, 'Erd??sm??rok', '7735', 2),
(921, 'Erd??smecske', '7723', 2),
(922, 'Erd??tarcsa', '2177', 12),
(923, 'Erd??telek', '3358', 9),
(924, 'Erk', '3295', 9),
(925, '??rpatak', '4245', 15),
(926, '??rsekcsan??d', '6347', 1),
(927, '??rsekhalma', '6348', 1),
(928, '??rsekvadkert', '2659', 12),
(929, '??rt??ny', '7093', 16),
(930, 'Erzs??bet', '7661', 2),
(931, 'Eszt??r', '4124', 8),
(932, 'Eszteregnye', '8882', 19),
(933, 'Eszterg??lyhorv??ti', '8742', 19),
(934, 'Esztergom', '2500', 11),
(935, 'Esztergom', '2509', 11),
(936, 'Ete', '2947', 11),
(937, 'Etes', '3136', 12),
(938, 'Etyek', '2091', 6),
(939, 'F??bi??nh??za', '4354', 15),
(940, 'F??bi??nsebesty??n', '6625', 5),
(941, 'F??c??nkert', '7136', 16),
(942, 'Fadd', '7133', 16),
(943, 'Fadd', '7139', 16),
(944, 'F??j', '3865', 4),
(945, 'Fajsz', '6352', 1),
(946, 'Fancsal', '3855', 4),
(947, 'Far??d', '9321', 7),
(948, 'Farkasgyep??', '8582', 18),
(949, 'Farkaslyuk', '3608', 4),
(950, 'Farmos', '2765', 13),
(951, 'Fazekasboda', '7732', 2),
(952, 'Fed??mes', '3255', 9),
(953, 'Fegyvernek', '5213', 10),
(954, 'Fegyvernek', '5231', 10),
(955, 'Feh??rgyarmat', '4900', 15),
(956, 'Feh??rt??', '9163', 7),
(957, 'Feh??rv??rcsurg??', '8052', 6),
(958, 'Feked', '7724', 2),
(959, 'Feketeerd??', '9211', 7),
(960, 'Felcs??t', '8086', 6),
(961, 'Feldebr??', '3352', 9),
(962, 'Felgy??', '6645', 5),
(963, 'Felp??c', '9122', 7),
(964, 'Fels??berecki', '3985', 4),
(965, 'Fels??csat??r', '9794', 17),
(966, 'Fels??dobsza', '3847', 4),
(967, 'Fels??egerszeg', '7370', 2),
(968, 'Fels??gagy', '3837', 4),
(969, 'Fels??j??nosfa', '9934', 17),
(970, 'Fels??kelecs??ny', '3722', 4),
(971, 'Fels??lajos', '6055', 1),
(972, 'Fels??mar??c', '9918', 17),
(973, 'Fels??mocsol??d', '7456', 14),
(974, 'Fels??n??na', '7175', 16),
(975, 'Fels??ny??r??d', '3721', 4),
(976, 'Fels??ny??k', '7099', 16),
(977, 'Fels????rs', '8227', 18),
(978, 'Fels??p??hok', '8380', 19),
(979, 'Fels??pakony', '2363', 13),
(980, 'Fels??pet??ny', '2611', 12),
(981, 'Fels??rajk', '8767', 19),
(982, 'Fels??regmec', '3989', 4),
(983, 'Fels??szenterzs??bet', '8973', 19),
(984, 'Fels??szentiv??n', '6447', 1),
(985, 'Fels??szentm??rton', '7968', 2),
(986, 'Fels??sz??ln??k', '9985', 17),
(987, 'Fels??t??rk??ny', '3324', 9),
(988, 'Fels??telekes', '3735', 4),
(989, 'Fels??told', '3067', 12),
(990, 'Fels??vad??sz', '3814', 4),
(991, 'Fels??zsolca', '3561', 4),
(992, 'F??nyeslitke', '4621', 15),
(993, 'Feny??f??', '8432', 7),
(994, 'Ferencsz??ll??s', '6774', 5),
(995, 'Fert??boz', '9493', 7),
(996, 'Fert??d', '9431', 7),
(997, 'Fert??d', '9433', 7),
(998, 'Fert??endr??d', '9442', 7),
(999, 'Fert??homok', '9492', 7),
(1000, 'Fert??r??kos', '9421', 7),
(1001, 'Fert??szentmikl??s', '9444', 7),
(1002, 'Fert??sz??plak', '9436', 7),
(1003, 'Fiad', '7282', 14),
(1004, 'Filkeh??za', '3994', 4),
(1005, 'Fityeh??z', '8835', 19),
(1006, 'Fokt??', '6331', 1),
(1007, 'F??lde??k', '6922', 5),
(1008, 'F??ldes', '4177', 8),
(1009, 'Foly??s', '4090', 8),
(1010, 'Fon??', '7271', 14),
(1011, 'Fony', '3893', 4),
(1012, 'F??nyed', '8732', 14),
(1013, 'Fony??d', '8640', 14),
(1014, 'Fony??d', '8644', 14),
(1015, 'Forr??sk??t', '6793', 5),
(1016, 'Forr??', '3849', 4),
(1017, 'F??t', '2151', 13),
(1018, 'F??le', '8157', 6),
(1019, 'F??lesd', '4964', 15),
(1020, 'Ful??k??rcs', '3864', 4),
(1021, 'F??l??p', '4266', 8),
(1022, 'F??l??ph??za', '6042', 1),
(1023, 'F??l??pjakab', '6116', 1),
(1024, 'F??l??psz??ll??s', '6085', 1),
(1025, 'F??lp??sdar??c', '4754', 15),
(1026, 'F??rged', '7087', 16),
(1027, 'Furta', '4141', 8),
(1028, 'F??z??r', '3996', 4),
(1029, 'F??z??rkajata', '3994', 4),
(1030, 'F??z??rkoml??s', '3997', 4),
(1031, 'F??z??rradv??ny', '3993', 4),
(1032, 'F??zesabony', '3390', 9),
(1033, 'F??zesgyarmat', '5525', 3),
(1034, 'F??zv??lgy', '8777', 19),
(1035, 'G??borj??n', '4122', 8),
(1036, 'G??borj??nh??za', '8969', 19),
(1037, 'Gacs??ly', '4972', 15),
(1038, 'Gad??cs', '7276', 14),
(1039, 'Gad??ny', '8716', 14),
(1040, 'Gadna', '3815', 4),
(1041, 'G??doros', '5932', 3),
(1042, 'Gagyap??ti', '3837', 4),
(1043, 'Gagyb??tor', '3817', 4),
(1044, 'Gagyvend??gi', '3816', 4),
(1045, 'Galambok', '8754', 19),
(1046, 'Galgaguta', '2686', 12),
(1047, 'Galgagy??rk', '2681', 13),
(1048, 'Galgah??v??z', '2193', 13),
(1049, 'Galgam??csa', '2183', 13),
(1050, 'G??losfa', '7473', 14),
(1051, 'Galv??cs', '3752', 4),
(1052, 'Gam??s', '8685', 14),
(1053, 'Ganna', '8597', 18),
(1054, 'G??nt', '8082', 6),
(1055, 'Gara', '6522', 1),
(1056, 'Gar??b', '3067', 12),
(1057, 'Garabonc', '8747', 19),
(1058, 'Garadna', '3873', 4),
(1059, 'Garbolc', '4976', 15),
(1060, 'G??rdony', '2483', 6),
(1061, 'G??rdony', '2484', 6),
(1062, 'G??rdony', '2485', 6),
(1063, 'Gar??', '7812', 2),
(1064, 'Gasztony', '9952', 17),
(1065, 'G??t??r', '6111', 1),
(1066, 'G??vavencsell??', '4471', 15),
(1067, 'G??vavencsell??', '4472', 15),
(1068, 'G??berj??n', '4754', 15),
(1069, 'Gecse', '8543', 18),
(1070, 'G??derlak', '6334', 1),
(1071, 'G??g??ny', '4517', 15),
(1072, 'Gelej', '3444', 4),
(1073, 'Gel??nes', '4935', 15),
(1074, 'Gell??nh??za', '8981', 19),
(1075, 'Gelse', '8774', 19),
(1076, 'Gelsesziget', '8774', 19),
(1077, 'Gemzse', '4567', 15),
(1078, 'Gencsap??ti', '9721', 17),
(1079, 'G??rce', '9672', 17),
(1080, 'Gerde', '7951', 2),
(1081, 'Gerend??s', '5925', 3),
(1082, 'Ger??nyes', '7362', 2),
(1083, 'Geresdlak', '7733', 2),
(1084, 'Gerjen', '7134', 16),
(1085, 'Gersekar??t', '9813', 17),
(1086, 'Geszt', '5734', 3),
(1087, 'Gesztely', '3715', 4),
(1088, 'Gesztely', '3923', 4),
(1089, 'Geszter??d', '4232', 15),
(1090, 'G??tye', '8762', 19),
(1091, 'Gic', '8435', 18),
(1092, 'Gige', '7527', 14),
(1093, 'Gilv??nfa', '7954', 2),
(1094, 'Girincs', '3578', 4),
(1095, 'G??d', '2131', 13),
(1096, 'G??d', '2132', 13),
(1097, 'G??d??ll??', '2100', 13),
(1098, 'G??dre', '7385', 2),
(1099, 'G??dre', '7386', 2),
(1100, 'G??g??nfa', '8346', 18),
(1101, 'G??lle', '7272', 14),
(1102, 'Golop', '3906', 4),
(1103, 'Gomba', '2217', 13),
(1104, 'Gombosszeg', '8984', 19),
(1105, 'G??m??rsz??l??s', '3728', 4),
(1106, 'G??nc', '3895', 4),
(1107, 'G??ncruszka', '3894', 4),
(1108, 'G??ny??', '9071', 7),
(1109, 'G??r', '9625', 17),
(1110, 'G??rbeh??za', '4075', 8),
(1111, 'G??rcs??ny', '7833', 2),
(1112, 'G??rcs??nydoboka', '7728', 2),
(1113, 'Gordisa', '7853', 2),
(1114, 'G??rgeteg', '7553', 14),
(1115, 'G??sfa', '8913', 19),
(1116, 'Gosztola', '8978', 19),
(1117, 'Gr??b??c', '7162', 16),
(1118, 'Gul??cs', '4842', 15),
(1119, 'Gutorf??lde', '8951', 19),
(1120, 'Gy??l', '2360', 13),
(1121, 'Gyal??ka', '9474', 7),
(1122, 'Gyan??geregye', '9774', 17),
(1123, 'Gyarmat', '9126', 7),
(1124, 'Gy??k??nyes', '8851', 14),
(1125, 'Gyenesdi??s', '8315', 19),
(1126, 'Gyep??kaj??n', '8473', 18),
(1127, 'Gyermely', '2821', 11),
(1128, 'Gy??d', '7668', 2),
(1129, 'Gyomaendr??d', '5500', 3),
(1130, 'Gyomaendr??d', '5502', 3),
(1131, 'Gy??m??re', '9124', 7),
(1132, 'Gy??mr??', '2230', 13),
(1133, 'Gy??ngyfa', '7954', 2),
(1134, 'Gy??ngy??s', '3200', 9),
(1135, 'Gy??ngy??s', '3221', 9),
(1136, 'Gy??ngy??s', '3232', 9),
(1137, 'Gy??ngy??s', '3233', 9),
(1138, 'Gy??ngy??sfalu', '9723', 17),
(1139, 'Gy??ngy??shal??sz', '3212', 9),
(1140, 'Gy??ngy??smell??k', '7972', 2),
(1141, 'Gy??ngy??soroszi', '3211', 9),
(1142, 'Gy??ngy??spata', '3035', 9),
(1143, 'Gy??ngy??ssolymos', '3231', 9),
(1144, 'Gy??ngy??starj??n', '3036', 9),
(1145, 'Gy??nk', '7064', 16),
(1146, 'Gy??r', '9000', 7),
(1147, 'Gy??r', '9011', 7),
(1148, 'Gy??r', '9012', 7),
(1149, 'Gy??r', '9019', 7),
(1150, 'Gy??r', '9021', 7),
(1151, 'Gy??r', '9022', 7),
(1152, 'Gy??r', '9023', 7),
(1153, 'Gy??r', '9024', 7),
(1154, 'Gy??r', '9025', 7),
(1155, 'Gy??r', '9026', 7),
(1156, 'Gy??r', '9027', 7),
(1157, 'Gy??r', '9028', 7),
(1158, 'Gy??r', '9029', 7),
(1159, 'Gy??r', '9030', 7),
(1160, 'Gy??rasszonyfa', '9093', 7),
(1161, 'Gy??re', '7352', 16),
(1162, 'Gy??rgytarl??', '3954', 4),
(1163, 'Gy??rk??ny', '7045', 16),
(1164, 'Gy??rladam??r', '9173', 7),
(1165, 'Gy??r??', '9363', 7),
(1166, 'Gy??r??cske', '4625', 15),
(1167, 'Gy??rs??g', '9084', 7),
(1168, 'Gy??rs??v??nyh??z', '9161', 7),
(1169, 'Gy??rszemere', '9121', 7),
(1170, 'Gy??rtelek', '4752', 15),
(1171, 'Gy??r??jbar??t', '9081', 7),
(1172, 'Gy??r??jfalu', '9171', 7),
(1173, 'Gy??rv??r', '9821', 17),
(1174, 'Gy??rz??moly', '9172', 7),
(1175, 'Gyugy', '8692', 14),
(1176, 'Gy??gye', '4733', 15),
(1177, 'Gyula', '5700', 3),
(1178, 'Gyula', '5703', 3),
(1179, 'Gyula', '5711', 3),
(1180, 'Gyulah??za', '4545', 15),
(1181, 'Gyulaj', '7227', 16),
(1182, 'Gyulakeszi', '8286', 18),
(1183, 'Gy??re', '4813', 15),
(1184, 'Gy??r??', '2464', 6),
(1185, 'Gy??r??s', '8932', 19),
(1186, 'H??cs', '8694', 14),
(1187, 'Hagy??rosb??r??nd', '8992', 19),
(1188, 'Hah??t', '8771', 19),
(1189, 'Hajd??bagos', '4273', 8),
(1190, 'Hajd??b??sz??rm??ny', '4074', 8),
(1191, 'Hajd??b??sz??rm??ny', '4086', 8),
(1192, 'Hajd??b??sz??rm??ny', '4220', 8),
(1193, 'Hajd??b??sz??rm??ny', '4224', 8),
(1194, 'Hajd??dorog', '4087', 8),
(1195, 'Hajd??hadh??z', '4242', 8),
(1196, 'Hajd??n??n??s', '4080', 8),
(1197, 'Hajd??n??n??s', '4085', 8),
(1198, 'Hajd??s??mson', '4251', 8),
(1199, 'Hajd??szoboszl??', '4200', 8),
(1200, 'Hajd??szov??t', '4212', 8),
(1201, 'Hajm??s', '7473', 14),
(1202, 'Hajm??sk??r', '8192', 18),
(1203, 'Haj??s', '6344', 1),
(1204, 'Halast??', '9814', 17),
(1205, 'Hal??szi', '9228', 7),
(1206, 'Hal??sztelek', '2314', 13),
(1207, 'Halimba', '8452', 18),
(1208, 'Halmaj', '3842', 4),
(1209, 'Halmajugra', '3273', 9),
(1210, 'Halogy', '9917', 17),
(1211, 'Hang??cs', '3795', 4),
(1212, 'Hangony', '3626', 4),
(1213, 'Hantos', '2434', 6),
(1214, 'Harasztifalu', '9784', 17),
(1215, 'Harc', '7172', 16),
(1216, 'Harka', '9422', 7),
(1217, 'Harkak??t??ny', '6136', 1),
(1218, 'Hark??ny', '7815', 2),
(1219, 'H??romfa', '7585', 14),
(1220, 'H??romhuta', '3936', 4),
(1221, 'Hars??ny', '3555', 4),
(1222, 'H??rsk??t', '8442', 18),
(1223, 'Harta', '6326', 1),
(1224, 'Harta', '6327', 1),
(1225, 'H??ss??gy', '7745', 2),
(1226, 'Hatvan', '3000', 9),
(1227, 'H??derv??r', '9178', 7),
(1228, 'Hedrehely', '7533', 14),
(1229, 'Hegyesd', '8296', 18),
(1230, 'Hegyeshalom', '9222', 7),
(1231, 'Hegyfalu', '9631', 17),
(1232, 'Hegyh??thod??sz', '9915', 17),
(1233, 'Hegyh??tmar??c', '7348', 2),
(1234, 'Hegyh??ts??l', '9915', 17),
(1235, 'Hegyh??tszentjakab', '9934', 17),
(1236, 'Hegyh??tszentm??rton', '9931', 17),
(1237, 'Hegyh??tszentp??ter', '9826', 17),
(1238, 'Hegyk??', '9437', 7),
(1239, 'Hegymagas', '8265', 18),
(1240, 'Hegymeg', '3786', 4),
(1241, 'Hegyszentm??rton', '7837', 2),
(1242, 'H??halom', '3041', 12),
(1243, 'Hejce', '3892', 4),
(1244, 'Hej??b??ba', '3593', 4),
(1245, 'Hej??kereszt??r', '3597', 4),
(1246, 'Hej??k??rt', '3588', 4),
(1247, 'Hej??papi', '3594', 4),
(1248, 'Hej??szalonta', '3595', 4),
(1249, 'Helesfa', '7683', 2),
(1250, 'Helv??cia', '6034', 1),
(1251, 'Hencida', '4123', 8),
(1252, 'Hencse', '7532', 14),
(1253, 'Herceghalom', '2053', 13),
(1254, 'Hercegk??t', '3958', 4),
(1255, 'Hercegsz??nt??', '6525', 1),
(1256, 'Her??d', '3011', 9),
(1257, 'H??reg', '2832', 11),
(1258, 'Herencs??ny', '2677', 12),
(1259, 'Herend', '8440', 18),
(1260, 'Heresznye', '7587', 14),
(1261, 'Herm??nszeg', '4735', 15),
(1262, 'Hern??d', '2376', 13),
(1263, 'Hern??db??d', '3853', 4),
(1264, 'Hern??dc??ce', '3887', 4),
(1265, 'Hern??dkak', '3563', 4),
(1266, 'Hern??dk??rcs', '3846', 4),
(1267, 'Hern??dn??meti', '3564', 4),
(1268, 'Hern??dpetri', '3874', 4),
(1269, 'Hern??dszentandr??s', '3852', 4),
(1270, 'Hern??dszurdok', '3875', 4),
(1271, 'Hern??dv??cse', '3874', 4),
(1272, 'Herny??k', '8957', 19),
(1273, 'H??t', '3655', 4),
(1274, 'Hetefej??rcse', '4843', 15),
(1275, 'Hetes', '7432', 14),
(1276, 'Hetvehely', '7681', 2),
(1277, 'Hetyef??', '8344', 18),
(1278, 'Heves', '3360', 9),
(1279, 'Hevesaranyos', '3322', 9),
(1280, 'Hevesvezek??ny', '3383', 9),
(1281, 'H??v??z', '8380', 19),
(1282, 'H??v??zgy??rk', '2192', 13),
(1283, 'Hidas', '7696', 2),
(1284, 'Hidasn??meti', '3876', 4),
(1285, 'Hidegk??t', '8247', 18),
(1286, 'Hidegs??g', '9491', 7),
(1287, 'Hidv??gard??', '3768', 4),
(1288, 'Himesh??za', '7735', 2),
(1289, 'Himod', '9362', 7),
(1290, 'Hirics', '7838', 2),
(1291, 'Hobol', '7971', 2),
(1292, 'Hod??sz', '4334', 15),
(1293, 'H??dmez??v??s??rhely', '6800', 5),
(1294, 'H??dmez??v??s??rhely', '6806', 5),
(1295, 'H??gy??sz', '7191', 16),
(1296, 'Holl??d', '8731', 14),
(1297, 'Holl??h??za', '3999', 4),
(1298, 'Holl??k??', '3176', 12),
(1299, 'Homokb??d??ge', '8563', 18),
(1300, 'Homokkom??rom', '8777', 19),
(1301, 'Homokm??gy', '6341', 1),
(1302, 'Homokszentgy??rgy', '7537', 14),
(1303, 'Homor??d', '7716', 2),
(1304, 'Homrogd', '3812', 4),
(1305, 'Hont', '2647', 12),
(1306, 'Horp??cs', '2658', 12),
(1307, 'Hort', '3014', 9),
(1308, 'Hortob??gy', '4071', 8),
(1309, 'Horv??thertelend', '7935', 2),
(1310, 'Horv??tl??v??', '9796', 17),
(1311, 'Horv??tzsid??ny', '9733', 17),
(1312, 'Hossz??het??ny', '7694', 2),
(1313, 'Hossz??p??lyi', '4274', 8),
(1314, 'Hossz??pereszteg', '9676', 17),
(1315, 'Hossz??v??z', '8716', 14),
(1316, 'Hossz??v??lgy', '8777', 19),
(1317, 'Hoszt??t', '8475', 18),
(1318, 'Hott??', '8991', 19),
(1319, 'H??vej', '9361', 7),
(1320, 'Hugyag', '2672', 12),
(1321, 'Hunya', '5555', 3),
(1322, 'Hunyadfalva', '5063', 10),
(1323, 'Huszt??t', '7678', 2),
(1324, 'Ibafa', '7935', 2),
(1325, 'Iborfia', '8984', 19),
(1326, 'Ibr??ny', '4484', 15),
(1327, 'Igal', '7275', 14),
(1328, 'Igar', '7015', 6),
(1329, 'Igar', '7016', 6),
(1330, 'Igrici', '3459', 4),
(1331, 'Iharos', '8726', 14),
(1332, 'Iharosber??ny', '8725', 14),
(1333, 'Ikerv??r', '9756', 17),
(1334, 'Iklad', '2181', 13),
(1335, 'Iklanber??ny', '9634', 17),
(1336, 'Ikl??db??rd??ce', '8958', 19),
(1337, 'Ikr??ny', '9141', 7),
(1338, 'Iliny', '2675', 12),
(1339, 'Ilk', '4566', 15),
(1340, 'Illocska', '7775', 2),
(1341, 'Imola', '3724', 4),
(1342, 'Imrehegy', '6238', 1),
(1343, 'In??ncs', '3851', 4),
(1344, 'In??rcs', '2365', 13),
(1345, 'Inke', '8724', 14),
(1346, 'Ipacsfa', '7847', 2),
(1347, 'Ipolydam??sd', '2631', 13),
(1348, 'Ipolytarn??c', '3138', 12),
(1349, 'Ipolyt??lgyes', '2633', 13),
(1350, 'Ipolyvece', '2669', 12),
(1351, 'Iregszemcse', '7095', 16),
(1352, 'Irota', '3786', 4),
(1353, 'Isaszeg', '2117', 13),
(1354, 'Isp??nk', '9941', 17),
(1355, 'Istenmezeje', '3253', 9),
(1356, 'Istv??ndi', '7987', 14),
(1357, 'Iszkaszentgy??rgy', '8043', 6),
(1358, 'Iszk??z', '8493', 18),
(1359, 'Isztim??r', '8045', 6),
(1360, 'Iv??d', '3248', 9),
(1361, 'Iv??n', '9374', 7),
(1362, 'Iv??nbatty??n', '7772', 2),
(1363, 'Iv??nc', '9931', 17),
(1364, 'Iv??ncsa', '2454', 6),
(1365, 'Iv??nd??rda', '7781', 2),
(1366, 'Izm??ny', '7353', 16),
(1367, 'Izs??k', '6070', 1),
(1368, 'Izs??falva', '3741', 4),
(1369, 'J??g??nak', '7362', 16),
(1370, 'J??k', '9798', 17),
(1371, 'Jakabsz??ll??s', '6078', 1),
(1372, 'J??kfa', '9643', 17),
(1373, 'J??kfalva', '3721', 4),
(1374, 'J??k??', '7525', 14),
(1375, 'J??nd', '4841', 15),
(1376, 'J??nkmajtis', '4741', 15),
(1377, 'J??noshalma', '6440', 1),
(1378, 'J??nosh??za', '9545', 17),
(1379, 'J??noshida', '5143', 10),
(1380, 'J??nossomorja', '9241', 7),
(1381, 'J??nossomorja', '9242', 7),
(1382, 'J??rd??nh??za', '3664', 4),
(1383, 'J??rmi', '4337', 15),
(1384, 'J??sd', '8424', 18),
(1385, 'J??sz??g??', '5124', 10),
(1386, 'J??szals??szentgy??rgy', '5054', 10),
(1387, 'J??szap??ti', '5130', 10),
(1388, 'J??sz??roksz??ll??s', '5123', 10),
(1389, 'J??szber??ny', '5100', 10),
(1390, 'J??szber??ny', '5152', 10),
(1391, 'J??szboldogh??za', '5144', 10),
(1392, 'J??szd??zsa', '5122', 10),
(1393, 'J??szfels??szentgy??rgy', '5111', 10),
(1394, 'J??szf??nyszaru', '5126', 10),
(1395, 'J??sziv??ny', '5135', 10),
(1396, 'J??szj??k??halma', '5121', 10),
(1397, 'J??szkarajen??', '2746', 13),
(1398, 'J??szkis??r', '5137', 10),
(1399, 'J??szlad??ny', '5055', 10),
(1400, 'J??szszentandr??s', '5136', 10),
(1401, 'J??szszentl??szl??', '6133', 1),
(1402, 'J??sztelek', '5141', 10),
(1403, 'J??ke', '4611', 15),
(1404, 'Jen??', '8146', 6),
(1405, 'Jobah??za', '9323', 7),
(1406, 'Jobb??gyi', '3063', 12),
(1407, 'J??svaf??', '3758', 4),
(1408, 'Juta', '7431', 14),
(1409, 'Kaba', '4183', 8),
(1410, 'Kacorlak', '8773', 19),
(1411, 'K??cs', '3424', 4),
(1412, 'Kacs??ta', '7940', 2),
(1413, 'Kadark??t', '7530', 14),
(1414, 'Kaj??rp??c', '9123', 7),
(1415, 'Kaj??sz??', '2472', 6),
(1416, 'Kajdacs', '7051', 16),
(1417, 'Kakasd', '7122', 16),
(1418, 'K??kics', '7958', 2),
(1419, 'Kakucs', '2366', 13),
(1420, 'K??l', '3350', 9),
(1421, 'Kalazn??', '7194', 16),
(1422, 'K??ld', '9673', 17),
(1423, 'K??ll??', '2175', 12),
(1424, 'Kall??sd', '8785', 19),
(1425, 'K??ll??semj??n', '4324', 15),
(1426, 'K??lm??ncsa', '7538', 14),
(1427, 'K??lm??nh??za', '4434', 15),
(1428, 'K??l??cfa', '8988', 19),
(1429, 'Kalocsa', '6300', 1),
(1430, 'K??loz', '8124', 6),
(1431, 'K??m', '9841', 17),
(1432, 'Kamond', '8469', 18),
(1433, 'Kamut', '5673', 3),
(1434, 'K??n??', '3735', 4),
(1435, 'K??ntorj??nosi', '4335', 15),
(1436, 'K??ny', '3821', 4),
(1437, 'K??nya', '8667', 14),
(1438, 'K??nyav??r', '8956', 19),
(1439, 'Kapolcs', '8294', 18),
(1440, 'K??polna', '3355', 9),
(1441, 'K??poln??sny??k', '2475', 6),
(1442, 'Kapoly', '8671', 14),
(1443, 'Kaposf??', '7523', 14),
(1444, 'Kaposgyarmat', '7473', 14),
(1445, 'Kaposhomok', '7261', 14),
(1446, 'Kaposkereszt??r', '7258', 14),
(1447, 'Kaposm??r??', '7521', 14),
(1448, 'Kapospula', '7251', 16),
(1449, 'Kaposszekcs??', '7361', 16),
(1450, 'Kaposszerdahely', '7476', 14),
(1451, 'Kapos??jlak', '7522', 14),
(1452, 'Kaposv??r', '7400', 14),
(1453, 'K??ptalanfa', '8471', 18),
(1454, 'K??ptalant??ti', '8283', 18),
(1455, 'Kapuv??r', '9330', 7),
(1456, 'Kapuv??r', '9339', 7),
(1457, 'K??ra', '7285', 14),
(1458, 'Kar??csond', '3281', 9),
(1459, 'Kar??d', '8676', 14),
(1460, 'Karak??', '9547', 17),
(1461, 'Karak??sz??rcs??k', '8491', 18),
(1462, 'Karancsalja', '3181', 12),
(1463, 'Karancsber??ny', '3137', 12),
(1464, 'Karancskeszi', '3183', 12),
(1465, 'Karancslapujt??', '3182', 12),
(1466, 'Karancss??g', '3163', 12),
(1467, 'K??r??sz', '7333', 2),
(1468, 'Karcag', '5300', 10),
(1469, 'Karcsa', '3963', 4),
(1470, 'Kardos', '5552', 3),
(1471, 'Kardosk??t', '5945', 3),
(1472, 'Karmacs', '8354', 19),
(1473, 'K??rolyh??za', '9182', 7),
(1474, 'Karos', '3962', 4),
(1475, 'Kartal', '2173', 13),
(1476, 'K??s??d', '7827', 2),
(1477, 'Kaskanty??', '6211', 1),
(1478, 'Kast??lyosdomb??', '7977', 14),
(1479, 'Kaszaper', '5948', 3),
(1480, 'Kasz??', '7564', 14),
(1481, 'Kat??dfa', '7914', 2),
(1482, 'Katafa', '9915', 17),
(1483, 'K??toly', '7661', 2),
(1484, 'Katym??r', '6455', 1),
(1485, 'K??va', '2215', 13),
(1486, 'K??v??s', '8994', 19),
(1487, 'Kaz??r', '3127', 12),
(1488, 'Kaz??r', '3147', 12),
(1489, 'Kazincbarcika', '3700', 4),
(1490, 'K??zsm??rk', '3831', 4),
(1491, 'Kazsok', '7274', 14),
(1492, 'Kecel', '6237', 1),
(1493, 'Kecsk??d', '2852', 11),
(1494, 'Kecskem??t', '6000', 1),
(1495, 'Kecskem??t', '6008', 1),
(1496, 'Kecskem??t', '6044', 1),
(1497, 'Kehidakust??ny', '8784', 19),
(1498, 'K??k', '4515', 15),
(1499, 'K??kcse', '4494', 15),
(1500, 'K??ked', '3899', 4),
(1501, 'K??kesd', '7661', 2),
(1502, 'K??kk??t', '8254', 18),
(1503, 'Kelebia', '6423', 1),
(1504, 'Kel??d', '9549', 17),
(1505, 'Kelem??r', '3728', 4),
(1506, 'K??leshalom', '6444', 1),
(1507, 'Kelev??z', '8714', 14),
(1508, 'Kemecse', '4501', 15),
(1509, 'Kemence', '2638', 13),
(1510, 'Kemendoll??r', '8931', 19),
(1511, 'Kemenesh??gy??sz', '8516', 18),
(1512, 'Kemenesk??polna', '9553', 17),
(1513, 'Kemenesmagasi', '9522', 17),
(1514, 'Kemenesmih??lyfa', '9511', 17),
(1515, 'Kemenesp??lfa', '9544', 17),
(1516, 'Kemeness??mj??n', '9517', 17),
(1517, 'Kemenesszentm??rton', '9521', 17),
(1518, 'Kemenesszentp??ter', '8518', 18),
(1519, 'Kem??nfa', '8995', 19),
(1520, 'K??mes', '7843', 2),
(1521, 'Kemestar??dfa', '9923', 17),
(1522, 'Kemse', '7839', 2),
(1523, 'Kenderes', '5331', 10),
(1524, 'Kenderes', '5349', 10),
(1525, 'Ken??z', '9752', 17),
(1526, 'Ken??zl??', '3955', 4),
(1527, 'Kengyel', '5083', 10),
(1528, 'Kenyeri', '9514', 17),
(1529, 'Kercaszomor', '9945', 17),
(1530, 'Kercseliget', '7256', 14),
(1531, 'Kerecsend', '3396', 9),
(1532, 'Kerecseny', '8745', 19),
(1533, 'Kerekegyh??za', '6041', 1),
(1534, 'Kereki', '8618', 14),
(1535, 'Ker??kteleki', '2882', 11),
(1536, 'Kerepes', '2144', 13),
(1537, 'Kerepes', '2145', 13),
(1538, 'Kereszt??te', '3821', 4),
(1539, 'Kerkabarab??s', '8971', 19),
(1540, 'Kerkafalva', '8973', 19),
(1541, 'Kerkakutas', '8973', 19),
(1542, 'Kerk??sk??polna', '9944', 17),
(1543, 'Kerkaszentkir??ly', '8874', 19),
(1544, 'Kerkatesk??nd', '8879', 19),
(1545, 'K??rsemj??n', '4912', 15),
(1546, 'Kerta', '8492', 18),
(1547, 'Kert??szsziget', '5526', 3),
(1548, 'Keszeg', '2616', 12),
(1549, 'Keszny??ten', '3579', 4),
(1550, 'Kesz??hidegk??t', '7062', 16),
(1551, 'Keszthely', '8360', 19),
(1552, 'Keszt??lc', '2517', 11),
(1553, 'Kesz??', '7668', 2),
(1554, 'K??tbodony', '2655', 12),
(1555, 'K??tegyh??za', '5741', 3),
(1556, 'K??thely', '8713', 14),
(1557, 'K??tp??', '5411', 10),
(1558, 'K??tsoprony', '5674', 3),
(1559, 'K??t??jfalu', '7975', 2),
(1560, 'K??tv??lgy', '9982', 17),
(1561, 'K??ty', '7174', 16),
(1562, 'Kevermes', '5744', 3),
(1563, 'Kilim??n', '8774', 19),
(1564, 'Kimle', '9181', 7),
(1565, 'Kincsesb??nya', '8044', 6),
(1566, 'Kir??ld', '3657', 4),
(1567, 'Kir??lyegyh??za', '7953', 2),
(1568, 'Kir??lyhegyes', '6911', 5),
(1569, 'Kir??lyszentistv??n', '8195', 18),
(1570, 'Kisap??ti', '8284', 18),
(1571, 'Kisapostag', '2428', 6),
(1572, 'Kisar', '4921', 15),
(1573, 'Kisasszond', '7523', 14),
(1574, 'Kisasszonyfa', '7954', 2),
(1575, 'Kisbabot', '9133', 7),
(1576, 'Kisb??gyon', '3046', 12),
(1577, 'Kisbajcs', '9062', 7),
(1578, 'Kisbajom', '7542', 14),
(1579, 'Kisb??rap??ti', '7282', 14),
(1580, 'Kisb??rk??ny', '3075', 12),
(1581, 'Kisb??r', '2870', 11),
(1582, 'Kisb??r', '2879', 11),
(1583, 'Kisber??ny', '8693', 14),
(1584, 'Kisberzseny', '8477', 18),
(1585, 'Kisbeszterce', '7391', 2),
(1586, 'Kisbodak', '9234', 7),
(1587, 'Kisbucsa', '8925', 19),
(1588, 'Kisbudm??r', '7756', 2),
(1589, 'Kiscs??cs', '3578', 4),
(1590, 'Kiscsehi', '8888', 19),
(1591, 'Kiscs??sz', '8494', 18),
(1592, 'Kisd??r', '7814', 2),
(1593, 'Kisdobsza', '7985', 2),
(1594, 'Kisdombegyh??z', '5837', 3),
(1595, 'Kisdorog', '7159', 16),
(1596, 'Kisecset', '2655', 12),
(1597, 'Kisfalud', '9341', 7),
(1598, 'Kisf??zes', '3256', 9),
(1599, 'Kisg??rb??', '8356', 19),
(1600, 'Kisgyal??n', '7279', 14),
(1601, 'Kisgy??r', '3556', 4),
(1602, 'Kishajm??s', '7391', 2),
(1603, 'Kishars??ny', '7800', 2),
(1604, 'Kisharty??n', '3161', 12),
(1605, 'Kisherend', '7763', 2),
(1606, 'Kish??dos', '4977', 15),
(1607, 'Kishuta', '3994', 4),
(1608, 'Kisigm??nd', '2948', 11),
(1609, 'Kisjakabfalva', '7773', 2),
(1610, 'Kiskassa', '7766', 2),
(1611, 'Kiskinizs', '3843', 4),
(1612, 'Kisk??re', '3384', 9),
(1613, 'Kisk??r??s', '6200', 1),
(1614, 'Kiskorp??d', '7524', 14),
(1615, 'Kiskunf??legyh??za', '6100', 1),
(1616, 'Kiskunhalas', '6400', 1),
(1617, 'Kiskunlach??za', '2340', 13),
(1618, 'Kiskunmajsa', '6120', 1),
(1619, 'Kiskutas', '8911', 19),
(1620, 'Kisl??ng', '8156', 6),
(1621, 'Kisl??ta', '4325', 15),
(1622, 'Kislipp??', '7775', 2),
(1623, 'Kisl??d', '8446', 18),
(1624, 'Kism??nyok', '7356', 16),
(1625, 'Kismarja', '4126', 8),
(1626, 'Kismaros', '2623', 13),
(1627, 'Kisnam??ny', '4737', 15),
(1628, 'Kisn??na', '3264', 9),
(1629, 'Kisn??medi', '2165', 13),
(1630, 'Kisny??r??d', '7759', 2),
(1631, 'Kisoroszi', '2024', 13),
(1632, 'Kispal??d', '4956', 15),
(1633, 'Kisp??li', '8912', 19),
(1634, 'Kispirit', '8496', 18),
(1635, 'Kisr??kos', '9936', 17),
(1636, 'Kisr??cse', '8756', 19),
(1637, 'Kisrozv??gy', '3965', 4),
(1638, 'Kissik??tor', '3627', 4),
(1639, 'Kissomly??', '9555', 17),
(1640, 'Kissz??ll??s', '6421', 1),
(1641, 'Kissz??kely', '7082', 16),
(1642, 'Kisszekeres', '4963', 15),
(1643, 'Kisszentm??rton', '7841', 2),
(1644, 'Kissziget', '8957', 19),
(1645, 'Kissz??l??s', '8483', 18),
(1646, 'Kistam??si', '7981', 2),
(1647, 'Kistapolca', '7823', 2),
(1648, 'Kistarcsa', '2143', 13),
(1649, 'Kistelek', '6760', 5),
(1650, 'Kistokaj', '3553', 4),
(1651, 'Kistolm??cs', '8868', 19),
(1652, 'Kistorm??s', '7068', 16),
(1653, 'Kist??tfalu', '7768', 2),
(1654, 'Kis??jsz??ll??s', '5310', 10),
(1655, 'Kisunyom', '9772', 17),
(1656, 'Kisv??rda', '4600', 15),
(1657, 'Kisvars??ny', '4811', 15),
(1658, 'Kisv??s??rhely', '8341', 19),
(1659, 'Kisvaszar', '7381', 2),
(1660, 'Kisvejke', '7183', 16),
(1661, 'Kiszombor', '6775', 5),
(1662, 'Kiszsid??ny', '9733', 17),
(1663, 'Kl??rafalva', '6773', 5),
(1664, 'K??bl??ny', '7334', 2),
(1665, 'Kocs', '2898', 11),
(1666, 'Kocs??r', '2755', 13),
(1667, 'K??csk', '9553', 17),
(1668, 'Kocsola', '7212', 16),
(1669, 'Kocsord', '4751', 15),
(1670, 'K??ka', '2243', 13),
(1671, 'Kokad', '4284', 8),
(1672, 'K??k??ny', '7668', 2),
(1673, 'K??k??t', '7530', 14),
(1674, 'K??lcse', '4965', 15),
(1675, 'K??lesd', '7052', 16),
(1676, 'K??lked', '7717', 2),
(1677, 'Kolont??r', '8468', 18),
(1678, 'Kom??di', '4138', 8),
(1679, 'Kom??rom', '2900', 11),
(1680, 'Kom??rom', '2903', 11),
(1681, 'Kom??rom', '2921', 11),
(1682, 'Komj??ti', '3765', 4),
(1683, 'Koml??', '7300', 2),
(1684, 'Koml??', '7305', 2),
(1685, 'K??ml??', '3372', 9),
(1686, 'K??ml??d', '2853', 11),
(1687, 'Koml??dt??tfalu', '4765', 15),
(1688, 'Koml??sd', '7582', 14),
(1689, 'Koml??ska', '3937', 4),
(1690, 'Komor??', '4622', 15),
(1691, 'K??m??r??', '4943', 15),
(1692, 'K??mp??c', '6134', 1),
(1693, 'Kompolt', '3356', 9),
(1694, 'Kond??', '3775', 4),
(1695, 'Kondorfa', '9943', 17),
(1696, 'Kondoros', '5553', 3),
(1697, 'K??ny', '9144', 7),
(1698, 'Kony??r', '4133', 8),
(1699, 'K??ph??za', '9495', 7),
(1700, 'Kopp??nysz??nt??', '7094', 16),
(1701, 'Korl??t', '3886', 4),
(1702, 'K??rmend', '9900', 17),
(1703, 'K??rmend', '9909', 17),
(1704, 'K??rnye', '2851', 11),
(1705, 'K??r??m', '3577', 4);
INSERT INTO `city` (`city_id`, `city_name`, `postal_code`, `region_id`) VALUES
(1706, 'Koronc??', '9113', 7),
(1707, 'K??r??s', '7841', 2),
(1708, 'K??r??shegy', '8617', 14),
(1709, 'K??r??slad??ny', '5516', 3),
(1710, 'K??r??snagyhars??ny', '5539', 3),
(1711, 'K??r??sszak??l', '4136', 8),
(1712, 'K??r??sszegap??ti', '4135', 8),
(1713, 'K??r??starcsa', '5622', 3),
(1714, 'K??r??stet??tlen', '2745', 13),
(1715, 'K??r??s??jfalu', '5536', 3),
(1716, 'Kosd', '2612', 13),
(1717, 'K??spallag', '2625', 13),
(1718, 'K??sz??rhegy', '8152', 6),
(1719, 'K??szeg', '9730', 17),
(1720, 'K??szegdoroszl??', '9725', 17),
(1721, 'K??szegpaty', '9739', 17),
(1722, 'K??szegszerdahely', '9725', 17),
(1723, 'K??taj', '4482', 15),
(1724, 'K??tcse', '8627', 14),
(1725, 'K??tegy??n', '5725', 3),
(1726, 'K??telek', '5062', 10),
(1727, 'Kov??cshida', '7847', 2),
(1728, 'Kov??cssz??n??ja', '7678', 2),
(1729, 'Kov??csv??g??s', '3992', 4),
(1730, 'K??v??g????rs', '8254', 18),
(1731, 'K??v??g??sz??l??s', '7673', 2),
(1732, 'K??v??g??t??tt??s', '7675', 2),
(1733, 'K??vegy', '6912', 5),
(1734, 'K??vesk??l', '8274', 18),
(1735, 'Koz??rd', '3053', 12),
(1736, 'Koz??rmisleny', '7761', 2),
(1737, 'Kozmadombja', '8988', 19),
(1738, 'Krasznokvajda', '3821', 4),
(1739, 'K??bekh??za', '6755', 5),
(1740, 'Kulcs', '2458', 6),
(1741, 'K??ls??s??rd', '8978', 19),
(1742, 'K??ls??vat', '9532', 18),
(1743, 'Kunadacs', '6097', 1),
(1744, 'Kun??gota', '5746', 3),
(1745, 'Kunbaja', '6435', 1),
(1746, 'Kunbaracs', '6043', 1),
(1747, 'Kuncsorba', '5412', 10),
(1748, 'Kunfeh??rt??', '6413', 1),
(1749, 'K??ng??s', '8162', 18),
(1750, 'Kunhegyes', '5340', 10),
(1751, 'Kunmadaras', '5321', 10),
(1752, 'Kunpesz??r', '6096', 1),
(1753, 'Kunsz??ll??s', '6115', 1),
(1754, 'Kunszentm??rton', '5440', 10),
(1755, 'Kunszentm??rton', '5449', 10),
(1756, 'Kunszentmikl??s', '6090', 1),
(1757, 'Kunsziget', '9184', 7),
(1758, 'Kup', '8595', 18),
(1759, 'Kupa', '3813', 4),
(1760, 'Kurd', '7226', 16),
(1761, 'Kurity??n', '3732', 4),
(1762, 'Kust??nszeg', '8919', 19),
(1763, 'Kutas', '7541', 14),
(1764, 'Kutas??', '3066', 12),
(1765, 'L??batlan', '2541', 11),
(1766, 'L??bod', '7551', 14),
(1767, 'L??cacs??ke', '3967', 4),
(1768, 'Lad', '7535', 14),
(1769, 'Lad??nybene', '6045', 1),
(1770, 'L??dbeseny??', '3780', 4),
(1771, 'Lajoskom??rom', '8136', 6),
(1772, 'Lajosmizse', '6050', 1),
(1773, 'Lak', '3786', 4),
(1774, 'Lakhegy', '8913', 19),
(1775, 'Lakitelek', '6065', 1),
(1776, 'Lak??csa', '7918', 14),
(1777, 'L??nycs??k', '7759', 2),
(1778, 'L??paf??', '7214', 16),
(1779, 'Lap??ncsa', '7775', 2),
(1780, 'Laskod', '4543', 15),
(1781, 'Lasztonya', '8887', 19),
(1782, 'L??tr??ny', '8681', 14),
(1783, 'L??zi', '9089', 7),
(1784, 'Le??nyfalu', '2016', 13),
(1785, 'Le??nyv??r', '2518', 11),
(1786, 'L??b??ny', '9155', 7),
(1787, 'Leg??nd', '2619', 12),
(1788, 'Legyesb??nye', '3904', 4),
(1789, 'L??h', '3832', 4),
(1790, 'L??n??rddar??c', '3648', 4),
(1791, 'Lendvadedes', '8978', 19),
(1792, 'Lendvajakabfa', '8977', 19),
(1793, 'Lengyel', '7184', 16),
(1794, 'Lengyelt??ti', '8693', 14),
(1795, 'Lenti', '8960', 19),
(1796, 'Lenti', '8966', 19),
(1797, 'Leps??ny', '8132', 6),
(1798, 'Lesencefalu', '8318', 18),
(1799, 'Lesenceistv??nd', '8319', 18),
(1800, 'Lesencetomaj', '8318', 18),
(1801, 'L??tav??rtes', '4281', 8),
(1802, 'L??tav??rtes', '4283', 8),
(1803, 'Letenye', '8868', 19),
(1804, 'Letk??s', '2632', 13),
(1805, 'Lev??l', '9221', 7),
(1806, 'Levelek', '4555', 15),
(1807, 'Libickozma', '8707', 14),
(1808, 'Lick??vadamos', '8981', 19),
(1809, 'Liget', '7331', 2),
(1810, 'Ligetfalva', '8782', 19),
(1811, 'Lip??t', '9233', 7),
(1812, 'Lipp??', '7781', 2),
(1813, 'Lipt??d', '7757', 2),
(1814, 'Lispeszentadorj??n', '8888', 19),
(1815, 'Lisz??', '8831', 19),
(1816, 'Lit??r', '8196', 18),
(1817, 'Litka', '3866', 4),
(1818, 'Litke', '3186', 12),
(1819, 'L??cs', '9634', 17),
(1820, 'L??k??sh??za', '5743', 3),
(1821, 'L??k??t', '8425', 18),
(1822, 'L??nya', '4836', 15),
(1823, 'L??r??v', '2309', 13),
(1824, 'L??rinci', '3021', 9),
(1825, 'L??rinci', '3022', 9),
(1826, 'L??rinci', '3024', 9),
(1827, 'Loth??rd', '7761', 2),
(1828, 'Lovas', '8228', 18),
(1829, 'Lovasber??ny', '8093', 6),
(1830, 'Lov??szhet??ny', '7720', 2),
(1831, 'Lov??szi', '8878', 19),
(1832, 'Lov??szpatona', '8553', 18),
(1833, 'L??v??', '9461', 7),
(1834, 'L??v??petri', '4633', 15),
(1835, 'Lucfalva', '3129', 12),
(1836, 'Lud??nyhal??szi', '3188', 12),
(1837, 'Ludas', '3274', 9),
(1838, 'Luk??csh??za', '9724', 17),
(1839, 'Lulla', '8660', 14),
(1840, 'L??zsok', '7838', 2),
(1841, 'M??d', '3909', 4),
(1842, 'Madaras', '6456', 1),
(1843, 'Madocsa', '7026', 16),
(1844, 'Magl??ca', '9169', 7),
(1845, 'Magl??d', '2234', 13),
(1846, 'M??gocs', '7342', 2),
(1847, 'Magosliget', '4953', 15),
(1848, 'Magy', '4556', 15),
(1849, 'Magyaralm??s', '8071', 6),
(1850, 'Magyarat??d', '7463', 14),
(1851, 'Magyarb??nhegyes', '5667', 3),
(1852, 'Magyarb??ly', '7775', 2),
(1853, 'Magyarcsan??d', '6932', 5),
(1854, 'Magyardombegyh??z', '5838', 3),
(1855, 'Magyaregregy', '7332', 2),
(1856, 'Magyaregres', '7441', 14),
(1857, 'Magyarf??ld', '8973', 19),
(1858, 'Magyarg??c', '3133', 12),
(1859, 'Magyargencs', '8517', 18),
(1860, 'Magyarhertelend', '7394', 2),
(1861, 'Magyarhomorog', '4137', 8),
(1862, 'Magyarkereszt??r', '9346', 7),
(1863, 'Magyarkeszi', '7098', 16),
(1864, 'Magyarlak', '9962', 17),
(1865, 'Magyarlukafa', '7925', 2),
(1866, 'Magyarmecske', '7954', 2),
(1867, 'Magyarn??dalja', '9909', 17),
(1868, 'Magyarn??ndor', '2694', 12),
(1869, 'Magyarpol??ny', '8449', 18),
(1870, 'Magyarsarl??s', '7761', 2),
(1871, 'Magyarszecs??d', '9912', 17),
(1872, 'Magyarsz??k', '7396', 2),
(1873, 'Magyarszentmikl??s', '8776', 19),
(1874, 'Magyarszerdahely', '8776', 19),
(1875, 'Magyarszombatfa', '9946', 17),
(1876, 'Magyartelek', '7954', 2),
(1877, 'Majosh??za', '2339', 13),
(1878, 'Majs', '7783', 2),
(1879, 'Mak??d', '2322', 13),
(1880, 'Makkoshotyka', '3959', 4),
(1881, 'Makl??r', '3397', 9),
(1882, 'Mak??', '6900', 5),
(1883, 'Mak??', '6903', 5),
(1884, 'Malomsok', '8533', 18),
(1885, 'M??lyi', '3434', 4),
(1886, 'M??lyinka', '3645', 4),
(1887, 'M??nd', '4942', 15),
(1888, 'M??ndok', '4644', 15),
(1889, 'M??nfa', '7304', 2),
(1890, 'M??ny', '2065', 6),
(1891, 'Mar??za', '7733', 2),
(1892, 'Marcalgergelyi', '9534', 18),
(1893, 'Marcali', '8700', 14),
(1894, 'Marcali', '8709', 14),
(1895, 'Marcali', '8714', 14),
(1896, 'Marcalt??', '8531', 18),
(1897, 'Marcalt??', '8532', 18),
(1898, 'M??rfa', '7817', 2),
(1899, 'M??riahalom', '2527', 11),
(1900, 'M??riak??lnok', '9231', 7),
(1901, 'M??riak??m??nd', '7663', 2),
(1902, 'M??rianosztra', '2629', 13),
(1903, 'M??riap??cs', '4326', 15),
(1904, 'Markaz', '3262', 9),
(1905, 'M??rkh??za', '3075', 12),
(1906, 'M??rk??', '8441', 18),
(1907, 'Mark??c', '7967', 2),
(1908, 'Markotab??d??ge', '9164', 7),
(1909, 'Mar??c', '8888', 19),
(1910, 'Mar??csa', '7960', 2),
(1911, 'M??rok', '7774', 2),
(1912, 'M??rokf??ld', '8976', 19),
(1913, 'M??rokpapi', '4932', 15),
(1914, 'Maroslele', '6921', 5),
(1915, 'M??rt??ly', '6636', 5),
(1916, 'Martf??', '5435', 10),
(1917, 'Martonfa', '7720', 2),
(1918, 'Martonv??s??r', '2462', 6),
(1919, 'Martonyi', '3755', 4),
(1920, 'M??t??szalka', '4700', 15),
(1921, 'M??t??telke', '6452', 1),
(1922, 'M??traballa', '3247', 9),
(1923, 'M??traderecske', '3246', 9),
(1924, 'M??tramindszent', '3155', 12),
(1925, 'M??tranov??k', '3143', 12),
(1926, 'M??tranov??k', '3144', 12),
(1927, 'M??traszele', '3142', 12),
(1928, 'M??traszentimre', '3234', 9),
(1929, 'M??traszentimre', '3235', 9),
(1930, 'M??trasz??l??s', '3068', 12),
(1931, 'M??traterenye', '3145', 12),
(1932, 'M??traterenye', '3146', 12),
(1933, 'M??travereb??ly', '3077', 12),
(1934, 'Matty', '7854', 2),
(1935, 'M??ty??sdomb', '8134', 6),
(1936, 'M??tyus', '4835', 15),
(1937, 'M??za', '7351', 2),
(1938, 'Mecsekn??dasd', '7695', 2),
(1939, 'Mecsekp??l??ske', '7300', 2),
(1940, 'Mecs??r', '9176', 7),
(1941, 'Medgyesbodz??s', '5663', 3),
(1942, 'Medgyesbodz??s', '5664', 3),
(1943, 'Medgyesegyh??za', '5666', 3),
(1944, 'Medgyesegyh??za', '5752', 3),
(1945, 'Medina', '7057', 16),
(1946, 'Meggyeskov??csi', '9757', 17),
(1947, 'Megyasz??', '3718', 4),
(1948, 'Megyehid', '9754', 17),
(1949, 'Megyer', '8348', 18),
(1950, 'M??hker??k', '5726', 3),
(1951, 'M??htelek', '4975', 15),
(1952, 'Mek??nyes', '7344', 2),
(1953, 'M??lyk??t', '6449', 1),
(1954, 'Mencshely', '8271', 18),
(1955, 'Mende', '2235', 13),
(1956, 'M??ra', '3871', 4),
(1957, 'Merenye', '7981', 2),
(1958, 'M??rges', '9136', 7),
(1959, 'M??rk', '4352', 15),
(1960, 'Mernye', '7453', 14),
(1961, 'Mersev??t', '9531', 17),
(1962, 'Mesterh??za', '9662', 17),
(1963, 'Mesteri', '9551', 17),
(1964, 'Mestersz??ll??s', '5452', 10),
(1965, 'Meszes', '3754', 4),
(1966, 'Meszlen', '9745', 17),
(1967, 'Mesztegny??', '8716', 14),
(1968, 'Mez??ber??ny', '5650', 3),
(1969, 'Mez??cs??t', '3450', 4),
(1970, 'Mez??csokonya', '7434', 14),
(1971, 'Mez??d', '7370', 2),
(1972, 'Mez??falva', '2422', 6),
(1973, 'Mez??gy??n', '5732', 3),
(1974, 'Mez??hegyes', '5820', 3),
(1975, 'Mez??h??k', '5453', 10),
(1976, 'Mez??keresztes', '3441', 4),
(1977, 'Mez??kom??rom', '8137', 6),
(1978, 'Mez??kov??csh??za', '5800', 3),
(1979, 'Mez??k??vesd', '3400', 4),
(1980, 'Mez??lad??ny', '4641', 15),
(1981, 'Mez??lak', '8514', 18),
(1982, 'Mez??nagymih??ly', '3443', 4),
(1983, 'Mez??ny??r??d', '3421', 4),
(1984, 'Mez????rs', '9097', 7),
(1985, 'Mez????rs', '9098', 7),
(1986, 'Mez??peterd', '4118', 8),
(1987, 'Mez??sas', '4134', 8),
(1988, 'Mez??szemere', '3378', 9),
(1989, 'Mez??szentgy??rgy', '8133', 6),
(1990, 'Mez??szilas', '7017', 6),
(1991, 'Mez??t??rk??ny', '3375', 9),
(1992, 'Mez??t??r', '5400', 10),
(1993, 'Mez??zombor', '3931', 4),
(1994, 'Mih??ld', '8825', 19),
(1995, 'Mih??lyfa', '8341', 19),
(1996, 'Mih??lygerge', '3184', 12),
(1997, 'Mih??lyh??za', '8513', 18),
(1998, 'Mih??lyi', '9342', 7),
(1999, 'Mike', '7512', 14),
(2000, 'Mikebuda', '2736', 13),
(2001, 'Mikekar??csonyfa', '8949', 19),
(2002, 'Mikep??rcs', '4271', 8),
(2003, 'Mikl??si', '7286', 14),
(2004, 'Mik??falva', '3344', 9),
(2005, 'Mik??h??za', '3989', 4),
(2006, 'Mikossz??plak', '9835', 17),
(2007, 'Milejszeg', '8917', 19),
(2008, 'Milota', '4948', 15),
(2009, 'Mindszent', '6630', 5),
(2010, 'Mindszentgodisa', '7391', 2),
(2011, 'Mindszentk??lla', '8282', 18),
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
(2038, 'M??cs??ny', '7163', 16),
(2039, 'Mogyor??d', '2146', 13),
(2040, 'Mogyor??sb??nya', '2535', 11),
(2041, 'Mogyor??ska', '3893', 4),
(2042, 'Moha', '8042', 6),
(2043, 'Moh??cs', '7700', 2),
(2044, 'Moh??cs', '7714', 2),
(2045, 'Moh??cs', '7715', 2),
(2046, 'Mohora', '2698', 12),
(2047, 'Moln??ri', '8863', 19),
(2048, 'Molnaszecs??d', '9912', 17),
(2049, 'Molv??ny', '7981', 2),
(2050, 'Monaj', '3812', 4),
(2051, 'Monok', '3905', 4),
(2052, 'Monor', '2200', 13),
(2053, 'Monor', '2213', 13),
(2054, 'M??nosb??l', '3345', 9),
(2055, 'Monostorap??ti', '8296', 18),
(2056, 'Monostorp??lyi', '4275', 8),
(2057, 'Monoszl??', '8273', 18),
(2058, 'Monyor??d', '7751', 2),
(2059, 'M??r', '8060', 6),
(2060, 'M??r??gy', '7165', 16),
(2061, 'M??rahalom', '6782', 5),
(2062, 'M??ricg??t', '6132', 1),
(2063, 'M??richida', '9131', 7),
(2064, 'Mosd??s', '7257', 14),
(2065, 'Mosonmagyar??v??r', '9200', 7),
(2066, 'Mosonszentmikl??s', '9154', 7),
(2067, 'Mosonszentmikl??s', '9183', 7),
(2068, 'Mosonszolnok', '9245', 7),
(2069, 'Mozsg??', '7932', 2),
(2070, 'Mucsfa', '7185', 16),
(2071, 'Mucsi', '7195', 16),
(2072, 'M??csony', '3744', 4),
(2073, 'Muhi', '3552', 4),
(2074, 'Murakereszt??r', '8834', 19),
(2075, 'Murar??tka', '8868', 19),
(2076, 'Muraszemenye', '8872', 19),
(2077, 'Murga', '7176', 16),
(2078, 'Murony', '5672', 3),
(2079, 'N??br??d', '4911', 15),
(2080, 'Nadap', '8097', 6),
(2081, 'N??dasd', '9915', 17),
(2082, 'N??dasdlad??ny', '8145', 6),
(2083, 'N??dudvar', '4181', 8),
(2084, 'N??gocs', '8674', 14),
(2085, 'Nagyacs??d', '8521', 18),
(2086, 'Nagyal??sony', '8484', 18),
(2087, 'Nagyar', '4922', 15),
(2088, 'Nagyat??d', '7500', 14),
(2089, 'Nagybajcs', '9063', 7),
(2090, 'Nagybajom', '7561', 14),
(2091, 'Nagybak??nak', '8821', 19),
(2092, 'Nagyb??nhegyes', '5668', 3),
(2093, 'Nagybaracska', '6527', 1),
(2094, 'Nagybarca', '3641', 4),
(2095, 'Nagyb??rk??ny', '3075', 12),
(2096, 'Nagyber??ny', '8656', 14),
(2097, 'Nagyberki', '7255', 14),
(2098, 'Nagyb??rzs??ny', '2634', 13),
(2099, 'Nagybudm??r', '7756', 2),
(2100, 'Nagycenk', '9485', 7),
(2101, 'Nagycs??ny', '7838', 2),
(2102, 'Nagycs??cs', '3598', 4),
(2103, 'Nagycsepely', '8628', 14),
(2104, 'Nagycserkesz', '4445', 15),
(2105, 'Nagyd??m', '8554', 18),
(2106, 'Nagydobos', '4823', 15),
(2107, 'Nagydobsza', '7985', 2),
(2108, 'Nagydorog', '7044', 16),
(2109, 'Nagyecsed', '4355', 15),
(2110, 'Nagy??r', '6917', 5),
(2111, 'Nagyeszterg??r', '8415', 18),
(2112, 'Nagyf??ged', '3282', 9),
(2113, 'Nagygeresd', '9664', 17),
(2114, 'Nagyg??rb??', '8356', 19),
(2115, 'Nagygyim??t', '8551', 18),
(2116, 'Nagyhajm??s', '7343', 2),
(2117, 'Nagyhal??sz', '4485', 15),
(2118, 'Nagyhars??ny', '7822', 2),
(2119, 'Nagyhegyes', '4064', 8),
(2120, 'Nagyh??dos', '4977', 15),
(2121, 'Nagyhuta', '3994', 4),
(2122, 'Nagyigm??nd', '2942', 11),
(2123, 'Nagyiv??n', '5363', 10),
(2124, 'Nagyk??ll??', '4320', 15),
(2125, 'Nagykamar??s', '5751', 3),
(2126, 'Nagykanizsa', '8800', 19),
(2127, 'Nagykanizsa', '8808', 19),
(2128, 'Nagykanizsa', '8809', 19),
(2129, 'Nagykanizsa', '8831', 19),
(2130, 'Nagykapornak', '8935', 19),
(2131, 'Nagykar??csony', '2425', 6),
(2132, 'Nagyk??ta', '2760', 13),
(2133, 'Nagykereki', '4127', 8),
(2134, 'Nagykereszt??r', '3129', 12),
(2135, 'Nagykinizs', '3844', 4),
(2136, 'Nagyk??k??nyes', '3012', 9),
(2137, 'Nagyk??lked', '9784', 17),
(2138, 'Nagyk??nyi', '7092', 16),
(2139, 'Nagyk??r??s', '2750', 13),
(2140, 'Nagykorp??d', '7545', 14),
(2141, 'Nagyk??r??', '5065', 10),
(2142, 'Nagykov??csi', '2094', 13),
(2143, 'Nagykoz??r', '7741', 2),
(2144, 'Nagykutas', '8911', 19),
(2145, 'Nagylak', '6933', 5),
(2146, 'Nagylengyel', '8983', 19),
(2147, 'Nagyl??c', '3175', 12),
(2148, 'Nagyl??k', '2435', 6),
(2149, 'Nagyl??zs', '9482', 7),
(2150, 'Nagym??gocs', '6622', 5),
(2151, 'Nagym??nyok', '7355', 16),
(2152, 'Nagymaros', '2626', 13),
(2153, 'Nagymizd??', '9913', 17),
(2154, 'Nagyny??r??d', '7784', 2),
(2155, 'Nagyoroszi', '2645', 12),
(2156, 'Nagyp??li', '8912', 19),
(2157, 'Nagypall', '7731', 2),
(2158, 'Nagypeterd', '7912', 2),
(2159, 'Nagypirit', '8496', 18),
(2160, 'Nagyr??b??', '4173', 8),
(2161, 'Nagyrada', '8746', 19),
(2162, 'Nagyr??kos', '9938', 17),
(2163, 'Nagyr??cse', '8756', 19),
(2164, 'Nagyr??de', '3214', 9),
(2165, 'Nagyr??v', '5463', 10),
(2166, 'Nagyrozv??gy', '3965', 4),
(2167, 'Nagys??p', '2524', 11),
(2168, 'Nagysimonyi', '9561', 17),
(2169, 'Nagyszak??csi', '8739', 14),
(2170, 'Nagysz??kely', '7085', 16),
(2171, 'Nagyszekeres', '4962', 15),
(2172, 'Nagysz??n??s', '5931', 3),
(2173, 'Nagyszentj??nos', '9072', 7),
(2174, 'Nagyszokoly', '7097', 16),
(2175, 'Nagyt??lya', '3398', 9),
(2176, 'Nagytarcsa', '2142', 13),
(2177, 'Nagytevel', '8562', 18),
(2178, 'Nagytilaj', '9832', 17),
(2179, 'Nagyt??ke', '6612', 5),
(2180, 'Nagyt??tfalu', '7800', 2),
(2181, 'Nagy??t', '3357', 9),
(2182, 'Nagyvars??ny', '4812', 15),
(2183, 'Nagyv??ty', '7912', 2),
(2184, 'Nagyv??zsony', '8291', 18),
(2185, 'Nagyvejke', '7186', 16),
(2186, 'Nagyveleg', '8065', 6),
(2187, 'Nagyvenyim', '2421', 6),
(2188, 'Nagyvisny??', '3349', 9),
(2189, 'Nak', '7215', 16),
(2190, 'Napkor', '4552', 15),
(2191, 'N??rai', '9797', 17),
(2192, 'Narda', '9793', 17),
(2193, 'Nasz??ly', '2899', 11),
(2194, 'N??gyes', '3463', 4),
(2195, 'Nek??zseny', '3646', 4),
(2196, 'Nemesap??ti', '8923', 19),
(2197, 'Nemesbikk', '3592', 4),
(2198, 'Nemesb??d', '9749', 17),
(2199, 'Nemesborzova', '4942', 15),
(2200, 'Nemesb??k', '8371', 19),
(2201, 'Nemescs??', '9739', 17),
(2202, 'Nemesd??d', '8722', 14),
(2203, 'Nemesg??rzs??ny', '8522', 18),
(2204, 'Nemesgul??cs', '8284', 18),
(2205, 'Nemeshany', '8471', 18),
(2206, 'Nemeshet??s', '8925', 19),
(2207, 'Nemeske', '7981', 2),
(2208, 'Nemesk??r', '9471', 7),
(2209, 'Nemeskereszt??r', '9548', 17),
(2210, 'Nemeskisfalud', '8717', 14),
(2211, 'Nemeskocs', '9542', 17),
(2212, 'Nemeskolta', '9775', 17),
(2213, 'Nemesl??dony', '9663', 17),
(2214, 'Nemesmedves', '9953', 17),
(2215, 'Nemesn??dudvar', '6345', 1),
(2216, 'Nemesn??p', '8976', 19),
(2217, 'Nemesp??tr??', '8856', 19),
(2218, 'Nemesr??d??', '8915', 19),
(2219, 'Nemesrempeholl??s', '9782', 17),
(2220, 'Nemess??ndorh??za', '8925', 19),
(2221, 'Nemesszal??k', '9533', 18),
(2222, 'Nemesszentandr??s', '8925', 19),
(2223, 'Nemesv??mos', '8248', 18),
(2224, 'Nemesvid', '8738', 14),
(2225, 'Nemesvita', '8311', 18),
(2226, 'N??metb??nya', '8581', 18),
(2227, 'N??metfalu', '8918', 19),
(2228, 'N??metk??r', '7039', 16),
(2229, 'Nemti', '3152', 12),
(2230, 'Neszm??ly', '2544', 11),
(2231, 'N??zsa', '2618', 12),
(2232, 'Nick', '9652', 17),
(2233, 'Nikla', '8706', 14),
(2234, 'N??gr??d', '2642', 12),
(2235, 'N??gr??dk??vesd', '2691', 12),
(2236, 'N??gr??dmarcal', '2675', 12),
(2237, 'N??gr??dmegyer', '3132', 12),
(2238, 'N??gr??ds??p', '2685', 12),
(2239, 'N??gr??dsipek', '3179', 12),
(2240, 'N??gr??dszak??l', '3187', 12),
(2241, 'N??r??p', '8591', 18),
(2242, 'Noszlop', '8456', 18),
(2243, 'Noszvaj', '3325', 9),
(2244, 'N??tincs', '2610', 12),
(2245, 'Nova', '8948', 19),
(2246, 'Novaj', '3327', 9),
(2247, 'Novajidr??ny', '3872', 4),
(2248, 'Nyalka', '9096', 7),
(2249, 'Ny??r??d', '8512', 18),
(2250, 'Ny??regyh??za', '2723', 13),
(2251, 'Ny??rl??rinc', '6032', 1),
(2252, 'Ny??rsap??t', '2712', 13),
(2253, 'Ny??kl??dh??za', '3433', 4),
(2254, 'Nyerges??jfalu', '2536', 11),
(2255, 'Nyerges??jfalu', '2537', 11),
(2256, 'Ny??sta', '3809', 4),
(2257, 'Nyim', '8612', 14),
(2258, 'Ny??r??br??ny', '4264', 8),
(2259, 'Ny??racs??d', '4262', 8),
(2260, 'Nyir??d', '8454', 18),
(2261, 'Ny??radony', '4252', 8),
(2262, 'Ny??radony', '4253', 8),
(2263, 'Ny??radony', '4254', 8),
(2264, 'Ny??rb??tor', '4300', 15),
(2265, 'Ny??rb??ltek', '4372', 15),
(2266, 'Ny??rbog??t', '4361', 15),
(2267, 'Ny??rbogd??ny', '4511', 15),
(2268, 'Ny??rcsaholy', '4356', 15),
(2269, 'Ny??rcs??sz??ri', '4331', 15),
(2270, 'Ny??rderzs', '4332', 15),
(2271, 'Ny??regyh??za', '4246', 15),
(2272, 'Ny??regyh??za', '4400', 15),
(2273, 'Ny??regyh??za', '4405', 15),
(2274, 'Ny??regyh??za', '4412', 15),
(2275, 'Ny??regyh??za', '4431', 15),
(2276, 'Ny??regyh??za', '4432', 15),
(2277, 'Ny??regyh??za', '4433', 15),
(2278, 'Ny??regyh??za', '4481', 15),
(2279, 'Ny??regyh??za', '4551', 15),
(2280, 'Ny??rgelse', '4362', 15),
(2281, 'Ny??rgyulaj', '4311', 15),
(2282, 'Ny??ri', '3997', 4),
(2283, 'Ny??ribrony', '4535', 15),
(2284, 'Ny??rj??k??', '4541', 15),
(2285, 'Ny??rkar??sz', '4544', 15),
(2286, 'Ny??rk??ta', '4333', 15),
(2287, 'Ny??rk??rcs', '4537', 15),
(2288, 'Ny??rl??v??', '4632', 15),
(2289, 'Ny??rlugos', '4371', 15),
(2290, 'Ny??rmada', '4564', 15),
(2291, 'Ny??rm??rtonfalva', '4263', 8),
(2292, 'Ny??rmeggyes', '4722', 15),
(2293, 'Ny??rmih??lydi', '4363', 15),
(2294, 'Ny??rparasznya', '4822', 15),
(2295, 'Ny??rpazony', '4531', 15),
(2296, 'Ny??rpilis', '4376', 15),
(2297, 'Ny??rtass', '4522', 15),
(2298, 'Ny??rtelek', '4461', 15),
(2299, 'Ny??rt??t', '4554', 15),
(2300, 'Ny??rtura', '4532', 15),
(2301, 'Ny??rvasv??ri', '4341', 15),
(2302, 'Ny??g??r', '9682', 17),
(2303, 'Nyom??r', '3795', 4),
(2304, 'Nyugotszenterzs??bet', '7912', 2),
(2305, 'Ny??l', '9082', 7),
(2306, '??b??nya', '7695', 2),
(2307, '??barok', '2063', 6),
(2308, '??budav??r', '8272', 18),
(2309, '??cs', '8292', 18),
(2310, '??csa', '2364', 13),
(2311, '??cs??rd', '7814', 2),
(2312, '??cs??ny', '7143', 16),
(2313, '??cs??d', '5451', 10),
(2314, '??falu', '7695', 2),
(2315, '??feh??rt??', '4558', 15),
(2316, '??f??lde??k', '6923', 5),
(2317, '??hid', '8342', 19),
(2318, 'Ok??ny', '5534', 3),
(2319, 'Okor??g', '7957', 2),
(2320, '??k??rit??f??lp??s', '4755', 15),
(2321, 'Okorv??lgy', '7681', 2),
(2322, 'Olasz', '7745', 2),
(2323, 'Olaszfa', '9824', 17),
(2324, 'Olaszfalu', '8414', 18),
(2325, 'Olaszliszka', '3933', 4),
(2326, '??lb??', '9621', 17),
(2327, 'Olcsva', '4826', 15),
(2328, 'Olcsvaap??ti', '4914', 15),
(2329, 'Old', '7824', 2),
(2330, '??lmod', '9733', 17),
(2331, 'Olt??rc', '8886', 19),
(2332, '??mb??ly', '4373', 15),
(2333, 'Onga', '3562', 4),
(2334, '??nod', '3551', 4),
(2335, '??p??lyi', '4821', 15),
(2336, '??pusztaszer', '6767', 5),
(2337, '??r', '4336', 15),
(2338, 'Orb??nyosfa', '8935', 19),
(2339, '??rbotty??n', '2162', 13),
(2340, 'Orci', '7400', 14),
(2341, 'Ordacsehi', '8635', 14),
(2342, 'Ordas', '6335', 1),
(2343, '??regcsert??', '6311', 1),
(2344, '??reglak', '8697', 14),
(2345, 'Orfalu', '9982', 17),
(2346, 'Orf??', '7677', 2),
(2347, 'Orgov??ny', '6077', 1),
(2348, '??rhalom', '2671', 12),
(2349, '??rimagyar??sd', '9933', 17),
(2350, '??riszentp??ter', '9941', 17),
(2351, '??rk??ny', '2377', 13),
(2352, 'Orm??ndlak', '8983', 19),
(2353, '??rm??nyes', '5222', 10),
(2354, '??rm??nyk??t', '5556', 3),
(2355, 'Ormosb??nya', '3743', 4),
(2356, 'Orosh??za', '5900', 3),
(2357, 'Orosh??za', '5903', 3),
(2358, 'Orosh??za', '5904', 3),
(2359, 'Orosh??za', '5905', 3),
(2360, 'Oroszi', '8458', 18),
(2361, 'Oroszl??ny', '2840', 11),
(2362, 'Oroszl??', '7370', 2),
(2363, 'Orosztony', '8744', 19),
(2364, 'Ortah??za', '8954', 19),
(2365, '??rtilos', '8854', 14),
(2366, '??rv??nyes', '8242', 18),
(2367, '??sag??rd', '2610', 12),
(2368, '??si', '8161', 18),
(2369, '??sk??', '8191', 18),
(2370, 'Osli', '9354', 7),
(2371, 'Ostffyasszonyfa', '9512', 17),
(2372, 'Ostoros', '3326', 9),
(2373, 'Oszk??', '9825', 17),
(2374, 'Oszl??r', '3591', 4),
(2375, 'Osztop??n', '7444', 14),
(2376, '??ttev??ny', '9153', 7),
(2377, '??tt??m??s', '6784', 5),
(2378, '??tv??sk??nyi', '7511', 14),
(2379, '??zd', '3600', 4),
(2380, '??zd', '3603', 4),
(2381, '??zd', '3604', 4),
(2382, '??zd', '3621', 4),
(2383, '??zd', '3625', 4),
(2384, '??zd', '3651', 4),
(2385, '??zd', '3661', 4),
(2386, '??zd', '3662', 4),
(2387, '??zdfalu', '7836', 2),
(2388, 'Ozm??nb??k', '8998', 19),
(2389, 'Ozora', '7086', 16),
(2390, 'P??cin', '3964', 4),
(2391, 'Pacsa', '8761', 19),
(2392, 'P??csony', '9823', 17),
(2393, 'Pad??r', '8935', 19),
(2394, 'P??hi', '6075', 1),
(2395, 'P??ka', '8956', 19),
(2396, 'Pakod', '8799', 19),
(2397, 'P??kozd', '8095', 6),
(2398, 'Paks', '7027', 16),
(2399, 'Paks', '7030', 16),
(2400, 'Pal??', '7370', 2),
(2401, 'P??lfa', '7042', 16),
(2402, 'P??lfiszeg', '8990', 19),
(2403, 'P??lh??za', '3994', 4),
(2404, 'P??li', '9345', 7),
(2405, 'Palkonya', '7771', 2),
(2406, 'P??lmajor', '7561', 14),
(2407, 'P??lmonostora', '6112', 1),
(2408, 'Palotabozsok', '7727', 2),
(2409, 'Palot??s', '3042', 12),
(2410, 'Paloznak', '8229', 18),
(2411, 'Paml??ny', '3821', 4),
(2412, 'Pamuk', '8698', 14),
(2413, 'P??nd', '2214', 13),
(2414, 'Pankasz', '9937', 17),
(2415, 'Pannonhalma', '9090', 7),
(2416, 'P??nyok', '3898', 4),
(2417, 'Panyola', '4913', 15),
(2418, 'Pap', '4631', 15),
(2419, 'P??pa', '8500', 18),
(2420, 'P??pa', '8511', 18),
(2421, 'P??pa', '8591', 18),
(2422, 'P??pa', '8598', 18),
(2423, 'P??padereske', '8593', 18),
(2424, 'P??pakov??csi', '8596', 18),
(2425, 'P??pasalamon', '8594', 18),
(2426, 'P??patesz??r', '8556', 18),
(2427, 'Papkeszi', '8183', 18),
(2428, 'P??poc', '9515', 17),
(2429, 'Papos', '4338', 15),
(2430, 'P??pr??d', '7838', 2),
(2431, 'Par??d', '3240', 9),
(2432, 'Par??d', '3244', 9),
(2433, 'Par??dsasv??r', '3242', 9),
(2434, 'Parasznya', '3777', 4),
(2435, 'Paszab', '4475', 15),
(2436, 'P??szt??', '3060', 12),
(2437, 'P??szt??', '3065', 12),
(2438, 'P??szt??', '3082', 12),
(2439, 'P??sztori', '9311', 7),
(2440, 'Pat', '8825', 19),
(2441, 'Patak', '2648', 12),
(2442, 'Patalom', '7463', 14),
(2443, 'Patapoklosi', '7923', 2),
(2444, 'Patca', '7477', 14),
(2445, 'P??tka', '8092', 6),
(2446, 'Patosfa', '7536', 14),
(2447, 'P??troha', '4523', 15),
(2448, 'Patvarc', '2668', 12),
(2449, 'P??ty', '2071', 13),
(2450, 'P??tyod', '4766', 15),
(2451, 'P??zm??nd', '2476', 6),
(2452, 'P??zm??ndfalu', '9085', 7),
(2453, 'P??cel', '2119', 13),
(2454, 'Pec??l', '9754', 17),
(2455, 'P??cs', '7600', 2),
(2456, 'P??cs', '7621', 2),
(2457, 'P??cs', '7622', 2),
(2458, 'P??cs', '7623', 2),
(2459, 'P??cs', '7624', 2),
(2460, 'P??cs', '7625', 2),
(2461, 'P??cs', '7626', 2),
(2462, 'P??cs', '7627', 2),
(2463, 'P??cs', '7628', 2),
(2464, 'P??cs', '7629', 2),
(2465, 'P??cs', '7630', 2),
(2466, 'P??cs', '7631', 2),
(2467, 'P??cs', '7632', 2),
(2468, 'P??cs', '7633', 2),
(2469, 'P??cs', '7634', 2),
(2470, 'P??cs', '7635', 2),
(2471, 'P??cs', '7636', 2),
(2472, 'P??cs', '7691', 2),
(2473, 'P??cs', '7693', 2),
(2474, 'P??csbagota', '7951', 2),
(2475, 'P??csdevecser', '7766', 2),
(2476, 'P??csely', '8245', 18),
(2477, 'P??csudvard', '7762', 2),
(2478, 'P??csv??rad', '7720', 2),
(2479, 'Pell??rd', '7831', 2),
(2480, 'P??ly', '3381', 9),
(2481, 'Penc', '2614', 13),
(2482, 'Pen??szlek', '4267', 15),
(2483, 'Penyige', '4941', 15),
(2484, 'P??nzesgy??r', '8426', 18),
(2485, 'P??r', '9099', 7),
(2486, 'Perb??l', '2074', 13),
(2487, 'Pere', '3853', 4),
(2488, 'Perecse', '3821', 4),
(2489, 'Pereked', '7664', 2),
(2490, 'Perenye', '9722', 17),
(2491, 'Peresznye', '9734', 17),
(2492, 'Pereszteg', '9484', 7),
(2493, 'Perk??ta', '2431', 6),
(2494, 'Perkupa', '3756', 4),
(2495, 'Per??cs??ny', '2637', 13),
(2496, 'Peterd', '7766', 2),
(2497, 'P??terhida', '7582', 14),
(2498, 'P??teri', '2209', 13),
(2499, 'P??terv??s??ra', '3250', 9),
(2500, 'P??tf??rd??', '8105', 18),
(2501, 'Peth??henye', '8921', 19),
(2502, 'Petneh??za', '4542', 15),
(2503, 'Pet??fib??nya', '3023', 9),
(2504, 'Pet??fisz??ll??s', '6113', 1),
(2505, 'Pet??h??za', '9443', 7),
(2506, 'Pet??mih??lyfa', '9826', 17),
(2507, 'Petrikereszt??r', '8984', 19),
(2508, 'Petrivente', '8866', 19),
(2509, 'Pettend', '7980', 2),
(2510, 'Piliny', '3134', 12),
(2511, 'Pilis', '2721', 13),
(2512, 'Pilisborosjen??', '2097', 13),
(2513, 'Piliscsaba', '2081', 13),
(2514, 'Piliscsaba', '2087', 13),
(2515, 'Piliscs??v', '2519', 11),
(2516, 'Pilisj??szfalu', '2080', 13),
(2517, 'Pilismar??t', '2028', 11),
(2518, 'Pilissz??nt??', '2095', 13),
(2519, 'Pilisszentiv??n', '2084', 13),
(2520, 'Pilisszentkereszt', '2098', 13),
(2521, 'Pilisszentkereszt', '2099', 13),
(2522, 'Pilisszentl??szl??', '2009', 13),
(2523, 'Pilisv??r??sv??r', '2085', 13),
(2524, 'Pincehely', '7084', 16),
(2525, 'Pinkamindszent', '9922', 17),
(2526, 'Pinnye', '9481', 7),
(2527, 'Piricse', '4375', 15),
(2528, 'Pirt??', '6414', 1),
(2529, 'Pisk??', '7838', 2),
(2530, 'Pitvaros', '6914', 5),
(2531, 'P??csa', '7756', 2),
(2532, 'Pocsaj', '4125', 8),
(2533, 'P??csmegyer', '2017', 13),
(2534, 'P??cspetri', '4327', 15),
(2535, 'Pog??ny', '7666', 2),
(2536, 'Pog??nyszentp??ter', '8728', 14),
(2537, 'P??kaszepetk', '8932', 19),
(2538, 'Pol??ny', '7458', 14),
(2539, 'Polg??r', '4090', 8),
(2540, 'Polg??rdi', '8153', 6),
(2541, 'Polg??rdi', '8154', 6),
(2542, 'Polg??rdi', '8155', 6),
(2543, 'P??l??ske', '8929', 19),
(2544, 'P??l??skef??', '8773', 19),
(2545, 'Pom??z', '2013', 13),
(2546, 'P??rb??ly', '7142', 16),
(2547, 'Porcsalma', '4761', 15),
(2548, 'P??rdef??lde', '8956', 19),
(2549, 'Porn??ap??ti', '9796', 17),
(2550, 'Poroszl??', '3388', 9),
(2551, 'Porp??c', '9612', 17),
(2552, 'Porrog', '8858', 14),
(2553, 'Porrogszentkir??ly', '8858', 14),
(2554, 'Porrogszentp??l', '8858', 14),
(2555, 'P??rszombat', '8986', 19),
(2556, 'Porva', '8429', 18),
(2557, 'P??sfa', '9636', 17),
(2558, 'Potony', '7977', 14),
(2559, 'P??tr??te', '8767', 19),
(2560, 'Potyond', '9324', 7),
(2561, 'Pr??gy', '3925', 4),
(2562, 'Pula', '8291', 18),
(2563, 'P??ski', '9235', 7),
(2564, 'P??sp??khatvan', '2682', 13),
(2565, 'P??sp??klad??ny', '4150', 8),
(2566, 'P??sp??kmoln??ri', '9776', 17),
(2567, 'P??sp??kszil??gy', '2166', 13),
(2568, 'Pusztaap??ti', '8986', 19),
(2569, 'Pusztaberki', '2658', 12),
(2570, 'Pusztacsal??d', '9373', 7),
(2571, 'Pusztacs??', '9739', 17),
(2572, 'Pusztadobos', '4565', 15),
(2573, 'Pusztaederics', '8946', 19),
(2574, 'Pusztafalu', '3995', 4),
(2575, 'Pusztaf??ldv??r', '5919', 3),
(2576, 'Pusztahencse', '7038', 16),
(2577, 'Pusztakov??csi', '8707', 14),
(2578, 'Pusztamagyar??d', '8895', 19),
(2579, 'Pusztam??rges', '6785', 5),
(2580, 'Pusztamiske', '8455', 18),
(2581, 'Pusztamonostor', '5125', 10),
(2582, 'Pusztaottlaka', '5665', 3),
(2583, 'Pusztaradv??ny', '3874', 4),
(2584, 'Pusztaszabolcs', '2490', 6),
(2585, 'Pusztaszemes', '8619', 14),
(2586, 'Pusztaszentl??szl??', '8896', 19),
(2587, 'Pusztaszer', '6769', 5),
(2588, 'Pusztavacs', '2378', 13),
(2589, 'Pusztav??m', '8066', 6),
(2590, 'Pusztaz??mor', '2039', 13),
(2591, 'Putnok', '3630', 4),
(2592, 'R??bacsanak', '9313', 7),
(2593, 'R??bacs??cs??ny', '9136', 7),
(2594, 'R??bagyarmat', '9961', 17),
(2595, 'R??bahidv??g', '9777', 17),
(2596, 'R??bakec??l', '9344', 7),
(2597, 'R??bapatona', '9142', 7),
(2598, 'R??bapaty', '9641', 17),
(2599, 'R??bapord??ny', '9146', 7),
(2600, 'R??basebes', '9327', 7),
(2601, 'R??baszentandr??s', '9316', 7),
(2602, 'R??baszentmih??ly', '9135', 7),
(2603, 'R??baszentmikl??s', '9133', 7),
(2604, 'R??batam??si', '9322', 7),
(2605, 'R??bat??tt??s', '9766', 17),
(2606, 'R??bcakapi', '9165', 7),
(2607, 'R??calm??s', '2459', 6),
(2608, 'R??ckereszt??r', '2465', 6),
(2609, 'R??ckeve', '2300', 13),
(2610, 'R??d', '2613', 13),
(2611, 'R??dfalva', '7817', 2),
(2612, 'R??d??ck??lked', '9784', 17),
(2613, 'Radosty??n', '3776', 4),
(2614, 'Rag??ly', '3724', 4),
(2615, 'Rajka', '9224', 7),
(2616, 'Rakaca', '3825', 4),
(2617, 'Rakacaszend', '3826', 4),
(2618, 'Rakamaz', '4465', 15),
(2619, 'R??k??czib??nya', '3151', 12),
(2620, 'R??k??czifalva', '5085', 10),
(2621, 'R??k??czi??jfalu', '5084', 10),
(2622, 'R??ksi', '7464', 14),
(2623, 'Ramocsa', '8973', 19),
(2624, 'Ramocsah??za', '4536', 15),
(2625, 'R??polt', '4756', 15),
(2626, 'Raposka', '8300', 18),
(2627, 'R??sonys??pberencs', '3833', 4),
(2628, 'R??tka', '3908', 4),
(2629, 'R??t??t', '9951', 17),
(2630, 'Ravazd', '9091', 7),
(2631, 'Recsk', '3245', 9),
(2632, 'R??de', '2886', 11),
(2633, 'R??dics', '8978', 19),
(2634, 'Reg??c', '3893', 4),
(2635, 'Regenye', '7833', 2),
(2636, 'Reg??ly', '7193', 16),
(2637, 'R??m', '6446', 1),
(2638, 'Remetesz??l??s', '2090', 13),
(2639, 'R??p??shuta', '3559', 4),
(2640, 'R??pcelak', '9653', 17),
(2641, 'R??pceszemere', '9375', 7),
(2642, 'R??pceszentgy??rgy', '9623', 17),
(2643, 'R??pcevis', '9475', 7),
(2644, 'Resznek', '8977', 19),
(2645, 'R??talap', '9074', 7),
(2646, 'R??tk??zberencs', '4525', 15),
(2647, 'R??ts??g', '2651', 12),
(2648, 'R??vf??l??p', '8253', 18),
(2649, 'R??vle??nyv??r', '3976', 4),
(2650, 'Rezi', '8373', 19),
(2651, 'Ricse', '3974', 4),
(2652, 'Rig??cs', '8348', 18),
(2653, 'Rigy??c', '8883', 19),
(2654, 'Rim??c', '3177', 12),
(2655, 'Rinyabeseny??', '7552', 14),
(2656, 'Rinyakov??csi', '7527', 14),
(2657, 'Rinyaszentkir??ly', '7513', 14),
(2658, 'Rinya??jlak', '7556', 14),
(2659, 'Rinya??jn??p', '7584', 14),
(2660, 'Rohod', '4563', 15),
(2661, 'R??jt??kmuzsaj', '9451', 7),
(2662, 'Rom??nd', '8434', 7),
(2663, 'Romh??ny', '2654', 12),
(2664, 'Romonya', '7743', 2),
(2665, 'R??n??k', '9954', 17),
(2666, 'R??szke', '6758', 5),
(2667, 'R??zsafa', '7914', 2),
(2668, 'Rozs??ly', '4971', 15),
(2669, 'R??zsaszentm??rton', '3033', 9),
(2670, 'Rudab??nya', '3733', 4),
(2671, 'Rudolftelep', '3742', 4),
(2672, 'Rum', '9766', 17),
(2673, 'Ruzsa', '6786', 5),
(2674, 'S??g??jfalu', '3162', 12),
(2675, 'S??gv??r', '8654', 14),
(2676, 'Saj??b??bony', '3792', 4),
(2677, 'Saj??ecseg', '3793', 4),
(2678, 'Saj??galg??c', '3636', 4),
(2679, 'Saj??hidv??g', '3576', 4),
(2680, 'Saj??iv??nka', '3720', 4),
(2681, 'Saj??k??polna', '3773', 4),
(2682, 'Saj??kaza', '3720', 4),
(2683, 'Saj??kereszt??r', '3791', 4),
(2684, 'Saj??l??d', '3572', 4),
(2685, 'Saj??l??szl??falva', '3773', 4),
(2686, 'Saj??mercse', '3656', 4),
(2687, 'Saj??n??meti', '3652', 4),
(2688, 'Saj????r??s', '3586', 4),
(2689, 'Saj??p??lfala', '3714', 4),
(2690, 'Saj??petri', '3573', 4),
(2691, 'Saj??p??sp??ki', '3653', 4),
(2692, 'Saj??senye', '3712', 4),
(2693, 'Saj??szentp??ter', '3770', 4),
(2694, 'Saj??sz??ged', '3599', 4),
(2695, 'Saj??v??mos', '3712', 4),
(2696, 'Saj??velezd', '3656', 4),
(2697, 'Sajtosk??l', '9632', 17),
(2698, 'Salf??ld', '8256', 18),
(2699, 'Salg??tarj??n', '3100', 12),
(2700, 'Salg??tarj??n', '3102', 12),
(2701, 'Salg??tarj??n', '3104', 12),
(2702, 'Salg??tarj??n', '3109', 12),
(2703, 'Salg??tarj??n', '3121', 12),
(2704, 'Salg??tarj??n', '3141', 12),
(2705, 'Salk??vesk??t', '9742', 17),
(2706, 'Salomv??r', '8995', 19),
(2707, 'S??ly', '3425', 4),
(2708, 'S??mod', '7841', 2),
(2709, 'S??msonh??za', '3074', 12),
(2710, 'Sand', '8824', 19),
(2711, 'S??ndorfalva', '6762', 5),
(2712, 'S??ntos', '7479', 14),
(2713, 'S??p', '4176', 8),
(2714, 'S??r??nd', '4272', 8),
(2715, 'S??razsad??ny', '3942', 4),
(2716, 'S??rbog??rd', '7000', 6),
(2717, 'S??rbog??rd', '7003', 6),
(2718, 'S??rbog??rd', '7018', 6),
(2719, 'S??rbog??rd', '7019', 6),
(2720, 'S??regres', '7014', 6),
(2721, 'S??rfimizd??', '9813', 17),
(2722, 'S??rhida', '8944', 19),
(2723, 'S??ris??p', '2523', 11),
(2724, 'Sarkad', '5720', 3),
(2725, 'Sarkadkereszt??r', '5731', 3),
(2726, 'S??rkeresztes', '8051', 6),
(2727, 'S??rkereszt??r', '8125', 6),
(2728, 'S??rkeszi', '8144', 6),
(2729, 'S??rmell??k', '8391', 19),
(2730, 'S??rok', '7781', 2),
(2731, 'S??rosd', '2433', 6),
(2732, 'S??rospatak', '3950', 4),
(2733, 'S??rospatak', '3952', 4),
(2734, 'S??rpilis', '7145', 16),
(2735, 'S??rr??tudvari', '4171', 8),
(2736, 'Sarr??d', '9434', 7),
(2737, 'Sarr??d', '9435', 7),
(2738, 'S??rszent??gota', '8126', 6),
(2739, 'S??rszentl??rinc', '7047', 16),
(2740, 'S??rszentmih??ly', '8141', 6),
(2741, 'S??rszentmih??ly', '8143', 6),
(2742, 'Sarud', '3386', 9),
(2743, 'S??rv??r', '9600', 17),
(2744, 'S??rv??r', '9608', 17),
(2745, 'S??rv??r', '9609', 17),
(2746, 'S??sd', '7370', 2),
(2747, 'S??ska', '8308', 18),
(2748, 'S??ta', '3659', 4),
(2749, 'S??toralja??jhely', '3944', 4),
(2750, 'S??toralja??jhely', '3945', 4),
(2751, 'S??toralja??jhely', '3980', 4),
(2752, 'S??toralja??jhely', '3988', 4),
(2753, 'S??torhely', '7785', 2),
(2754, 'S??voly', '8732', 14),
(2755, 'S??', '9789', 17),
(2756, 'Segesd', '7562', 14),
(2757, 'Sellye', '7960', 2),
(2758, 'Selyeb', '3809', 4),
(2759, 'Semj??n', '3974', 4),
(2760, 'Semj??nh??za', '8862', 19),
(2761, 'S??nye', '8788', 19),
(2762, 'S??ny??', '4533', 15),
(2763, 'Sereg??lyes', '8111', 6),
(2764, 'Ser??nyfalva', '3729', 4),
(2765, 'S??rseksz??l??s', '8660', 14),
(2766, 'Sik??tor', '8439', 7),
(2767, 'Sikl??s', '7800', 2),
(2768, 'Sikl??s', '7818', 2),
(2769, 'Sikl??sbodony', '7814', 2),
(2770, 'Sikl??snagyfalu', '7823', 2),
(2771, 'Sima', '3881', 4),
(2772, 'Simas??g', '9633', 17),
(2773, 'Simonfa', '7474', 14),
(2774, 'Simontornya', '7081', 16),
(2775, 'Si??ag??rd', '7171', 16),
(2776, 'Si??fok', '8600', 14),
(2777, 'Si??fok', '8609', 14),
(2778, 'Si??fok', '8611', 14),
(2779, 'Si??jut', '8652', 14),
(2780, 'Sirok', '3332', 9),
(2781, 'Sitke', '9671', 17),
(2782, 'Sobor', '9315', 7),
(2783, 'S??jt??r', '8897', 19),
(2784, 'Sokor??p??tka', '9112', 7),
(2785, 'Solt', '6320', 1),
(2786, 'Soltszentimre', '6223', 1),
(2787, 'Soltvadkert', '6230', 1),
(2788, 'S??ly', '8193', 18),
(2789, 'Solym??r', '2083', 13),
(2790, 'Som', '8655', 14),
(2791, 'Somberek', '7728', 2),
(2792, 'Soml??jen??', '8478', 18),
(2793, 'Soml??sz??l??s', '8483', 18),
(2794, 'Soml??v??s??rhely', '8481', 18),
(2795, 'Soml??vecse', '8484', 18),
(2796, 'Somodor', '7454', 14),
(2797, 'Somogyacsa', '7283', 14),
(2798, 'Somogyap??ti', '7922', 2),
(2799, 'Somogyaracs', '7584', 14),
(2800, 'Somogyaszal??', '7452', 14),
(2801, 'Somogybabod', '8684', 14),
(2802, 'Somogyb??kk??sd', '8858', 14),
(2803, 'Somogycsics??', '8726', 14),
(2804, 'Somogyd??r??cske', '7284', 14),
(2805, 'Somogyegres', '8666', 14),
(2806, 'Somogyfajsz', '8708', 14),
(2807, 'Somogygeszti', '7455', 14),
(2808, 'Somogyh??rs??gy', '7925', 2),
(2809, 'Somogyhatvan', '7921', 2),
(2810, 'Somogyj??d', '7443', 14),
(2811, 'Somogymeggyes', '8673', 14),
(2812, 'Somogys??mson', '8733', 14),
(2813, 'Somogys??rd', '7435', 14),
(2814, 'Somogysimonyi', '8737', 14),
(2815, 'Somogyszentp??l', '8705', 14),
(2816, 'Somogyszil', '7276', 14),
(2817, 'Somogyszob', '7563', 14),
(2818, 'Somogyt??r', '8683', 14),
(2819, 'Somogyudvarhely', '7515', 14),
(2820, 'Somogyv??mos', '8699', 14),
(2821, 'Somogyv??r', '8698', 14),
(2822, 'Somogyviszl??', '7924', 2),
(2823, 'Somogyzsitfa', '8734', 14),
(2824, 'Sonk??d', '4954', 15),
(2825, 'Soponya', '8123', 6),
(2826, 'Sopron', '9400', 7),
(2827, 'Sopron', '9407', 7),
(2828, 'Sopron', '9408', 7),
(2829, 'Sopron', '9494', 7),
(2830, 'Sopronhorp??cs', '9463', 7),
(2831, 'Sopronk??vesd', '9483', 7),
(2832, 'Sopronn??meti', '9325', 7),
(2833, 'S??pte', '9743', 17),
(2834, 'S??r??d', '8072', 6),
(2835, 'Sorkifalud', '9774', 17),
(2836, 'Sorkik??polna', '9774', 17),
(2837, 'Sorm??s', '8881', 19),
(2838, 'Sorokpol??ny', '9773', 17),
(2839, 'S??sharty??n', '3131', 12),
(2840, 'S??sk??t', '2038', 13),
(2841, 'S??st??falva', '3716', 4),
(2842, 'S??svertike', '7960', 2),
(2843, 'S??tony', '9681', 17),
(2844, 'Sukor??', '8096', 6),
(2845, 'S??k??sd', '6346', 1),
(2846, 'S??lys??p', '2241', 13),
(2847, 'S??lys??p', '2242', 13),
(2848, 'S??meg', '8330', 18),
(2849, 'S??megcsehi', '8357', 19),
(2850, 'S??megpr??ga', '8351', 18),
(2851, 'Sumony', '7960', 2),
(2852, 'S??r', '2889', 11),
(2853, 'Surd', '8856', 19),
(2854, 'S??tt??', '2543', 11),
(2855, 'Szabadbatty??n', '8151', 6),
(2856, 'Szabadegyh??za', '2432', 6),
(2857, 'Szabadhidv??g', '8138', 6),
(2858, 'Szabadhidv??g', '8139', 6),
(2859, 'Szabadi', '7253', 14),
(2860, 'Szabadk??gy??s', '5712', 3),
(2861, 'Szabadsz??ll??s', '6080', 1),
(2862, 'Szabadszentkir??ly', '7951', 2),
(2863, 'Szab??s', '7544', 14),
(2864, 'Szabolcs', '4467', 15),
(2865, 'Szabolcsb??ka', '4547', 15),
(2866, 'Szabolcsveresmart', '4496', 15),
(2867, 'Szada', '2111', 13),
(2868, 'Sz??gy', '7383', 2),
(2869, 'Szajk', '7753', 2),
(2870, 'Szajla', '3334', 9),
(2871, 'Szajol', '5081', 10),
(2872, 'Szak??csi', '3786', 4),
(2873, 'Szakad??t', '7071', 16),
(2874, 'Szak??ld', '3596', 4),
(2875, 'Szak??ly', '7192', 16),
(2876, 'Szakcs', '7213', 16),
(2877, 'Szakm??r', '6336', 1),
(2878, 'Szakny??r', '9934', 17),
(2879, 'Szakoly', '4234', 15),
(2880, 'Szakony', '9474', 7),
(2881, 'Szakonyfalu', '9983', 17),
(2882, 'Sz??kszend', '2856', 11),
(2883, 'Szalaf??', '9942', 17),
(2884, 'Szal??nta', '7811', 2),
(2885, 'Szalapa', '8341', 19),
(2886, 'Szalaszend', '3863', 4),
(2887, 'Szalatnak', '7334', 2),
(2888, 'Sz??lka', '7121', 16),
(2889, 'Szalkszentm??rton', '6086', 1),
(2890, 'Szalmatercs', '3163', 12),
(2891, 'Szalonna', '3754', 4),
(2892, 'Szamosangyalos', '4767', 15),
(2893, 'Szamosbecs', '4745', 15),
(2894, 'Szamosk??r', '4721', 15),
(2895, 'Szamoss??lyi', '4735', 15),
(2896, 'Szamosszeg', '4824', 15),
(2897, 'Szamostat??rfalva', '4746', 15),
(2898, 'Szamos??jlak', '4734', 15),
(2899, 'Szanda', '2697', 12),
(2900, 'Szank', '6131', 1),
(2901, 'Sz??nt??d', '8622', 14),
(2902, 'Szany', '9317', 7),
(2903, 'Sz??p??r', '8423', 18),
(2904, 'Szaporca', '7843', 2),
(2905, 'Sz??r', '2066', 6),
(2906, 'Sz??r??sz', '7184', 2),
(2907, 'Sz??razd', '7063', 16),
(2908, 'Sz??rf??ld', '9353', 7),
(2909, 'Sz??rliget', '2067', 11),
(2910, 'Szarvas', '5540', 3),
(2911, 'Szarvasgede', '3051', 12),
(2912, 'Szarvaskend', '9913', 17),
(2913, 'Szarvask??', '3323', 9),
(2914, 'Sz??szberek', '5053', 10),
(2915, 'Sz??szfa', '3821', 4),
(2916, 'Sz??szv??r', '7349', 2),
(2917, 'Szatm??rcseke', '4945', 15),
(2918, 'Sz??tok', '2656', 12),
(2919, 'Szatta', '9938', 17),
(2920, 'Szatymaz', '6763', 5),
(2921, 'Szava', '7813', 2),
(2922, 'Sz??zhalombatta', '2440', 13),
(2923, 'Szeb??ny', '7725', 2),
(2924, 'Sz??cs??nke', '2692', 12),
(2925, 'Sz??cs??ny', '3170', 12),
(2926, 'Sz??cs??nyfelfalu', '3135', 12),
(2927, 'Sz??csisziget', '8879', 19),
(2928, 'Szederk??ny', '7751', 2),
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
(2946, 'Szegerd??', '8732', 14),
(2947, 'Szeghalom', '5520', 3),
(2948, 'Szegi', '3918', 4),
(2949, 'Szegilong', '3918', 4),
(2950, 'Szegv??r', '6635', 5),
(2951, 'Sz??kely', '4534', 15),
(2952, 'Sz??kelyszabar', '7737', 2),
(2953, 'Sz??kesfeh??rv??r', '8000', 6),
(2954, 'Sz??kesfeh??rv??r', '8019', 6),
(2955, 'Sz??kkutas', '6821', 5),
(2956, 'Szeksz??rd', '7100', 16),
(2957, 'Szeleste', '9622', 17),
(2958, 'Szelev??ny', '5476', 10),
(2959, 'Szell??', '7661', 2),
(2960, 'Szemely', '7763', 2),
(2961, 'Szemenye', '9685', 17),
(2962, 'Szemere', '3866', 4),
(2963, 'Szendehely', '2640', 12),
(2964, 'Szendr??', '3752', 4),
(2965, 'Szendr??l??d', '3751', 4),
(2966, 'Szenna', '7477', 14),
(2967, 'Szenta', '8849', 14),
(2968, 'Szentantalfa', '8272', 18),
(2969, 'Szentbal??zs', '7472', 14),
(2970, 'Szentb??kk??lla', '8281', 18),
(2971, 'Szentborb??s', '7918', 14),
(2972, 'Szentd??nes', '7913', 2),
(2973, 'Szentdomonkos', '3259', 9),
(2974, 'Szente', '2655', 12),
(2975, 'Szenteg??t', '7915', 2),
(2976, 'Szentendre', '2000', 13),
(2977, 'Szentes', '6600', 5),
(2978, 'Szentg??l', '8444', 18),
(2979, 'Szentg??losk??r', '7465', 14),
(2980, 'Szentgotth??rd', '9955', 17),
(2981, 'Szentgotth??rd', '9970', 17),
(2982, 'Szentgotth??rd', '9981', 17),
(2983, 'Szentgy??rgyv??r', '8393', 19),
(2984, 'Szentgy??rgyv??lgy', '8975', 19),
(2985, 'Szentimrefalva', '8475', 18),
(2986, 'Szentistv??n', '3418', 4),
(2987, 'Szentistv??nbaksa', '3844', 4),
(2988, 'Szentjakabfa', '8272', 18),
(2989, 'Szentkatalin', '7681', 2),
(2990, 'Szentkir??ly', '6031', 1),
(2991, 'Szentkir??lyszabadja', '8225', 18),
(2992, 'Szentkozmadombja', '8947', 19),
(2993, 'Szentl??szl??', '7936', 2),
(2994, 'Szentliszl??', '8893', 19),
(2995, 'Szentl??rinc', '7940', 2),
(2996, 'Szentl??rinck??ta', '2255', 13),
(2997, 'Szentmargitfalva', '8872', 19),
(2998, 'Szentm??rtonk??ta', '2254', 13),
(2999, 'Szentp??terfa', '9799', 17),
(3000, 'Szentp??terf??lde', '8953', 19),
(3001, 'Szentp??terszeg', '4121', 8),
(3002, 'Szentp??ter??r', '8762', 19),
(3003, 'Szeny??r', '8717', 14),
(3004, 'Szepetnek', '8861', 19),
(3005, 'Szerecseny', '9125', 7),
(3006, 'Szeremle', '6512', 1),
(3007, 'Szerencs', '3900', 4),
(3008, 'Szerep', '4162', 8),
(3009, 'Szerep', '4163', 8),
(3010, 'Szerg??ny', '9523', 17),
(3011, 'Szigetbecse', '2321', 13),
(3012, 'Szigetcs??p', '2317', 13),
(3013, 'Szigethalom', '2315', 13),
(3014, 'Szigetmonostor', '2015', 13),
(3015, 'Szigetszentm??rton', '2318', 13),
(3016, 'Szigetszentmikl??s', '2310', 13),
(3017, 'Sziget??jfalu', '2319', 13),
(3018, 'Szigetv??r', '7900', 2),
(3019, 'Szigliget', '8264', 18),
(3020, 'Szihalom', '3377', 9),
(3021, 'Szij??rt??h??za', '8969', 19),
(3022, 'Sziksz??', '3800', 4),
(3023, 'Szil', '9326', 7),
(3024, 'Szil??gy', '7664', 2),
(3025, 'Szilaspogony', '3125', 12),
(3026, 'Szils??rk??ny', '9312', 7),
(3027, 'Szilv??gy', '8986', 19),
(3028, 'Szilv??s', '7811', 2),
(3029, 'Szilv??sszentm??rton', '7477', 14),
(3030, 'Szilv??sv??rad', '3348', 9),
(3031, 'Szin', '3761', 4),
(3032, 'Szinpetri', '3761', 4),
(3033, 'Szir??k', '3044', 12),
(3034, 'Szirmabeseny??', '3711', 4),
(3035, 'Szob', '2628', 13),
(3036, 'Sz??c', '8452', 18),
(3037, 'Sz??ce', '9935', 17),
(3038, 'Sz??d', '2134', 13),
(3039, 'Sz??dliget', '2133', 13),
(3040, 'Sz??gliget', '3762', 4),
(3041, 'Sz??ke', '7833', 2),
(3042, 'Sz??k??d', '7763', 2),
(3043, 'Sz??kedencs', '8736', 14),
(3044, 'Szokolya', '2624', 13),
(3045, 'Sz??l??d', '8625', 14),
(3046, 'Szolnok', '5000', 10),
(3047, 'Szolnok', '5008', 10),
(3048, 'Sz??l??sard??', '3757', 4),
(3049, 'Sz??l??sgy??r??k', '8692', 14),
(3050, 'Szombathely', '9700', 17),
(3051, 'Szombathely', '9707', 17),
(3052, 'Szombathely', '9719', 17),
(3053, 'Szom??d', '2896', 11),
(3054, 'Szomolya', '3411', 4),
(3055, 'Szomor', '2822', 11),
(3056, 'Sz??r??ny', '7976', 2),
(3057, 'Szorgalmatos', '4441', 15),
(3058, 'Szorosad', '7285', 14),
(3059, 'Sz??cs', '3341', 9),
(3060, 'Sz??csi', '3034', 9),
(3061, 'Sz??gy', '2699', 12),
(3062, 'Szuha', '3154', 12),
(3063, 'Szuhaf??', '3726', 4),
(3064, 'Szuhak??ll??', '3731', 4),
(3065, 'Szuhogy', '3734', 4),
(3066, 'Szulim??n', '7932', 2),
(3067, 'Szulok', '7539', 14),
(3068, 'Sz??r', '7735', 2),
(3069, 'Szurdokp??sp??ki', '3064', 12),
(3070, 'Tab', '8660', 14),
(3071, 'Tabajd', '8088', 6),
(3072, 'Tabdi', '6224', 1),
(3073, 'T??borfalva', '2381', 13),
(3074, 'T??c', '8121', 6),
(3075, 'Tagyon', '8272', 18),
(3076, 'Tahit??tfalu', '2021', 13),
(3077, 'Tahit??tfalu', '2022', 13),
(3078, 'Tak??csi', '8541', 18),
(3079, 'T??kos', '4845', 15),
(3080, 'Taksony', '2335', 13),
(3081, 'Taktab??j', '3926', 4),
(3082, 'Taktahark??ny', '3922', 4),
(3083, 'Taktaken??z', '3924', 4),
(3084, 'Taktaszada', '3921', 4),
(3085, 'Tali??nd??r??gd', '8295', 18),
(3086, 'T??llya', '3907', 4),
(3087, 'Tam??si', '7090', 16),
(3088, 'Tam??si', '7091', 16),
(3089, 'Tanakajd', '9762', 17),
(3090, 'T??p', '9095', 7),
(3091, 'T??pi??bicske', '2764', 13),
(3092, 'T??pi??gy??rgye', '2767', 13),
(3093, 'T??pi??s??g', '2253', 13),
(3094, 'T??pi??szecs??', '2251', 13),
(3095, 'T??pi??szele', '2766', 13),
(3096, 'T??pi??szentm??rton', '2711', 13),
(3097, 'T??pi??sz??l??s', '2769', 13),
(3098, 'T??pl??nszentkereszt', '9761', 17),
(3099, 'Tapolca', '8297', 18),
(3100, 'Tapolca', '8300', 18),
(3101, 'Tapsony', '8718', 14),
(3102, 'T??pszentmikl??s', '9094', 7),
(3103, 'Tar', '3073', 12),
(3104, 'Tarany', '7514', 14),
(3105, 'Tarcal', '3915', 4),
(3106, 'Tard', '3416', 4),
(3107, 'Tardona', '3644', 4),
(3108, 'Tardos', '2834', 11),
(3109, 'Tarhos', '5641', 3),
(3110, 'Tarj??n', '2831', 11),
(3111, 'Tarj??npuszta', '9092', 7),
(3112, 'T??rk??ny', '2945', 11),
(3113, 'Tarnabod', '3369', 9),
(3114, 'Tarnalelesz', '3258', 9),
(3115, 'Tarnam??ra', '3284', 9),
(3116, 'Tarna??rs', '3294', 9),
(3117, 'Tarnaszentm??ria', '3331', 9),
(3118, 'Tarnaszentmikl??s', '3382', 9),
(3119, 'Tarnazsad??ny', '3283', 9),
(3120, 'T??rnok', '2461', 13),
(3121, 'T??rnokr??ti', '9165', 7),
(3122, 'Tarpa', '4931', 15),
(3123, 'Tarr??s', '7362', 2),
(3124, 'T??ska', '8696', 14),
(3125, 'Tass', '6098', 1),
(3126, 'Tasz??r', '7261', 14),
(3127, 'T??t', '2534', 11),
(3128, 'Tata', '2835', 11),
(3129, 'Tata', '2890', 11),
(3130, 'Tatab??nya', '2800', 11),
(3131, 'Tatah??za', '6451', 1),
(3132, 'Tat??rszentgy??rgy', '2375', 13),
(3133, 'T??zl??r', '6236', 1),
(3134, 'T??gl??s', '4243', 8),
(3135, 'T??kes', '7381', 2),
(3136, 'Teklafalu', '7973', 2),
(3137, 'Telekes', '9812', 17),
(3138, 'Telekgerend??s', '5675', 3),
(3139, 'Teleki', '8626', 14),
(3140, 'Telki', '2089', 13),
(3141, 'Telkib??nya', '3896', 4),
(3142, 'Tengelic', '7054', 16),
(3143, 'Tengeri', '7834', 2),
(3144, 'Teng??d', '8668', 14),
(3145, 'Tenk', '3359', 9),
(3146, 'T??ny??', '9111', 7),
(3147, 'T??pe', '4132', 8),
(3148, 'Terem', '4342', 15),
(3149, 'Ter??ny', '2696', 12),
(3150, 'Tereske', '2652', 12),
(3151, 'Teresztenye', '3757', 4),
(3152, 'Terpes', '3334', 9),
(3153, 'T??s', '8109', 18),
(3154, 'T??sa', '2635', 13),
(3155, 'T??senfa', '7843', 2),
(3156, 'T??seny', '7834', 2),
(3157, 'Tesk??nd', '8991', 19),
(3158, 'T??t', '9100', 7),
(3159, 'Tet??tlen', '4184', 8),
(3160, 'Tevel', '7181', 16),
(3161, 'Tibolddar??c', '3423', 4),
(3162, 'Tiborsz??ll??s', '4353', 15),
(3163, 'Tihany', '8237', 18),
(3164, 'Tikos', '8731', 14),
(3165, 'Tilaj', '8782', 19),
(3166, 'Tim??r', '4466', 15),
(3167, 'Tinnye', '2086', 13),
(3168, 'Tiszaadony', '4833', 15),
(3169, 'Tiszaalp??r', '6066', 1),
(3170, 'Tiszaalp??r', '6067', 1),
(3171, 'Tiszab??bolna', '3465', 4),
(3172, 'Tiszabecs', '4951', 15),
(3173, 'Tiszabercel', '4474', 15),
(3174, 'Tiszabezd??d', '4624', 15),
(3175, 'Tiszab??', '5232', 10),
(3176, 'Tiszabura', '5235', 10),
(3177, 'Tiszacs??cse', '4947', 15),
(3178, 'Tiszacsege', '4066', 8),
(3179, 'Tiszacsermely', '3972', 4),
(3180, 'Tiszadada', '4455', 15),
(3181, 'Tiszaderzs', '5243', 10),
(3182, 'Tiszadob', '4456', 15),
(3183, 'Tiszadorogma', '3466', 4),
(3184, 'Tiszaeszl??r', '4446', 15),
(3185, 'Tiszaeszl??r', '4464', 15),
(3186, 'Tiszaf??ldv??r', '5430', 10),
(3187, 'Tiszaf??ldv??r', '5461', 10),
(3188, 'Tiszaf??red', '5350', 10),
(3189, 'Tiszaf??red', '5358', 10),
(3190, 'Tiszaf??red', '5359', 10),
(3191, 'Tiszagyenda', '5233', 10),
(3192, 'Tiszagyulah??za', '4097', 8),
(3193, 'Tiszaigar', '5361', 10),
(3194, 'Tiszainoka', '5464', 10),
(3195, 'Tiszajen??', '5094', 10),
(3196, 'Tiszakany??r', '4493', 15),
(3197, 'Tiszakar??d', '3971', 4),
(3198, 'Tiszak??cske', '6060', 1),
(3199, 'Tiszak??cske', '6062', 1),
(3200, 'Tiszakerecseny', '4834', 15),
(3201, 'Tiszakeszi', '3458', 4),
(3202, 'Tiszak??r??d', '4946', 15),
(3203, 'Tiszak??rt', '5471', 10),
(3204, 'Tiszak??rt', '5472', 10),
(3205, 'Tiszalad??ny', '3929', 4),
(3206, 'Tiszal??k', '4447', 15),
(3207, 'Tiszal??k', '4450', 15),
(3208, 'Tiszal??c', '3565', 4),
(3209, 'Tiszamogyor??s', '4645', 15),
(3210, 'Tiszanagyfalu', '4463', 15),
(3211, 'Tiszan??na', '3385', 9),
(3212, 'Tisza??rs', '5362', 10),
(3213, 'Tiszapalkonya', '3587', 4),
(3214, 'Tiszap??sp??ki', '5211', 10),
(3215, 'Tiszar??d', '4503', 15),
(3216, 'Tiszaroff', '5234', 10),
(3217, 'Tiszasas', '5474', 10),
(3218, 'Tiszas??ly', '5061', 10),
(3219, 'Tiszaszalka', '4831', 15),
(3220, 'Tiszaszentimre', '5322', 10),
(3221, 'Tiszaszentimre', '5323', 10),
(3222, 'Tiszaszentm??rton', '4628', 15),
(3223, 'Tiszasziget', '6756', 5),
(3224, 'Tiszasz??l??s', '5244', 10),
(3225, 'Tiszatardos', '3928', 4),
(3226, 'Tiszatarj??n', '3589', 4),
(3227, 'Tiszatelek', '4486', 15),
(3228, 'Tiszatelek', '4487', 15),
(3229, 'Tiszateny??', '5082', 10),
(3230, 'Tiszaug', '6064', 1),
(3231, 'Tisza??jv??ros', '3580', 4),
(3232, 'Tiszavalk', '3464', 4),
(3233, 'Tiszav??rkony', '5092', 10),
(3234, 'Tiszav??rkony', '5095', 10),
(3235, 'Tiszavasv??ri', '4440', 15),
(3236, 'Tiszavid', '4832', 15),
(3237, 'Tisztaberek', '4969', 15),
(3238, 'Tivadar', '4921', 15),
(3239, 'T??alm??s', '2252', 13),
(3240, 'T??falu', '3354', 9),
(3241, 'T??fej', '8946', 19),
(3242, 'T??f??', '7348', 2),
(3243, 'T??k', '2073', 13),
(3244, 'Tokaj', '3910', 4),
(3245, 'Tokod', '2531', 11),
(3246, 'Tokodalt??r??', '2532', 11),
(3247, 'T??k??l', '2316', 13),
(3248, 'Tokorcs', '9561', 17),
(3249, 'Tolcsva', '3934', 4),
(3250, 'Told', '4117', 8),
(3251, 'Tolm??cs', '2657', 12),
(3252, 'Tolna', '7130', 16),
(3253, 'Tolna', '7131', 16),
(3254, 'Tolnan??medi', '7083', 16),
(3255, 'T??lt??stava', '9086', 7),
(3256, 'Tomajmonostora', '5324', 10),
(3257, 'Tomor', '3787', 4),
(3258, 'T??m??rd', '9738', 17),
(3259, 'T??m??rk??ny', '6646', 5),
(3260, 'Tompa', '6422', 1),
(3261, 'Tompal??dony', '9662', 17),
(3262, 'Tordas', '2463', 6),
(3263, 'Tormaf??lde', '8876', 19),
(3264, 'Torm??s', '7383', 2),
(3265, 'Torm??sliget', '9736', 17),
(3266, 'Tornabarakony', '3765', 4),
(3267, 'Tornak??polna', '3761', 4),
(3268, 'Tornan??daska', '3767', 4),
(3269, 'Tornaszentandr??s', '3765', 4),
(3270, 'Tornaszentjakab', '3769', 4),
(3271, 'Tornyiszentmikl??s', '8877', 19),
(3272, 'Tornyosn??meti', '3877', 4),
(3273, 'Tornyosp??lca', '4642', 15),
(3274, 'T??r??kb??lint', '2045', 13),
(3275, 'T??r??kkopp??ny', '7285', 14),
(3276, 'T??r??kszentmikl??s', '5200', 10),
(3277, 'T??r??kszentmikl??s', '5212', 10),
(3278, 'Torony', '9791', 17),
(3279, 'T??rtel', '2747', 13),
(3280, 'Torvaj', '8660', 14),
(3281, 'T??szeg', '5091', 10),
(3282, 'T??tkoml??s', '5940', 3),
(3283, 'T??tszentgy??rgy', '7981', 2),
(3284, 'T??tszentm??rton', '8865', 19),
(3285, 'T??tszerdahely', '8864', 19),
(3286, 'T??tt??s', '7755', 2),
(3287, 'T??t??jfalu', '7918', 14),
(3288, 'T??tv??zsony', '8246', 18),
(3289, 'Trizs', '3724', 4),
(3290, 'Tunyogmatolcs', '4731', 15),
(3291, 'Tura', '2194', 13),
(3292, 'T??ristv??ndi', '4944', 15),
(3293, 'T??rje', '8796', 19),
(3294, 'T??rkeve', '5420', 10),
(3295, 'T??rony', '7811', 2),
(3296, 'T??rricse', '4968', 15),
(3297, 'T??skev??r', '8477', 18),
(3298, 'Tuzs??r', '4623', 15),
(3299, 'Tyukod', '4762', 15),
(3300, 'Udvar', '7718', 2),
(3301, 'Udvari', '7066', 16),
(3302, 'Ugod', '8564', 18),
(3303, '??jbarok', '2066', 6),
(3304, '??jcsan??los', '3716', 4),
(3305, '??jdombr??d', '4491', 15),
(3306, '??jfeh??rt??', '4244', 15),
(3307, '??jharty??n', '2367', 13),
(3308, '??jir??z', '4146', 8),
(3309, '??jireg', '7095', 16),
(3310, '??jken??z', '4635', 15),
(3311, '??jk??r', '9472', 7),
(3312, '??jk??gy??s', '5661', 3),
(3313, '??jlengyel', '2724', 13),
(3314, '??jl??ta', '4288', 8),
(3315, '??jl??rincfalva', '3387', 9),
(3316, '??jpetre', '7766', 2),
(3317, '??jr??naf??', '9244', 7),
(3318, '??jsolt', '6320', 1),
(3319, '??jszalonta', '5727', 3),
(3320, '??jsz??sz', '5052', 10),
(3321, '??jszentiv??n', '6754', 5),
(3322, '??jszentmargita', '4065', 8),
(3323, '??jszilv??s', '2768', 13),
(3324, '??jtelek', '6337', 1),
(3325, '??jtikos', '4096', 8),
(3326, '??judvar', '8778', 19),
(3327, '??jv??rfalva', '7436', 14),
(3328, 'Ukk', '8347', 18),
(3329, '??ll??s', '6794', 5),
(3330, '??ll??', '2225', 13),
(3331, 'Und', '9464', 7),
(3332, '??ny', '2528', 11),
(3333, 'Uppony', '3622', 4),
(3334, 'Ura', '4763', 15),
(3335, 'Urai??jfalu', '9651', 17),
(3336, '??rhida', '8142', 6),
(3337, '??ri', '2244', 13),
(3338, '??rk??t', '8409', 18),
(3339, '??r??m', '2096', 13),
(3340, 'Uszka', '4952', 15),
(3341, 'Usz??d', '6332', 1),
(3342, 'Uzsa', '8321', 18),
(3343, 'V??c', '2600', 13),
(3344, 'V??cduka', '2167', 13),
(3345, 'V??cegres', '2184', 13),
(3346, 'V??charty??n', '2164', 13),
(3347, 'V??ckis??jfalu', '2185', 13),
(3348, 'V??cr??t??t', '2163', 13),
(3349, 'V??cszentl??szl??', '2115', 13),
(3350, 'Vadna', '3636', 4),
(3351, 'Vadosfa', '9346', 7),
(3352, 'V??g', '9327', 7),
(3353, 'V??g??shuta', '3992', 4),
(3354, 'Vaja', '4562', 15),
(3355, 'Vajd??cska', '3961', 4),
(3356, 'Vajszl??', '7838', 2),
(3357, 'Vajta', '7041', 6),
(3358, 'V??l', '2473', 6),
(3359, 'Valk??', '2114', 13),
(3360, 'Valkonya', '8885', 19);
INSERT INTO `city` (`city_id`, `city_name`, `postal_code`, `region_id`) VALUES
(3361, 'V??llaj', '4351', 15),
(3362, 'V??llus', '8316', 19),
(3363, 'V??mosatya', '4936', 15),
(3364, 'V??moscsal??d', '9665', 17),
(3365, 'V??mosgy??rk', '3291', 9),
(3366, 'V??mosmikola', '2635', 13),
(3367, 'V??mosoroszi', '4966', 15),
(3368, 'V??mosp??rcs', '4287', 8),
(3369, 'V??mosszabadi', '9061', 7),
(3370, 'V??mos??jfalu', '3941', 4),
(3371, 'V??ncsod', '4119', 8),
(3372, 'Vanyarc', '2688', 12),
(3373, 'Vanyola', '8552', 18),
(3374, 'V??rad', '7973', 2),
(3375, 'V??ralja', '7354', 16),
(3376, 'Var??szl??', '8723', 14),
(3377, 'V??rasz??', '3254', 9),
(3378, 'V??rbalog', '9243', 7),
(3379, 'Varb??', '3778', 4),
(3380, 'Varb??c', '3756', 4),
(3381, 'V??rda', '7442', 14),
(3382, 'V??rdomb', '7146', 16),
(3383, 'V??rf??lde', '8891', 19),
(3384, 'Varga', '7370', 2),
(3385, 'V??rgesztes', '2824', 11),
(3386, 'V??rkesz??', '8523', 18),
(3387, 'V??rong', '7214', 16),
(3388, 'V??rosf??ld', '6033', 1),
(3389, 'V??rosl??d', '8445', 18),
(3390, 'V??rpalota', '8100', 18),
(3391, 'V??rpalota', '8103', 18),
(3392, 'V??rpalota', '8104', 18),
(3393, 'Vars??d', '7067', 16),
(3394, 'Vars??ny', '3178', 12),
(3395, 'V??rv??lgy', '8316', 19),
(3396, 'Vasad', '2211', 13),
(3397, 'Vasalja', '9921', 17),
(3398, 'V??s??rosb??c', '7926', 2),
(3399, 'V??s??rosdomb??', '7362', 2),
(3400, 'V??s??rosfalu', '9343', 7),
(3401, 'V??s??rosmiske', '9552', 17),
(3402, 'V??s??rosnam??ny', '4800', 15),
(3403, 'V??s??rosnam??ny', '4803', 15),
(3404, 'V??s??rosnam??ny', '4804', 15),
(3405, 'Vasasszonyfa', '9744', 17),
(3406, 'Vasboldogasszony', '8914', 19),
(3407, 'Vasegerszeg', '9661', 17),
(3408, 'Vashossz??falu', '9674', 17),
(3409, 'Vaskeresztes', '9795', 17),
(3410, 'Vask??t', '6521', 1),
(3411, 'Vasmegyer', '4502', 15),
(3412, 'Vasp??r', '8998', 19),
(3413, 'Vassur??ny', '9741', 17),
(3414, 'Vassz??cseny', '9763', 17),
(3415, 'Vasszentmih??ly', '9953', 17),
(3416, 'Vasszilv??gy', '9747', 17),
(3417, 'Vasv??r', '9800', 17),
(3418, 'Vaszar', '8542', 18),
(3419, 'V??szoly', '8245', 18),
(3420, 'V??t', '9748', 17),
(3421, 'Vatta', '3431', 4),
(3422, 'V??zsnok', '7370', 2),
(3423, 'V??cs', '3265', 9),
(3424, 'Vecs??s', '2220', 13),
(3425, 'V??gegyh??za', '5811', 3),
(3426, 'Vejti', '7838', 2),
(3427, 'V??k??ny', '7333', 2),
(3428, 'Vekerd', '4143', 8),
(3429, 'Velem', '9726', 17),
(3430, 'Velem??r', '9946', 17),
(3431, 'Velence', '2481', 6),
(3432, 'Vel??ny', '7951', 2),
(3433, 'V??m??nd', '7726', 2),
(3434, 'V??nek', '9062', 7),
(3435, 'V??p', '9751', 17),
(3436, 'Vereb', '2477', 6),
(3437, 'Veresegyh??z', '2112', 13),
(3438, 'Ver??ce', '2621', 13),
(3439, 'Verpel??t', '3351', 9),
(3440, 'Verseg', '2174', 13),
(3441, 'Versend', '7752', 2),
(3442, 'V??rtesacsa', '8089', 6),
(3443, 'V??rtesbogl??r', '8085', 6),
(3444, 'V??rteskethely', '2859', 11),
(3445, 'V??rtessoml??', '2823', 11),
(3446, 'V??rtessz??l??s', '2837', 11),
(3447, 'V??rtestolna', '2833', 11),
(3448, 'V??se', '8721', 14),
(3449, 'Veszk??ny', '9352', 7),
(3450, 'Veszpr??m', '8200', 18),
(3451, 'Veszpr??m', '8411', 18),
(3452, 'Veszpr??m', '8412', 18),
(3453, 'Veszpr??mfajsz', '8248', 18),
(3454, 'Veszpr??mgalsa', '8475', 18),
(3455, 'Veszpr??mvars??ny', '8438', 7),
(3456, 'V??szt??', '5530', 3),
(3457, 'Vezseny', '5093', 10),
(3458, 'Vid', '8484', 18),
(3459, 'Vig??ntpetend', '8294', 18),
(3460, 'Vill??ny', '7773', 2),
(3461, 'Vill??nyk??vesd', '7772', 2),
(3462, 'Vilm??ny', '3891', 4),
(3463, 'Vilonya', '8194', 18),
(3464, 'Vilyvit??ny', '3991', 4),
(3465, 'Vin??r', '9535', 18),
(3466, 'Vindornyafok', '8354', 19),
(3467, 'Vindornyalak', '8353', 19),
(3468, 'Vindornyasz??l??s', '8355', 19),
(3469, 'Visegr??d', '2025', 13),
(3470, 'Visegr??d', '2026', 13),
(3471, 'Visnye', '7533', 14),
(3472, 'Visonta', '3271', 9),
(3473, 'Visonta', '3272', 9),
(3474, 'Viss', '3956', 4),
(3475, 'Visz', '8681', 14),
(3476, 'Visz??k', '9932', 17),
(3477, 'Viszl??', '3825', 4),
(3478, 'Visznek', '3293', 9),
(3479, 'Vitny??d', '9371', 7),
(3480, 'Vizsl??s', '3128', 12),
(3481, 'Vizsoly', '3888', 4),
(3482, 'V??zv??r', '7588', 14),
(3483, 'V??ck??nd', '8931', 19),
(3484, 'Vok??ny', '7768', 2),
(3485, 'V??lcsej', '9462', 7),
(3486, 'V??n??ck', '9516', 17),
(3487, 'Vonyarcvashegy', '8314', 19),
(3488, 'V??r??st??', '8291', 18),
(3489, 'V??rs', '8711', 14),
(3490, 'Zabar', '3124', 12),
(3491, 'Z??dor', '7976', 2),
(3492, 'Z??dorfalva', '3726', 4),
(3493, 'Zagyvar??kas', '5051', 10),
(3494, 'Zagyvasz??nt??', '3031', 9),
(3495, 'Z??hony', '4625', 15),
(3496, 'Zajk', '8868', 19),
(3497, 'Zajta', '4974', 15),
(3498, 'Z??k??ny', '8852', 14),
(3499, 'Z??k??nyfalu', '8853', 14),
(3500, 'Z??k??nysz??k', '6787', 5),
(3501, 'Zala', '8660', 14),
(3502, 'Zalaap??ti', '8741', 19),
(3503, 'Zalabaksa', '8971', 19),
(3504, 'Zalab??r', '8798', 19),
(3505, 'Zalaboldogfa', '8992', 19),
(3506, 'Zalacs??ny', '8782', 19),
(3507, 'Zalacs??b', '8996', 19),
(3508, 'Zalaegerszeg', '8900', 19),
(3509, 'Zalaerd??d', '8344', 18),
(3510, 'Zalagy??m??r??', '8349', 18),
(3511, 'Zalahal??p', '8308', 18),
(3512, 'Zalah??sh??gy', '8997', 19),
(3513, 'Zalaigrice', '8761', 19),
(3514, 'Zalaistv??nd', '8932', 19),
(3515, 'Zalakaros', '8749', 19),
(3516, 'Zalakom??r', '8751', 19),
(3517, 'Zalakom??r', '8752', 19),
(3518, 'Zalak??vesk??t', '8354', 19),
(3519, 'Zalal??v??', '8999', 19),
(3520, 'Zalameggyes', '8348', 18),
(3521, 'Zalamerenye', '8747', 19),
(3522, 'Zalas??rszeg', '8756', 19),
(3523, 'Zalaszabar', '8743', 19),
(3524, 'Zalasz??nt??', '8353', 19),
(3525, 'Zalaszegv??r', '8476', 18),
(3526, 'Zalaszentbal??zs', '8772', 19),
(3527, 'Zalaszentgr??t', '8785', 19),
(3528, 'Zalaszentgr??t', '8789', 19),
(3529, 'Zalaszentgr??t', '8790', 19),
(3530, 'Zalaszentgr??t', '8793', 19),
(3531, 'Zalaszentgr??t', '8795', 19),
(3532, 'Zalaszentgy??rgy', '8994', 19),
(3533, 'Zalaszentiv??n', '8921', 19),
(3534, 'Zalaszentjakab', '8827', 19),
(3535, 'Zalaszentl??szl??', '8788', 19),
(3536, 'Zalaszentl??rinc', '8921', 19),
(3537, 'Zalaszentm??rton', '8764', 19),
(3538, 'Zalaszentmih??ly', '8936', 19),
(3539, 'Zalaszombatfa', '8969', 19),
(3540, 'Zal??ta', '7839', 2),
(3541, 'Zalat??rnok', '8947', 19),
(3542, 'Zala??jlak', '8822', 19),
(3543, 'Zalav??r', '8392', 19),
(3544, 'Zalav??g', '8792', 19),
(3545, 'Zalkod', '3957', 4),
(3546, 'Zam??rdi', '8621', 14),
(3547, 'Z??moly', '8081', 6),
(3548, 'Z??nka', '8251', 18),
(3549, 'Zar??nk', '3296', 9),
(3550, 'Z??vod', '7182', 16),
(3551, 'Zebecke', '8957', 19),
(3552, 'Zebeg??ny', '2627', 13),
(3553, 'Zempl??nag??rd', '3977', 4),
(3554, 'Zeng??v??rkony', '7720', 2),
(3555, 'Zichy??jfalu', '8112', 6),
(3556, 'Zics', '8672', 14),
(3557, 'Ziliz', '3794', 4),
(3558, 'Zim??ny', '7471', 14),
(3559, 'Zirc', '8420', 18),
(3560, 'Z??k', '7671', 2),
(3561, 'Zomba', '7173', 16),
(3562, 'Zsad??ny', '5537', 3),
(3563, 'Zs??ka', '4142', 8),
(3564, 'Zs??mb??k', '2072', 13),
(3565, 'Zs??mbok', '2116', 13),
(3566, 'Zsana', '6411', 1),
(3567, 'Zsaroly??n', '4961', 15),
(3568, 'Zsebeh??za', '9346', 7),
(3569, 'Zs??deny', '9635', 17),
(3570, 'Zselickisfalud', '7477', 14),
(3571, 'Zselickislak', '7400', 14),
(3572, 'Zselicszentp??l', '7474', 14),
(3573, 'Zsennye', '9766', 17),
(3574, 'Zsira', '9476', 7),
(3575, 'Zsomb??', '6792', 5),
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
(2, 'ez??st'),
(3, '??sv??ny'),
(4, 'nemesf??m'),
(5, 'dr??gak??'),
(6, 'teh??ntej'),
(7, 'kecsketej'),
(8, 'liszt'),
(9, 'barack'),
(10, 'cukor'),
(11, 'kaka??'),
(12, '??leszt??');

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
(1, 'B??cs-Kiskun'),
(2, 'Baranya'),
(3, 'B??k??s'),
(4, 'Borsod-Aba??j-Zempl??n'),
(5, 'Csongr??d-Csan??d'),
(6, 'Fej??r'),
(7, 'Gy??r-Moson-Sopron'),
(8, 'Hajd??-Bihar'),
(9, 'Heves'),
(10, 'J??sz-Nagykun-Szolnok'),
(11, 'Kom??rom-Esztergom'),
(12, 'N??gr??d'),
(13, 'Pest'),
(14, 'Somogy'),
(15, 'Szabolcs-Szatm??r-Bereg'),
(16, 'Tolna'),
(17, 'Vas'),
(18, 'Veszpr??m'),
(19, 'Zala'),
(20, 'Budapest (f??v??ros)');

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
(1, 'K??rnyezetbar??t'),
(2, 'K??zzel k??sz??lt'),
(3, 'Etikusan beszerzett alapanyagok'),
(4, 'Fenntarthat??'),
(5, 'Csomagol??s mentes'),
(6, 'Veget??ri??nus'),
(7, 'Veg??n'),
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
