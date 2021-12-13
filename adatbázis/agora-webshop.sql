-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 21, 2021 at 03:58 PM
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

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `cart_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `shipping_address_id` int(11) NOT NULL,
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
  `amount` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category_relations`
--

CREATE TABLE `category_relations` (
  `parent_category_id` int(11) NOT NULL,
  `child_category_id` int(11) NOT NULL
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
  `amount` int(11) DEFAULT NULL
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
  `description` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `supplier_price` int(11) DEFAULT NULL,
  `inventory` int(11) DEFAULT NULL,
  `delivery` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `discount` int(11) DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_category`
--

CREATE TABLE `product_category` (
  `product_category_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
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
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `category_relations`
--
ALTER TABLE `category_relations`
  ADD PRIMARY KEY (`parent_category_id`,`child_category_id`),
  ADD KEY `child_category_id` (`child_category_id`);

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
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `product_category`
--
ALTER TABLE `product_category`
  ADD PRIMARY KEY (`product_category_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `category_id` (`category_id`);

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
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT;

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
-- AUTO_INCREMENT for table `product_category`
--
ALTER TABLE `product_category`
  MODIFY `product_category_id` int(11) NOT NULL AUTO_INCREMENT;

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
-- Constraints for table `category_relations`
--
ALTER TABLE `category_relations`
  ADD CONSTRAINT `category_relations_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `category` (`category_id`),
  ADD CONSTRAINT `category_relations_ibfk_2` FOREIGN KEY (`child_category_id`) REFERENCES `category` (`category_id`);

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
-- Constraints for table `product_category`
--
ALTER TABLE `product_category`
  ADD CONSTRAINT `product_category_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  ADD CONSTRAINT `product_category_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`);

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
