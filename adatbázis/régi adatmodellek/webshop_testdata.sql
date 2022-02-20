-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2021. Nov 09. 08:27
-- Kiszolgáló verziója: 10.4.6-MariaDB
-- PHP verzió: 7.3.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `webshop`
--
CREATE DATABASE IF NOT EXISTS `webshop` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci;
USE `webshop`;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `arus`
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

--
-- A tábla adatainak kiíratása `arus`
--

INSERT INTO `arus` (`arusID`, `nev`, `email`, `jelszo`, `telefonszam`, `bemutatkozas`, `csatlakozas_datuma`) VALUES
(1, 'Amity Anderson', 'rutrum.lorem@odionaminterdum.org', 'XZO81YRB5ED', '1-210-851-4203', 'ac urna. Ut tincidunt vehicula risus. Nulla', '0000-00-00 00:00:00'),
(2, 'Aquila Cabrera', 'nunc.lectus@proin.ca', 'JQD36DAM3ND', '1-175-545-5833', 'ligula consectetuer rhoncus. Nullam velit', '0000-00-00 00:00:00'),
(3, 'Felix Lloyd', 'donec.felis.orci@nullamscelerisque.ca', 'DMC73JQO4YP', '(723) 432-0154', 'Nunc', '0000-00-00 00:00:00'),
(4, 'Octavius Whitley', 'nunc.mauris@ipsumsuspendisse.org', 'INF74GCI4GW', '1-582-337-4820', 'Vestibulum ante ipsum primis in faucibus', '0000-00-00 00:00:00'),
(5, 'Brianna Moran', 'mauris.ut@eumetusin.net', 'LDL26FKB4BA', '(557) 118-5955', 'in faucibus orci luctus et ultrices posuere', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `arus_szamlaja`
--

CREATE TABLE `arus_szamlaja` (
  `szamlaID` int(11) NOT NULL,
  `vasarloID` int(11) DEFAULT NULL,
  `szallitasID` int(11) DEFAULT NULL,
  `arusID` int(11) DEFAULT NULL,
  `aru_osszerteke` int(11) DEFAULT NULL,
  `kiallitas_ideje` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `arus_szamlaja`
--

INSERT INTO `arus_szamlaja` (`szamlaID`, `vasarloID`, `szallitasID`, `arusID`, `aru_osszerteke`, `kiallitas_ideje`) VALUES
(1, 2, 3, 5, 52529, '0000-00-00 00:00:00'),
(2, 3, 3, 1, 70155, '0000-00-00 00:00:00'),
(3, 5, 1, 2, 8526, '0000-00-00 00:00:00'),
(4, 3, 5, 5, 21532, '0000-00-00 00:00:00'),
(5, 2, 4, 4, 96946, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kategoria`
--

CREATE TABLE `kategoria` (
  `kategoriaID` int(11) NOT NULL,
  `megnevezes` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `leiras` text COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `kategoria`
--

INSERT INTO `kategoria` (`kategoriaID`, `megnevezes`, `leiras`) VALUES
(1, 'Pékáru', 'fermentum risus, at fringilla purus mauris a nunc. In at pede. Cras vulputate velit eu sem. Pellentesque ut ipsum'),
(2, 'Zöldség, gyümölcs', 'condimentum eget, volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing ligula. Aenean gravida nunc sed pede. Cum sociis natoque penatibus et magnis dis'),
(3, 'Hús, hal', 'orci tincidunt adipiscing. Mauris molestie pharetra nibh. Aliquam ornare, libero at auctor ullamcorper, nisl arcu'),
(4, 'Tejtermék', 'diam. Sed diam lorem, auctor quis, tristique ac, eleifend vitae, erat. Vivamus'),
(5, 'Italok', 'dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kosar`
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

--
-- A tábla adatainak kiíratása `kosar`
--

INSERT INTO `kosar` (`kosarID`, `vasarloID`, `szallitasID`, `vegosszeg`, `statusz`, `fizetesi_forma`, `megrendeles_ideje`) VALUES
(1, 4, 3, 30727, 'parturient', 'tempus', '0000-00-00 00:00:00'),
(2, 5, 1, 45459, 'Nullam', 'lobortis', '0000-00-00 00:00:00'),
(3, 1, 3, 45303, 'lacus.', 'Nunc', '0000-00-00 00:00:00'),
(4, 2, 2, 52798, 'Aenean', 'tempus', '0000-00-00 00:00:00'),
(5, 1, 2, 65752, 'semper', 'feugiat.', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kosar_termek`
--

CREATE TABLE `kosar_termek` (
  `kosarID` int(11) NOT NULL,
  `termekID` int(11) NOT NULL,
  `mennyiseg` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `kosar_termek`
--

INSERT INTO `kosar_termek` (`kosarID`, `termekID`, `mennyiseg`) VALUES
(1, 3, 39),
(3, 3, 31),
(3, 4, 5),
(5, 1, 31),
(5, 2, 4);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `szallitasi_cim`
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

--
-- A tábla adatainak kiíratása `szallitasi_cim`
--

INSERT INTO `szallitasi_cim` (`szallitasID`, `vasarloID`, `megnevezes`, `telefonszam`, `orszag`, `megye`, `varos`, `utca_hazszam`, `iranyitoszam`) VALUES
(1, 5, 'mollis.', '1-515-414-6243', 'Germany', 'Phú Thọ', 'Develi', 'P.O. Box 703, 2944 Vulputate Road', '9186'),
(2, 3, 'sed', '1-177-255-9675', 'France', 'Caquetá', 'Niort', 'Ap #160-5600 Vitae Rd.', '5152'),
(3, 5, 'convallis', '(418) 222-8675', 'France', 'South Island', 'Wals-Siezenheim', 'P.O. Box 692, 3683 Tempor Rd.', '3872'),
(4, 2, 'lacus.', '(367) 883-2825', 'China', 'Poitou-Charentes', 'Sudhanoti', 'P.O. Box 558, 6486 Quam St.', 'G6H '),
(5, 3, 'egestas', '(801) 951-1405', 'Italy', 'Dalarnas län', 'Paillaco', 'Ap #513-3835 Dui St.', '5321');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `szamla_termek`
--

CREATE TABLE `szamla_termek` (
  `szamlaID` int(11) NOT NULL,
  `termekID` int(11) NOT NULL,
  `mennyiseg` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `szamla_termek`
--

INSERT INTO `szamla_termek` (`szamlaID`, `termekID`, `mennyiseg`) VALUES
(1, 5, 20),
(3, 1, 11),
(3, 2, 30),
(3, 3, 1),
(3, 4, 7);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `termek`
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

--
-- A tábla adatainak kiíratása `termek`
--

INSERT INTO `termek` (`termekID`, `megnevezes`, `leiras`, `ar`, `mennyiseg_raktaron`, `arusID`, `learazas`, `felvetel_ideje`) VALUES
(1, 'eu dolor', 'commodo tincidunt', 73673, 29, 1, 50, '0000-00-00 00:00:00'),
(2, 'ornare lectus', 'nec tempus scelerisque,', 40003, 205, 2, 20, '0000-00-00 00:00:00'),
(3, 'enim, condimentum', 'varius. Nam porttitor scelerisque', 13251, 40, 4, 10, '0000-00-00 00:00:00'),
(4, 'et ipsum', 'magna sed dui. Fusce aliquam, enim nec', 6669, 235, 1, 0, '0000-00-00 00:00:00'),
(5, 'sem ut', 'Suspendisse sed dolor. Fusce', 29319, 230, 3, 10, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `termekfoto`
--

CREATE TABLE `termekfoto` (
  `fotoID` int(11) NOT NULL,
  `link` varchar(200) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `indexkep` tinyint(1) DEFAULT NULL,
  `termekID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `termekfoto`
--

INSERT INTO `termekfoto` (`fotoID`, `link`, `indexkep`, `termekID`) VALUES
(1, 'XVN69OHI5WQ', 0, 1),
(2, 'SDD05YDF4VV', 1, 3),
(3, 'MDE01HMM2GZ', 0, 3),
(4, 'MNS21TLW2QV', 1, 1),
(5, 'OOS45QRM3ST', 1, 2);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `termek_kategoria`
--

CREATE TABLE `termek_kategoria` (
  `termekID` int(11) NOT NULL,
  `kategoriaID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `termek_kategoria`
--

INSERT INTO `termek_kategoria` (`termekID`, `kategoriaID`) VALUES
(1, 2),
(1, 3),
(2, 2),
(4, 3),
(5, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `vasarlo`
--

CREATE TABLE `vasarlo` (
  `vasarloID` int(11) NOT NULL,
  `nev` varchar(50) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `email` varchar(320) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `jelszo` varchar(64) COLLATE utf8mb4_hungarian_ci DEFAULT NULL,
  `csatlakozas_datuma` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `vasarlo`
--

INSERT INTO `vasarlo` (`vasarloID`, `nev`, `email`, `jelszo`, `csatlakozas_datuma`) VALUES
(1, 'Kane Gonzales', 'aliquam.eros@turpisnec.net', 'NST16DMC1OQ', '0000-00-00 00:00:00'),
(2, 'Vernon Hewitt', 'molestie.sodales@natoquepenatibuset.co.uk', 'KNP01PRN6AV', '0000-00-00 00:00:00'),
(3, 'Dara Freeman', 'metus.in@namac.co.uk', 'RHF39JQC2GE', '0000-00-00 00:00:00'),
(4, 'Garrett Haney', 'molestie.tortor.nibh@tortornunccommodo.com', 'WJT15VKJ5FC', '0000-00-00 00:00:00'),
(5, 'Evelyn Blackwell', 'turpis.vitae@consectetuer.com', 'EDM82OCP9MQ', '0000-00-00 00:00:00');

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `arus`
--
ALTER TABLE `arus`
  ADD PRIMARY KEY (`arusID`);

--
-- A tábla indexei `arus_szamlaja`
--
ALTER TABLE `arus_szamlaja`
  ADD PRIMARY KEY (`szamlaID`),
  ADD KEY `vasarloID` (`vasarloID`),
  ADD KEY `szallitasID` (`szallitasID`),
  ADD KEY `arusID` (`arusID`);

--
-- A tábla indexei `kategoria`
--
ALTER TABLE `kategoria`
  ADD PRIMARY KEY (`kategoriaID`);

--
-- A tábla indexei `kosar`
--
ALTER TABLE `kosar`
  ADD PRIMARY KEY (`kosarID`),
  ADD KEY `vasarloID` (`vasarloID`),
  ADD KEY `szallitasID` (`szallitasID`);

--
-- A tábla indexei `kosar_termek`
--
ALTER TABLE `kosar_termek`
  ADD PRIMARY KEY (`kosarID`,`termekID`),
  ADD KEY `kosarID` (`kosarID`),
  ADD KEY `termekID` (`termekID`);

--
-- A tábla indexei `szallitasi_cim`
--
ALTER TABLE `szallitasi_cim`
  ADD PRIMARY KEY (`szallitasID`),
  ADD KEY `vasarloID` (`vasarloID`);

--
-- A tábla indexei `szamla_termek`
--
ALTER TABLE `szamla_termek`
  ADD PRIMARY KEY (`szamlaID`,`termekID`),
  ADD KEY `szamlaID` (`szamlaID`),
  ADD KEY `termekID` (`termekID`);

--
-- A tábla indexei `termek`
--
ALTER TABLE `termek`
  ADD PRIMARY KEY (`termekID`),
  ADD KEY `arusID` (`arusID`);

--
-- A tábla indexei `termekfoto`
--
ALTER TABLE `termekfoto`
  ADD PRIMARY KEY (`fotoID`),
  ADD KEY `termekID` (`termekID`);

--
-- A tábla indexei `termek_kategoria`
--
ALTER TABLE `termek_kategoria`
  ADD PRIMARY KEY (`termekID`,`kategoriaID`),
  ADD KEY `termekID` (`termekID`),
  ADD KEY `kategoriaID` (`kategoriaID`);

--
-- A tábla indexei `vasarlo`
--
ALTER TABLE `vasarlo`
  ADD PRIMARY KEY (`vasarloID`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `arus`
--
ALTER TABLE `arus`
  MODIFY `arusID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `arus_szamlaja`
--
ALTER TABLE `arus_szamlaja`
  MODIFY `szamlaID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `kategoria`
--
ALTER TABLE `kategoria`
  MODIFY `kategoriaID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `kosar`
--
ALTER TABLE `kosar`
  MODIFY `kosarID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `szallitasi_cim`
--
ALTER TABLE `szallitasi_cim`
  MODIFY `szallitasID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `termek`
--
ALTER TABLE `termek`
  MODIFY `termekID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `termekfoto`
--
ALTER TABLE `termekfoto`
  MODIFY `fotoID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `vasarlo`
--
ALTER TABLE `vasarlo`
  MODIFY `vasarloID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `arus_szamlaja`
--
ALTER TABLE `arus_szamlaja`
  ADD CONSTRAINT `arus_szamlaja_ibfk_1` FOREIGN KEY (`vasarloID`) REFERENCES `vasarlo` (`vasarloID`),
  ADD CONSTRAINT `arus_szamlaja_ibfk_2` FOREIGN KEY (`szallitasID`) REFERENCES `szallitasi_cim` (`szallitasID`),
  ADD CONSTRAINT `arus_szamlaja_ibfk_3` FOREIGN KEY (`arusID`) REFERENCES `arus` (`arusID`);

--
-- Megkötések a táblához `kosar`
--
ALTER TABLE `kosar`
  ADD CONSTRAINT `kosar_ibfk_1` FOREIGN KEY (`vasarloID`) REFERENCES `vasarlo` (`vasarloID`),
  ADD CONSTRAINT `kosar_ibfk_2` FOREIGN KEY (`szallitasID`) REFERENCES `szallitasi_cim` (`szallitasID`);

--
-- Megkötések a táblához `kosar_termek`
--
ALTER TABLE `kosar_termek`
  ADD CONSTRAINT `kosar_termek_ibfk_1` FOREIGN KEY (`kosarID`) REFERENCES `kosar` (`kosarID`),
  ADD CONSTRAINT `kosar_termek_ibfk_2` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`);

--
-- Megkötések a táblához `szallitasi_cim`
--
ALTER TABLE `szallitasi_cim`
  ADD CONSTRAINT `szallitasi_cim_ibfk_1` FOREIGN KEY (`vasarloID`) REFERENCES `vasarlo` (`vasarloID`);

--
-- Megkötések a táblához `szamla_termek`
--
ALTER TABLE `szamla_termek`
  ADD CONSTRAINT `szamla_termek_ibfk_1` FOREIGN KEY (`szamlaID`) REFERENCES `arus_szamlaja` (`szamlaID`),
  ADD CONSTRAINT `szamla_termek_ibfk_2` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`);

--
-- Megkötések a táblához `termek`
--
ALTER TABLE `termek`
  ADD CONSTRAINT `termek_ibfk_1` FOREIGN KEY (`arusID`) REFERENCES `arus` (`arusID`);

--
-- Megkötések a táblához `termekfoto`
--
ALTER TABLE `termekfoto`
  ADD CONSTRAINT `termekfoto_ibfk_1` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`);

--
-- Megkötések a táblához `termek_kategoria`
--
ALTER TABLE `termek_kategoria`
  ADD CONSTRAINT `termek_kategoria_ibfk_1` FOREIGN KEY (`termekID`) REFERENCES `termek` (`termekID`),
  ADD CONSTRAINT `termek_kategoria_ibfk_2` FOREIGN KEY (`kategoriaID`) REFERENCES `kategoria` (`kategoriaID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
