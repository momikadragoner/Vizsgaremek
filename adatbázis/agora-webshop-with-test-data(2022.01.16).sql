-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 16, 2022 at 07:33 PM
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
(5, 'drágakő'),
(6, 'tehéntej'),
(7, 'kecsketej');

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
(1, 'Zita', 'Boros', 'zitaboros893@mail.com', '', '+36 30 533 6688', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', 'assets/def-pfp1.png', NULL, '2022-01-11 19:39:17', NULL, 1, 0),
(2, 'Aranka', 'Németh', 'arankanemeth59@mail.com', '', '+36 10 362 3553', 'Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎 ', 'assets\\profilepic.jpg', NULL, '2022-01-11 19:39:17', NULL, 1, 0),
(3, 'Valéria', 'Lakatos', 'valerialakatos827@mail.com', '', '+36 20 115 3159', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', 'assets/def-pfp2.png', NULL, '2022-01-11 19:39:17', NULL, 1, 0),
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
(20, 'Ildikó', 'Biró', 'ildikobiro1@mail.com', '', '+36 70 327 8823', 'Aliquam quis arcu vitae purus imperdiet auctor vel sed dolor.', NULL, NULL, '2022-01-11 19:39:17', NULL, 0, 0),
(21, 'Éva', 'Nagy', 'evanagy784@mail.com', '', '+36 10 767 3558', 'könnyebb tehát keresztül Nagyon inkább italért. eljön. vagyok? tehát utolsó eddig a', 'assets/def-pfp2.png', NULL, '2022-01-11 00:00:00', NULL, 1, 0),
(22, 'Rozália', 'Jakab', 'rozaliajakab753@mail.com', '', '+36 10 926 7715', 'legjobb szeret. szükségem, ezzel következő szálljon tudom ezzel Nem érdekében kopog, sokkal tudom', 'assets/def-pfp2.png', NULL, '2022-01-10 00:00:00', NULL, 1, 0),
(23, 'Eszter', 'Takács', 'esztertakacs270@mail.com', 'secret', '+36 40 481 6394', 'ezek őket Hat Nem következő szálljon még egyikük tehát erre alszom, tehát és van szájba', 'assets/def-pfp2.png', NULL, '2022-01-07 00:00:00', NULL, 1, 0),
(24, 'Rozália', 'Papp', 'rozaliapapp670@mail.com', '', '+36 60 129 8813', 'Mindenkinek neki Isten építsen néhány akár bumról, működik. fene akár évente. le Féltékeny', 'assets/def-pfp1.png', NULL, '2022-01-22 00:00:00', NULL, 1, 0),
(25, 'Béla', 'Horváth', 'belahorvath812@mail.com', '', '+36 80 349 5696', 'néhány darabig szájba működik. csukott áll az a olyan éves itt éves amelyek', 'assets/def-pfp1.png', NULL, '2022-01-30 00:00:00', NULL, 1, 0);

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
(3, 'Gyönygy medál', 12990, 'Afrikai zebra jáspisból formált gömb alakú medál ezüst láncon.', 5, 'Azonnal szállítható', 'Ékszer', 4.6, 2, NULL, 1, '2022-01-06 00:00:00', NULL, '2022-01-10 00:00:00'),
(4, ' Ementáli Sajt', 15620, 'közé reggeli, csukott azt hiszem, például azt össze sokkal hónap Isten például mint közé ide? meg ', 3, 'Megrendelésre készül', 'Tejtermék', 2.75, 25, NULL, 1, '2022-01-28 00:00:00', NULL, '2022-01-28 00:00:00'),
(5, 'Friss Ementáli Sajt', 3610, 'reggeli, érdekében most isten alszom, van hozzá dolog sokkal vagyok? most mely meleg Nagyon ember. vacsora. ', 24, 'Azonnal szállítható', 'Tejtermék', 4, 21, NULL, 1, '2022-01-09 00:00:00', NULL, '2022-01-09 00:00:00'),
(6, 'Füstölt Cheddar Sajt', 6830, 'dolog lehetőség során az lesz évente. nem a szájba évente. szemben szabadságra ', 14, 'Azonnal szállítható', 'Tejtermék', 1, 25, NULL, 1, '2022-01-29 00:00:00', NULL, '2022-01-29 00:00:00'),
(7, 'Füstölt Edami Sajt', 6240, 'fene van eljön. szemmel reggeli, övék. jól tovább viszont hiszem, eddig Két ember szó ', 5, 'Megrendelésre készül', 'Tejtermék', 3.5, 25, NULL, 1, '2022-01-14 00:00:00', NULL, '2022-01-14 00:00:00'),
(8, 'Finom Brie Sajt', 4010, 'ajtót! tehát évente. idő Féltékeny közé És lesz kövér, tudom a mégis szüleimre, ', 18, 'Azonnal szállítható', 'Tejtermék', 1.25, 22, NULL, 1, '2022-01-14 00:00:00', NULL, '2022-01-14 00:00:00'),
(9, 'Házi Parmezan Sajt', 8620, 'keresztül meleg ebben életforma. értem, tudom Hol az életforma. hónap övék. jól ', 18, 'Azonnal szállítható', 'Tejtermék', 4, 22, NULL, 1, '2022-01-22 00:00:00', NULL, '2022-01-22 00:00:00'),
(10, ' Ementáli Sajt', 7400, 'darabig közé jog tudom szó áldja azon kopog, nem vagyok ', 16, 'Azonnal szállítható', 'Tejtermék', 2.75, 24, NULL, 1, '2022-01-04 00:00:00', NULL, '2022-01-04 00:00:00'),
(11, 'Friss Ementáli Sajt', 610, 'azok néhány koffeinfüggő azon látni, szinte azon Hol őket van ', 15, 'Megrendelésre készül', 'Tejtermék', 3, 25, NULL, 1, '2022-01-01 00:00:00', NULL, '2022-01-01 00:00:00'),
(12, ' Parmezan Sajt', 24960, 'kopog, mint Hol ezzel különböző ezzel szájba vagyok kerül mint őket legtöbb szüleimre, ide? vacsora. szájba ', 24, 'Azonnal szállítható', 'Tejtermék', 2.75, 25, NULL, 1, '2022-01-09 00:00:00', NULL, '2022-01-09 00:00:00'),
(13, 'Füstölt Trapista Sajt', 16640, 'olyan alszom, isten mégis mai fizetek szájba tehát kerültem ember. hiszen kövér, kövér, ', 12, 'Megrendelésre készül', 'Tejtermék', 1.5, 23, NULL, 1, '2022-01-17 00:00:00', NULL, '2022-01-17 00:00:00');

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
(6, 5, 3),
(7, 6, 4),
(8, 6, 10),
(9, 6, 9),
(10, 7, 12),
(11, 6, 8),
(12, 6, 7),
(13, 7, 6),
(14, 7, 13),
(15, 7, 5),
(16, 6, 11);

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
(8, 3, NULL, 'assets/item2.jpg', 0),
(9, 5, NULL, 'assets/product-pictures/cheese1.jpg', 1),
(10, 11, NULL, 'assets/product-pictures/cheese1.jpg', 1),
(11, 12, NULL, 'assets/product-pictures/cheese8.jpg', 0),
(12, 13, NULL, 'assets/product-pictures/cheese8.jpg', 0),
(13, 8, NULL, 'assets/product-pictures/cheese1.jpg', 0),
(14, 12, NULL, 'assets/product-pictures/cheese2.jpg', 0),
(15, 12, NULL, 'assets/product-pictures/cheese3.jpg', 1),
(16, 7, NULL, 'assets/product-pictures/cheese3.jpg', 0),
(17, 4, NULL, 'assets/product-pictures/cheese1.jpg', 0),
(18, 9, NULL, 'assets/product-pictures/cheese9.jpg', 0),
(19, 4, NULL, 'assets/product-pictures/cheese2.jpg', 1),
(20, 10, NULL, 'assets/product-pictures/cheese6.jpg', 1),
(21, 10, NULL, 'assets/product-pictures/cheese3.jpg', 0),
(22, 10, NULL, 'assets/product-pictures/cheese4.jpg', 0),
(23, 11, NULL, 'assets/product-pictures/cheese2.jpg', 0),
(24, 9, NULL, 'assets/product-pictures/cheese5.jpg', 1),
(25, 7, NULL, 'assets/product-pictures/cheese9.jpg', 0),
(26, 8, NULL, 'assets/product-pictures/cheese3.jpg', 1),
(27, 6, NULL, 'assets/product-pictures/cheese1.jpg', 1),
(28, 13, NULL, 'assets/product-pictures/cheese9.jpg', 1),
(29, 7, NULL, 'assets/product-pictures/cheese2.jpg', 1),
(30, 6, NULL, 'assets/product-pictures/cheese5.jpg', 0),
(31, 5, NULL, 'assets/product-pictures/cheese2.jpg', 0);

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
(8, 5, 3),
(9, 8, 10),
(10, 7, 10),
(11, 1, 5),
(12, 8, 5),
(13, 6, 11),
(14, 2, 11),
(15, 6, 9),
(16, 3, 9),
(17, 2, 13),
(18, 5, 13),
(19, 5, 11),
(20, 6, 5),
(21, 1, 13),
(22, 5, 4),
(23, 6, 6),
(24, 3, 8),
(25, 7, 8),
(26, 5, 8),
(27, 3, 6),
(28, 4, 7),
(29, 3, 7),
(30, 8, 6),
(31, 1, 4),
(32, 8, 7),
(33, 6, 12),
(34, 7, 12);

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
(8, 3, 12, 4, 3, 'Szép darab', 'Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom.', '2022-01-11 00:00:00'),
(9, 12, 4, 2, 7, 'szükséges ', 'ütődik. utolsó nem nem Szia, ', '2022-01-09 00:00:00'),
(10, 11, 14, 1, 13, 'most van ', 'felé szemmel mai van sokkal különböző csinálni. legjobb ', '2022-01-01 00:00:00'),
(11, 12, 20, 1, 2, 'szálljon ', 'és lehetőség értem, ebéd ma szemben ', '2022-01-09 00:00:00'),
(12, 11, 16, 5, 1, 'alszom, egy tartoznak ', 'kopog, szálljon azon idő felé alszom, könnyebb lesz eljön. nem szó viszont sem ', '2022-01-01 00:00:00'),
(13, 11, 15, 1, 4, 'soha Féltékeny ', 'szabadságra milyen dolog inkább hogy És ember azt ebéd inkább ', '2022-01-01 00:00:00'),
(14, 11, 9, 5, 2, 'tartoznak ', 'utolsó jól azt egy mondanom, vagyok? ', '2022-01-01 00:00:00'),
(15, 12, 20, 4, 3, 'össze ajtót! ', 'során áll mint lehetőség vagyok hobbijaim látni, eddig során ', '2022-01-09 00:00:00'),
(16, 12, 13, 4, 0, 'Beszélgetek, bumról, ', 'olyan akár mint italért. még terve, nem néhány tartoznak ', '2022-01-09 00:00:00'),
(17, 8, 12, 2, 4, 'mind ', 'Hol dolog életforma. italért. vacsora. teljes ', '2022-01-14 00:00:00'),
(18, 10, 20, 3, 11, 'rendetlenséget! ajtót! ', 'szeret. hozzá jól ezzel tudom jól érdekében hiszem, életforma. ', '2022-01-04 00:00:00'),
(19, 4, 15, 5, 2, 'szó ', 'szeret. viszont mikor szabadságra ebben őket ', '2022-01-28 00:00:00'),
(20, 4, 17, 3, 7, 'és ', 'különböző csukott azt szeret. három ', '2022-01-28 00:00:00'),
(21, 4, 3, 2, 2, 'mint ', 'során soha mikor tovább működik. során ', '2022-01-28 00:00:00'),
(22, 4, 6, 1, 6, 'akár ', 'legjobb elég nem nekem van jog ', '2022-01-28 00:00:00'),
(23, 5, 6, 5, 8, 'csinálni. Hol ', 'amelyek csinálni. szükségem, építsen egy szálljon ebben szép ', '2022-01-09 00:00:00'),
(24, 5, 13, 3, 9, 'nem egy ', 'felé kopog, az. közé mondanom, kétszer mondanom, ', '2022-01-09 00:00:00'),
(25, 6, 20, 1, 8, 'Nem viszont ', 'eljön. hiszem, tudom ebéd évente. szüleimre, italért. tehát ', '2022-01-29 00:00:00'),
(26, 6, 2, 1, 9, 'közé például ', 'kicsit. mint szeret. évente. elég meleg ajtót! azok kerültem szó ', '2022-01-29 00:00:00'),
(27, 6, 20, 1, 2, 'itt ember. ', 'nem ebéd érdekében azt néhány vagyok Úgy ', '2022-01-29 00:00:00'),
(28, 7, 19, 2, 3, 'Hat sem ', 'ide? egy vagyok során kopog, én csinálni. hiszen ezzel szemmel terve, Ha ', '2022-01-14 00:00:00'),
(29, 7, 13, 5, 0, 'egy Szia, ', 'áll azt ebben Szia, viszont csukott vagyok reggeli, elég ', '2022-01-14 00:00:00'),
(30, 7, 12, 5, 13, 'rendetlenséget! ebéd ', 'vacsora. kétszer tehát ide? Féltékeny közé legjobb vacsora. ', '2022-01-14 00:00:00'),
(31, 7, 17, 2, 13, 'Hogy lesz ', 'ezt látni, szemben isten mint mint lehetőség legtöbb a hónap gyerek, ', '2022-01-14 00:00:00'),
(32, 8, 7, 1, 13, 'kicsit. viszont ', 'könnyebb mai a biztos tovább tudom neki ', '2022-01-14 00:00:00'),
(33, 8, 12, 1, 1, 'szemmel Annyira ', 'van életforma. egy sokkal hozzá áll van ', '2022-01-14 00:00:00'),
(34, 8, 7, 1, 6, 'kell keresztül ', 'Egy amíg szálljon tartoznak vagyok egy jog gyengéd koffeinfüggő itt vagyok ', '2022-01-14 00:00:00'),
(35, 13, 14, 2, 5, 'viszont ', 'lehetőség egyetlen egyikük során például ', '2022-01-17 00:00:00'),
(36, 9, 20, 5, 5, 'biztos Szia, ', 'dolog nekem sokkal nem szemben azt szeret. vagyok Isten ', '2022-01-22 00:00:00'),
(37, 9, 4, 5, 0, 'ezzel lesz ', 'egy szemben hozzá csinálni. És Hat kövér, mai ', '2022-01-22 00:00:00'),
(38, 9, 5, 4, 10, 'különböző ', 'a évente. Nagyon mai tovább ', '2022-01-22 00:00:00'),
(39, 9, 13, 2, 7, 'szükséges következő ', 'azok teljes gyengéd azt szinte ma érdekében mikor jól koffeinfüggő Féltékeny tovább ', '2022-01-22 00:00:00'),
(40, 10, 2, 2, 10, 'terve, fene ', 'amíg mely jog Hogy nekem vacsora. soha szükségem, ', '2022-01-04 00:00:00'),
(41, 10, 7, 3, 11, 'elég vagyok ', 'ember együtt a lehetőség szép bumról, lesz szép áldja hiszem, és ', '2022-01-04 00:00:00'),
(42, 10, 6, 3, 2, 'áldja Beszélgetek, ', 'össze keresztül neki megfelelő itt évente. Szia, tudom ', '2022-01-04 00:00:00'),
(43, 13, 5, 1, 14, 'erre mondanom, ', 'hónap tudom következő hónap övék. Mindenkinek vagyok azon ', '2022-01-17 00:00:00');

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

--
-- Dumping data for table `vendor_detail`
--

INSERT INTO `vendor_detail` (`vendor_detail_id`, `member_id`, `company_name`, `site_location`, `website`, `takes_custom_orders`) VALUES
(1, 2, NULL, 'Győrújfalu', 'aranka.hu', 1),
(2, 1, NULL, 'Ménfőcsanak', 'csanakiekszer.hu', 1),
(3, 21, 'PeaceOfMind Csoport', 'Rábcakapi', NULL, 0),
(4, 22, NULL, 'Győrasszonyfa', NULL, 0),
(5, 23, NULL, 'Várbalog', NULL, 0),
(6, 24, 'LightPicture Kft.', 'Feketeerdő', NULL, 0),
(7, 25, NULL, 'Bodonhely', 'horvathsajt.hu', 1);

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
  MODIFY `material_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `member`
--
ALTER TABLE `member`
  MODIFY `member_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `product_material`
--
ALTER TABLE `product_material`
  MODIFY `product_material_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `product_picture`
--
ALTER TABLE `product_picture`
  MODIFY `product_picture_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `product_tag`
--
ALTER TABLE `product_tag`
  MODIFY `product_tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `review`
--
ALTER TABLE `review`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

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
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `vendor_detail`
--
ALTER TABLE `vendor_detail`
  MODIFY `vendor_detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
