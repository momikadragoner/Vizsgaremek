-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 13, 2022 at 09:37 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `changeProductVisibility` (IN `isPub` TINYINT, IN `lstUp` DATETIME, IN `prodId` INT)  NO SQL
BEGIN
	UPDATE `product` SET `is_published`=isPub, `last_updated_at`=lstUp WHERE product_id = prodId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProduct` (IN `prodId` INT)  NO SQL
BEGIN
	DELETE FROM `product_material` WHERE product_id = prodId;
    DELETE FROM `product_picture` WHERE product_id = prodId;
    DELETE FROM `product_tag` WHERE product_id = prodId;
    UPDATE `product` SET `name`="Eltávolított termék",`price`=NULL,`description`=NULL,`inventory`=NULL,`delivery`=NULL,`category`=NULL,`rating`=NULL,`vendor_id`=NULL,`discount`=NULL,`is_published`=FALSE,`is_removed`=TRUE,`created_at`=NULL,`last_updated_at`=NULL,`published_at`=NULL WHERE `product_id` = prodId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertCart` (IN `userId` INT, IN `prodId` INT)  NO SQL
BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertMaterials` (IN `mats` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL
BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertPictures` (IN `pics` VARCHAR(255), IN `length` INT, IN `prodId` INT, IN `thId` INT)  NO SQL
BEGIN
	DECLARE x INT DEFAULT 1;
	CREATE TEMPORARY TABLE pictures(i INT, url VARCHAR(50));
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertProduct` (IN `nm` VARCHAR(50), IN `prc` INT, IN `dsc` TEXT, IN `inv` INT, IN `del` VARCHAR(50), IN `cat` VARCHAR(50), IN `venId` INT, IN `disc` INT, IN `isPub` TINYINT, IN `crAt` DATETIME, IN `pbAt` DATETIME, IN `tags` VARCHAR(255), IN `tagsL` INT, IN `mats` VARCHAR(255), IN `matsL` INT, IN `pics` VARCHAR(255), IN `picsL` INT, IN `thumId` INT)  NO SQL
BEGIN
INSERT INTO `product`(`name`, `price`, `description`, `inventory`, `delivery`, `category`, `vendor_id`, `discount`, `is_published`, `created_at`, `published_at`) VALUES (nm, prc, dsc, inv, del, cat, venId, disc, isPub, crAt, pbAt);
SET @productId = (SELECT LAST_INSERT_ID());
CALL insertMaterials(mats, matsL, @productId);
CALL insertTags(tags, tagsL, @productId);
CALL insertPictures(pics, picsL, @productId, thumId);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertTags` (IN `tgs` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL
BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertWishList` (IN `prodId` INT, IN `userId` INT, IN `addAt` DATETIME)  NO SQL
BEGIN
	INSERT INTO wish_list(product_id, member_id, added_at) VALUES(prodId,userId,addAt);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCart` (IN `userId` INT)  NO SQL
BEGIN
	SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl, cart_product.amount, cart_product.status
FROM cart
INNER JOIN cart_product ON cart_product.cart_id = cart.cart_id
INNER JOIN product ON product.product_id = cart_product.product_id
INNER JOIN member ON member.member_id = product.vendor_id
WHERE cart.member_id = userId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectWishList` (IN `userId` INT)  NO SQL
SELECT product.product_id AS productId, product.name, product.price, product.vendor_id AS sellerId, product.discount, product.is_published AS isPublic, member.first_name AS sellerFirstName, member.last_name AS sellerLastName, ( SELECT product_picture.resource_link FROM product_picture WHERE product_picture.is_thumbnail = TRUE AND product.product_id = product_picture.product_id LIMIT 1 ) AS imgUrl 
FROM wish_list
INNER JOIN product ON product.product_id = wish_list.product_id
INNER JOIN member ON member.member_id = product.vendor_id
WHERE wish_list.member_id = userId AND product.is_published = TRUE$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateMaterials` (IN `mats` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL
BEGIN
	DELETE FROM product_material WHERE product_id = prodId;
    CALL insertMaterials(mats, length, prodId);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePictures` (IN `pics` VARCHAR(255), IN `length` INT, IN `prodId` INT, IN `thId` INT)  NO SQL
BEGIN
	DELETE FROM product_picture WHERE product_id = prodId;
    CALL insertPictures(pics, length, prodId, thId);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateProduct` (IN `nm` VARCHAR(50), IN `prc` INT, IN `dsc` TEXT, IN `inv` INT, IN `del` VARCHAR(50), IN `cat` VARCHAR(50), IN `disc` INT, IN `isPub` TINYINT, IN `lstUp` DATETIME, IN `pubAt` DATETIME, IN `prodId` INT, IN `tags` VARCHAR(255), IN `tagsL` INT, IN `mats` VARCHAR(255), IN `matsL` INT, IN `pics` VARCHAR(255), IN `picsL` INT, IN `thumId` INT)  NO SQL
BEGIN
	UPDATE `product` SET `name`=nm,`price`=prc,`description`=dsc,`inventory`=inv,`delivery`=del, `category`=cat,`discount`=disc,`is_published`=isPub,`last_updated_at`=lstUp, `published_at`=pubAt WHERE product_id = prodId;
    CALL updateTags(tags, tagsL, prodId);
    CALL updateMaterials(mats, matsL, prodId);
    CALL updatePictures(pics, picsL, prodId, thumId);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateTags` (IN `tgs` VARCHAR(255), IN `length` INT, IN `prodId` INT)  NO SQL
BEGIN
	DELETE FROM product_tag WHERE product_id = prodId;
    CALL insertTags(tgs, length, prodId);
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
-- Table structure for table `follower_relations`
--

CREATE TABLE `follower_relations` (
  `follower_id` int(11) NOT NULL,
  `following_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoice`
--

CREATE TABLE `invoice` (
  `invoice_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `shipping_address_id` int(11) NOT NULL,
  `sum_price` int(11) DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoice_product`
--

CREATE TABLE `invoice_product` (
  `invoice_product_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `material`
--

CREATE TABLE `material` (
  `material_id` int(11) NOT NULL,
  `material_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

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
  `message` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
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
  `resource_link` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
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
-- Table structure for table `shipping_address`
--

CREATE TABLE `shipping_address` (
  `shipping_address_id` int(11) NOT NULL,
  `member_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
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
-- Indexes for table `follower_relations`
--
ALTER TABLE `follower_relations`
  ADD PRIMARY KEY (`follower_id`,`following_id`),
  ADD KEY `following_id` (`following_id`);

--
-- Indexes for table `invoice`
--
ALTER TABLE `invoice`
  ADD PRIMARY KEY (`invoice_id`),
  ADD KEY `shipping_address_id` (`shipping_address_id`),
  ADD KEY `vendor_id` (`vendor_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `invoice_product`
--
ALTER TABLE `invoice_product`
  ADD PRIMARY KEY (`invoice_product_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `invoice_id` (`invoice_id`);

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
-- AUTO_INCREMENT for table `invoice`
--
ALTER TABLE `invoice`
  MODIFY `invoice_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoice_product`
--
ALTER TABLE `invoice_product`
  MODIFY `invoice_product_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `material`
--
ALTER TABLE `material`
  MODIFY `material_id` int(11) NOT NULL AUTO_INCREMENT;

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
-- AUTO_INCREMENT for table `shipping_address`
--
ALTER TABLE `shipping_address`
  MODIFY `shipping_address_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag`
--
ALTER TABLE `tag`
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT;

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
-- Constraints for table `follower_relations`
--
ALTER TABLE `follower_relations`
  ADD CONSTRAINT `follower_relations_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `member` (`member_id`),
  ADD CONSTRAINT `follower_relations_ibfk_2` FOREIGN KEY (`following_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `invoice`
--
ALTER TABLE `invoice`
  ADD CONSTRAINT `invoice_ibfk_1` FOREIGN KEY (`shipping_address_id`) REFERENCES `shipping_address` (`shipping_address_id`),
  ADD CONSTRAINT `invoice_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  ADD CONSTRAINT `invoice_ibfk_3` FOREIGN KEY (`vendor_id`) REFERENCES `member` (`member_id`);

--
-- Constraints for table `invoice_product`
--
ALTER TABLE `invoice_product`
  ADD CONSTRAINT `invoice_product_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `invoice_product_ibfk_2` FOREIGN KEY (`invoice_id`) REFERENCES `invoice` (`invoice_id`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `member` (`member_id`),
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`reciver_id`) REFERENCES `member` (`member_id`);

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
