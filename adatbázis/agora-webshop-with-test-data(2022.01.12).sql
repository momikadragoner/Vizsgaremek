-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 12, 2022 at 08:47 PM
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
  `sum_price` int(11) DEFAULT NULL
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
  `sum_price` int(11) DEFAULT NULL
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

--
-- Dumping data for table `material`
--

INSERT INTO `material` (`material_id`, `material_name`) VALUES
(1, 'arany'),
(2, 'ezüst'),
(3, 'ásvány'),
(4, 'nemesfém'),
(5, 'drágakő');

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

--
-- Dumping data for table `member`
--

INSERT INTO `member` (`member_id`, `first_name`, `last_name`, `email`, `password`, `phone`, `about`, `profile_picture_link`, `header_picture_link`, `registered_at`, `last_login`, `is_vendor`, `is_admin`) VALUES
(1, 'Zita', 'Boros', 'zitaboros893@mail.com', '', '+36 30 533 6688', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 1, 0),
(2, 'Aranka', 'Németh', 'arankanemeth59@mail.com', '', '+36 10 362 3553', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 1, 0),
(3, 'Valéria', 'Lakatos', 'valerialakatos827@mail.com', '', '+36 20 115 3159', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 1, 0),
(4, 'Csilla', 'Takács', 'csillatakacs193@mail.com', '', '+36 10 684 5456', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 1, 0),
(5, 'Levente', 'Szücs', 'leventeszucs128@mail.com', '', '+36 40 216 4237', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(6, 'Gabriella', 'Kiss', 'gabriellakiss91@mail.com', '', '+36 40 322 2473', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(7, 'Melinda', 'László', 'melindalaszlo179@mail.com', '', '+36 80 394 8928', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(8, 'Antal', 'Kelemen', 'antalkelemen705@mail.com', '', '+36 10 794 7746', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(9, 'László', 'Papp', 'laszlopapp782@mail.com', '', '+36 90 363 3328', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(10, 'Tamás', 'Bakos', 'tamasbakos765@mail.com', '', '+36 20 386 1345', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(11, 'Veronika', 'Bakos', 'veronikabakos199@mail.com', '', '+36 70 253 7718', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(12, 'Dezső', 'Major', 'dezsomajor431@mail.com', '', '+36 10 378 6696', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(13, 'Szilárd', 'Halász', 'szilardhalasz54@mail.com', '', '+36 30 566 1723', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(14, 'Bertalan', 'Székely', 'bertalanszekely127@mail.com', '', '+36 80 548 1557', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(15, 'Antal', 'Virág', 'antalvirag904@mail.com', '', '+36 70 269 2786', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(16, 'Antal', 'Papp', 'antalpapp937@mail.com', '', '+36 60 897 2647', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(17, 'Péter', 'Kelemen', 'peterkelemen36@mail.com', '', '+36 90 524 8641', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(18, 'Krisztina', 'Jakab', 'krisztinajakab258@mail.com', '', '+36 40 841 2554', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(19, 'Hajnalka', 'Sándor', 'hajnalkasandor393@mail.com', '', '+36 80 858 3484', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(20, 'Ildikó', 'Biró', 'ildikobiro1@mail.com', '', '+36 70 327 8823', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0);

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
  `created_at` datetime DEFAULT NULL,
  `last_updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`product_id`, `name`, `price`, `description`, `inventory`, `delivery`, `category`, `rating`, `vendor_id`, `discount`, `is_published`, `created_at`, `last_updated_at`, `published_at`) VALUES
(1, 'Arany nyaklánc', 6990, 'Nagyon szép nyaklánc zöld kővel díszítve.', 12, 'Azonnal szállítható', 'Ékszer', 4.7, 1, NULL, 1, '2022-01-06 00:00:00', NULL, '2022-01-10 00:00:00'),
(2, 'Ásvány nyakék', 4990, 'Barna színű achát ékszer.', 8, 'Azonnal szállítható', 'Ékszer', 4.7, 2, NULL, 1, '2022-01-06 00:00:00', NULL, '2022-01-10 00:00:00'),
(3, 'Gyönygy medál', 12990, 'Afrikai zebra jáspisból formált gömb alakú medál ezüst láncon.', 5, 'Azonnal szállítható', 'Ékszer', 4.6, 2, NULL, 1, '2022-01-06 00:00:00', NULL, '2022-01-10 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `product_material`
--

CREATE TABLE `product_material` (
  `product_material_id` int(11) NOT NULL,
  `material_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `product_material`
--

INSERT INTO `product_material` (`product_material_id`, `material_id`, `product_id`) VALUES
(1, 1, 1),
(2, 5, 1),
(3, 3, 2),
(4, 4, 2),
(5, 2, 3),
(6, 5, 3);

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

--
-- Dumping data for table `product_picture`
--

INSERT INTO `product_picture` (`product_picture_id`, `product_id`, `resource_name`, `resource_link`, `is_thumbnail`) VALUES
(1, 1, NULL, 'assets/item1.jpg', 1),
(2, 1, NULL, 'assets/item3.jfif', 0),
(3, 1, NULL, 'assets/item5.jfif', 0),
(4, 2, NULL, 'assets/item2.jpg', 1),
(5, 2, NULL, 'assets/item3.jfif', 0),
(6, 3, NULL, 'assets/item4.jpg', 1),
(7, 3, NULL, 'assets/item1.jpg', 0),
(8, 3, NULL, 'assets/item2.jpg', 0);

-- --------------------------------------------------------

--
-- Table structure for table `product_tag`
--

CREATE TABLE `product_tag` (
  `product_tag_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Dumping data for table `product_tag`
--

INSERT INTO `product_tag` (`product_tag_id`, `tag_id`, `product_id`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 2, 2),
(5, 4, 2),
(6, 2, 3),
(7, 1, 3),
(8, 5, 3);

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

--
-- Dumping data for table `review`
--

INSERT INTO `review` (`review_id`, `product_id`, `member_id`, `rating`, `points`, `title`, `content`, `published_at`) VALUES
(1, 1, 5, 5, 9, 'Szuper duper', 'Az egyik kedvenc ékszerem', '2022-01-11 00:00:00'),
(2, 1, 5, 4, 2, 'Jó', '-', '2022-01-11 00:00:00'),
(3, 1, 7, 5, 4, 'Ajándékba vettem', 'Biztos jó, nem tudom.', '2022-01-11 00:00:00'),
(4, 2, 8, 4, 7, 'Pont ezt kerestem', 'Mindenhol kerestem dejó h itt van', '2022-01-11 00:00:00'),
(5, 2, 9, 4, 5, 'Nagyszerű', '', '2022-01-11 00:00:00'),
(6, 3, 10, 5, 7, 'Minden amire valaha vágytam', '', '2022-01-11 00:00:00'),
(7, 3, 11, 5, 8, 'Egyszerűen tökéletes!!!', 'Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!', '2022-01-11 00:00:00'),
(8, 3, 12, 4, 3, 'Szép darab', 'Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom.', '2022-01-11 00:00:00');

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

--
-- Dumping data for table `tag`
--

INSERT INTO `tag` (`tag_id`, `tag_name`) VALUES
(1, 'Környezetbarát'),
(2, 'Kézzel készült'),
(3, 'Etikusan beszerzett alapanyagok'),
(4, 'Fenntartható'),
(5, 'Csomagolás mentes');

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
  MODIFY `material_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `member`
--
ALTER TABLE `member`
  MODIFY `member_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `product_material`
--
ALTER TABLE `product_material`
  MODIFY `product_material_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `product_picture`
--
ALTER TABLE `product_picture`
  MODIFY `product_picture_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `product_tag`
--
ALTER TABLE `product_tag`
  MODIFY `product_tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `review`
--
ALTER TABLE `review`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
