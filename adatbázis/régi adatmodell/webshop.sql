-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 07, 2021 at 03:07 PM
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
-- Database: `webshop`
--
CREATE DATABASE IF NOT EXISTS `webshop` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci;
USE `webshop`;

-- --------------------------------------------------------

--
-- Table structure for table `arus`
--

CREATE TABLE `arus` (
  `arusID` int(11) NOT NULL,
  `nev` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `email` varchar(320) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `jelszo` varchar(64) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `telefonszam` varchar(20) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `bemutatkozas` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `csatlakozas_datuma` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `arus_szamlaja`
--

CREATE TABLE `arus_szamlaja` (
  `szamlaID` int(11) NOT NULL,
  `vasarloID` int(11) DEFAULT NULL,
  `szallitasID` int(11) DEFAULT NULL,
  `arusID` int(11) DEFAULT NULL,
  `aru_osszerteke` int(11) DEFAULT NULL,
  `kiallitas_ideje` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kategoria`
--

CREATE TABLE `kategoria` (
  `kategoriaID` int(11) NOT NULL,
  `megnevezes` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `leiras` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kosar`
--

CREATE TABLE `kosar` (
  `kosarID` int(11) NOT NULL,
  `vasarloID` int(11) DEFAULT NULL,
  `szallitasID` int(11) DEFAULT NULL,
  `vegosszeg` int(11) DEFAULT NULL,
  `statusz` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `fizetesi_forma` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `megrendeles_ideje` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kosar_termek`
--

CREATE TABLE `kosar_termek` (
  `kosarID` int(11) DEFAULT NULL,
  `termekID` int(11) DEFAULT NULL,
  `mennyiseg` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `szallitasi_cim`
--

CREATE TABLE `szallitasi_cim` (
  `szallitasID` int(11) NOT NULL,
  `vasarloID` int(11) DEFAULT NULL,
  `megnevezes` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `telefonszam` varchar(20) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `orszag` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `megye` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `varos` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `utca_hazszam` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `iranyitoszam` varchar(4) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `szamla_termek`
--

CREATE TABLE `szamla_termek` (
  `szamlaID` int(11) DEFAULT NULL,
  `termekID` int(11) DEFAULT NULL,
  `mennyiseg` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `termek`
--

CREATE TABLE `termek` (
  `termekID` int(11) NOT NULL,
  `megnevezes` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `leiras` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `ar` int(11) DEFAULT NULL,
  `mennyiseg_raktaron` int(11) DEFAULT NULL,
  `arusID` int(11) DEFAULT NULL,
  `learazas` int(11) DEFAULT NULL,
  `felvetel_ideje` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `termekfoto`
--

CREATE TABLE `termekfoto` (
  `fotoID` int(11) NOT NULL,
  `link` varchar(200) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `indexkep` tinyint(1) DEFAULT NULL,
  `termekID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `termek_kategoria`
--

CREATE TABLE `termek_kategoria` (
  `termekID` int(11) DEFAULT NULL,
  `kategoriaID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vasarlo`
--

CREATE TABLE `vasarlo` (
  `vasarloID` int(11) NOT NULL,
  `nev` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `email` varchar(320) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `jelszo` varchar(64) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `csatlakozas_datuma` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `arus`
--
ALTER TABLE `arus`
  ADD PRIMARY KEY (`arusID`);

--
-- Indexes for table `arus_szamlaja`
--
ALTER TABLE `arus_szamlaja`
  ADD PRIMARY KEY (`szamlaID`),
  ADD KEY `vasarloID` (`vasarloID`),
  ADD KEY `szallitasID` (`szallitasID`),
  ADD KEY `arusID` (`arusID`);

--
-- Indexes for table `kategoria`
--
ALTER TABLE `kategoria`
  ADD PRIMARY KEY (`kategoriaID`);

--
-- Indexes for table `kosar`
--
ALTER TABLE `kosar`
  ADD PRIMARY KEY (`kosarID`),
  ADD KEY `vasarloID` (`vasarloID`),
  ADD KEY `szallitasID` (`szallitasID`);

--
-- Indexes for table `kosar_termek`
--
ALTER TABLE `kosar_termek`
  ADD PRIMARY KEY `kosar_termekID` (`kosarID`, `termekID`),
  ADD KEY `kosarID` (`kosarID`),
  ADD KEY `termekID` (`termekID`);

--
-- Indexes for table `szallitasi_cim`
--
ALTER TABLE `szallitasi_cim`
  ADD PRIMARY KEY (`szallitasID`),
  ADD KEY `vasarloID` (`vasarloID`);

--
-- Indexes for table `szamla_termek`
--
ALTER TABLE `szamla_termek`
  ADD PRIMARY KEY `szamla_termekID` (`szamlaID`, `termekID`),
  ADD KEY `szamlaID` (`szamlaID`),
  ADD KEY `termekID` (`termekID`);

--
-- Indexes for table `termek`
--
ALTER TABLE `termek`
  ADD PRIMARY KEY (`termekID`),
  ADD KEY `arusID` (`arusID`);

--
-- Indexes for table `termekfoto`
--
ALTER TABLE `termekfoto`
  ADD PRIMARY KEY (`fotoID`),
  ADD KEY `termekID` (`termekID`);

--
-- Indexes for table `termek_kategoria`
--
ALTER TABLE `termek_kategoria`
  ADD PRIMARY KEY `termek_kategoriaID` (`termekID`, `kategoriaID`),
  ADD KEY `termekID` (`termekID`),
  ADD KEY `kategoriaID` (`kategoriaID`);

--
-- Indexes for table `vasarlo`
--
ALTER TABLE `vasarlo`
  ADD PRIMARY KEY (`vasarloID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `arus`
--
ALTER TABLE `arus`
  MODIFY `arusID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `arus_szamlaja`
--
ALTER TABLE `arus_szamlaja`
  MODIFY `szamlaID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kategoria`
--
ALTER TABLE `kategoria`
  MODIFY `kategoriaID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kosar`
--
ALTER TABLE `kosar`
  MODIFY `kosarID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `szallitasi_cim`
--
ALTER TABLE `szallitasi_cim`
  MODIFY `szallitasID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `termek`
--
ALTER TABLE `termek`
  MODIFY `termekID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `termekfoto`
--
ALTER TABLE `termekfoto`
  MODIFY `fotoID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vasarlo`
--
ALTER TABLE `vasarlo`
  MODIFY `vasarloID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `arus_szamlaja`
--
ALTER TABLE `arus_szamlaja`
  ADD CONSTRAINT `arus_szamlaja_ibfk_1` FOREIGN KEY (`vasarloID`) REFERENCES `vasarlo` (`vasarloID`),
  ADD CONSTRAINT `arus_szamlaja_ibfk_2` FOREIGN KEY (`szallitasID`) REFERENCES `szallitasi_cim` (`szallitasID`),
  ADD CONSTRAINT `arus_szamlaja_ibfk_3` FOREIGN KEY (`arusID`) REFERENCES `arus` (`arusID`);

--
-- Constraints for table `kosar`
--
ALTER TABLE `kosar`
  ADD CONSTRAINT `kosar_ibfk_1` FOREIGN KEY (`vasarloID`) REFERENCES `vasarlo` (`vasarloID`),
  ADD CONSTRAINT `kosar_ibfk_2` FOREIGN KEY (`szallitasID`) REFERENCES `szallitasi_cim` (`szallitasID`);

--
-- Constraints for table `kosar_termek`
--
ALTER TABLE `kosar_termek`
  ADD CONSTRAINT `kosar_termek_ibfk_1` FOREIGN KEY (`kosarID`) REFERENCES `kosar` (`kosarID`),
  ADD CONSTRAINT `kosar_termek_ibfk_2` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`);

--
-- Constraints for table `szallitasi_cim`
--
ALTER TABLE `szallitasi_cim`
  ADD CONSTRAINT `szallitasi_cim_ibfk_1` FOREIGN KEY (`vasarloID`) REFERENCES `vasarlo` (`vasarloID`);

--
-- Constraints for table `szamla_termek`
--
ALTER TABLE `szamla_termek`
  ADD CONSTRAINT `szamla_termek_ibfk_1` FOREIGN KEY (`szamlaID`) REFERENCES `arus_szamlaja` (`szamlaID`),
  ADD CONSTRAINT `szamla_termek_ibfk_2` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`);

--
-- Constraints for table `termek`
--
ALTER TABLE `termek`
  ADD CONSTRAINT `termek_ibfk_1` FOREIGN KEY (`arusID`) REFERENCES `arus` (`arusID`);

--
-- Constraints for table `termekfoto`
--
ALTER TABLE `termekfoto`
  ADD CONSTRAINT `termekfoto_ibfk_1` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`);

--
-- Constraints for table `termek_kategoria`
--
ALTER TABLE `termek_kategoria`
  ADD CONSTRAINT `termek_kategoria_ibfk_1` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`),
  ADD CONSTRAINT `termek_kategoria_ibfk_2` FOREIGN KEY (`kategoriaID`) REFERENCES `kategoria` (`kategoriaID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
