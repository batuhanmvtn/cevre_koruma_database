-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 13, 2025 at 04:48 PM
-- Server version: 5.7.24
-- PHP Version: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cevrevakifdb`
--
CREATE DATABASE IF NOT EXISTS `cevrevakifdb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `cevrevakifdb`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `sp_basHarfUyeBagisBul`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_basHarfUyeBagisBul` (IN `p_basHarf` CHAR(1))   SELECT u.uyeAd, u.uyeSoyad, SUM(b.bagisMiktari) AS
ToplamBagis
FROM uyeler u
JOIN bagislar b ON u.uyeID = b.uyeID
WHERE u.uyeAd LIKE CONCAT(p_basHarf, '%')
GROUP BY u.uyeID, u.uyeAd, u.uyeSoyad
ORDER BY ToplamBagis DESC$$

DROP PROCEDURE IF EXISTS `sp_etkinlikTurleri`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_etkinlikTurleri` ()   SELECT t.turAd, COUNT(et.etkinlikID) AS EtkinlikSayisi
FROM tur t
LEFT JOIN etkinlikTur et ON t.turID = et.turID
GROUP BY t.turAd
ORDER BY EtkinlikSayisi DESC$$

DROP PROCEDURE IF EXISTS `sp_girilenMaastanBuyukYetkililerinProjeleri`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_girilenMaastanBuyukYetkililerinProjeleri` (IN `p_minMaas` DECIMAL(10,2))   SELECT y.yetkiliAd, y.yetkiliSoyad, y.maas, p.projeAd
FROM yetkililer y
JOIN proje_yetkili py ON y.yetkiliID = py.yetkiliID
JOIN projeler p ON py.projeID = p.projeID
WHERE y.maas > p_minMaas
ORDER BY y.maas DESC$$

DROP PROCEDURE IF EXISTS `sp_katilimciSayilari`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_katilimciSayilari` ()   SELECT e.etkinlikAdi, COUNT(k.uyeID) AS KatilimciSayisi
FROM etkinlikler e
LEFT JOIN katilim k ON e.etkinlikID = k.etkinlikID
GROUP BY e.etkinlikAdi
ORDER BY KatilimciSayisi DESC, e.etkinlikAdi$$

DROP PROCEDURE IF EXISTS `sp_ortUstuMaaslar`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ortUstuMaaslar` ()   SELECT yetkiliAd, yetkiliSoyad, pozisyon, maas
FROM yetkililer y
WHERE maas > (SELECT AVG(maas) FROM yetkililer)
ORDER BY maas DESC$$

DROP PROCEDURE IF EXISTS `sp_pozisyondakiYetkililerVeMaaslari`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pozisyondakiYetkililerVeMaaslari` (IN `p_pozisyon` VARCHAR(50))   SELECT y.pozisyon, COUNT(y.yetkiliID) AS YetkiliSayisi, AVG(y.maas) AS OrtMaas
FROM yetkililer y
WHERE y.pozisyon = p_pozisyon
GROUP BY y.pozisyon$$

DROP PROCEDURE IF EXISTS `sp_projeAdiAra`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_projeAdiAra` (IN `p_yazi` VARCHAR(100))   SELECT p.projeAd, y.yetkiliAd, y.yetkiliSoyad, y.pozisyon
FROM projeler p
JOIN proje_yetkili py ON p.projeID = py.projeID
JOIN yetkililer y ON py.yetkiliID = y.yetkiliID
WHERE p.projeAd LIKE CONCAT('%', p_yazi, '%')
ORDER BY p.projeAd$$

DROP PROCEDURE IF EXISTS `sp_projeKonumlariBasTarihleriDesc`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_projeKonumlariBasTarihleriDesc` ()   SELECT p.projeAd AS ProjeAdi, 
p.basTarih AS BaslangicTarihi, 
p.bitTarih AS BitisTarihi, 
k.konumAd AS KonumAdi, 
k.KonumAdres AS KonumAdresi
FROM projeler p
JOIN proje_konum pk ON p.projeID = pk.projeID
JOIN konum k ON pk.konumID = k.konumID
ORDER BY p.basTarih DESC$$

DROP PROCEDURE IF EXISTS `sp_projeKonumVeMaasaGoreYetkiliBul`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_projeKonumVeMaasaGoreYetkiliBul` (IN `p_konumID` INT(11), IN `p_minMaas` DECIMAL(10,2))   SELECT y.yetkiliAd, y.yetkiliSoyad, y.pozisyon, y.maas,
p.projeAd, k.konumAd
FROM yetkililer y
JOIN proje_yetkili py ON y.yetkiliID = py.yetkiliID
JOIN projeler p ON py.projeID = p.projeID
JOIN proje_konum pk ON p.projeID = pk.projeID
JOIN konum k ON pk.konumID = k.konumID
WHERE k.konumID = p_konumID AND y.maas > p_minMaas
ORDER BY y.maas DESC$$

DROP PROCEDURE IF EXISTS `sp_projelerVeYetkilileri`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_projelerVeYetkilileri` ()   SELECT p.projeAd, y.yetkiliAd, y.yetkiliSoyad, y.pozisyon
FROM projeler p
JOIN proje_yetkili py ON p.projeID = py.projeID
JOIN yetkililer y ON py.yetkiliID = y.yetkiliID
ORDER BY p.projeAd$$

DROP PROCEDURE IF EXISTS `sp_projeYetkililerininOrtMaasi`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_projeYetkililerininOrtMaasi` (IN `p_projeID` INT(11))   SELECT p.projeAd AS ProjeAdi, ROUND(AVG(y.maas), 2) AS ProjeYetkilileriOrtalamaMaas
FROM projeler p
JOIN proje_yetkili py ON p.projeID = py.projeID
JOIN yetkililer y ON py.yetkiliID = y.yetkiliID
WHERE p.projeID = p_projeID
GROUP BY p.projeAd$$

DROP PROCEDURE IF EXISTS `sp_turuneGoreKacKatilimci`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_turuneGoreKacKatilimci` (IN `p_turAdi` VARCHAR(150))   SELECT t.turAd, COUNT(DISTINCT k.uyeID) AS ToplamKatilimci
FROM tur t
JOIN etkinlikTur et ON t.turID = et.turID
JOIN katilim k ON et.etkinlikID = k.etkinlikID
WHERE t.turAd = p_turAdi
GROUP BY t.turAd$$

DROP PROCEDURE IF EXISTS `sp_uyeBagislariCoktanAza`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_uyeBagislariCoktanAza` ()   SELECT u.uyeAd, u.uyeSoyad, SUM(b.bagisMiktari) AS ToplamBagis
FROM uyeler u
JOIN bagislar b ON u.uyeID = b.uyeID
GROUP BY u.uyeID, u.uyeAd, u.uyeSoyad
ORDER BY ToplamBagis DESC$$

DROP PROCEDURE IF EXISTS `sp_verilenMiktarUstuBagiscilar`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verilenMiktarUstuBagiscilar` (IN `p_minBagisMiktari` DECIMAL(10,2))   SELECT u.uyeAd, u.uyeSoyad, SUM(b.bagisMiktari) AS ToplamBagis
FROM uyeler u
JOIN bagislar b ON u.uyeID = b.uyeID
GROUP BY u.uyeID, u.uyeAd, u.uyeSoyad
HAVING ToplamBagis >= p_minBagisMiktari
ORDER BY ToplamBagis DESC$$

DROP PROCEDURE IF EXISTS `sp_yetkiliKacEtkinlikte`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_yetkiliKacEtkinlikte` (IN `p_yetkiliID` INT(11))   SELECT y.yetkiliAd, y.yetkiliSoyad, COUNT(ye.etkinlikID) AS YonetilenEtkinlikSayisi
FROM yetkililer y
LEFT JOIN yetkili_etkinlik ye ON y.yetkiliID = ye.yetkiliID
WHERE y.yetkiliID = p_yetkiliID
GROUP BY y.yetkiliAd, y.yetkiliSoyad$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bagislar`
--

DROP TABLE IF EXISTS `bagislar`;
CREATE TABLE `bagislar` (
  `bagisID` int(11) NOT NULL,
  `bagisMiktari` decimal(10,2) DEFAULT NULL,
  `bagisTarihi` date DEFAULT NULL,
  `uyeID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bagislar`
--

INSERT INTO `bagislar` (`bagisID`, `bagisMiktari`, `bagisTarihi`, `uyeID`) VALUES
(1, '1000.00', '2023-02-01', 1),
(2, '25000.50', '2023-04-05', 2),
(3, '5000.00', '2023-06-10', 3),
(4, '50000.00', '2023-09-20', 4),
(5, '7500.25', '2024-01-30', 5),
(6, '1500.00', '2024-03-15', 6),
(7, '3000.00', '2024-05-25', 7),
(8, '1000.00', '2023-06-10', 3);

-- --------------------------------------------------------

--
-- Table structure for table `etkinlikler`
--

DROP TABLE IF EXISTS `etkinlikler`;
CREATE TABLE `etkinlikler` (
  `etkinlikID` int(11) NOT NULL,
  `etkinlikAdi` varchar(150) NOT NULL,
  `basTarih` date NOT NULL,
  `bitTarih` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `etkinlikler`
--

INSERT INTO `etkinlikler` (`etkinlikID`, `etkinlikAdi`, `basTarih`, `bitTarih`) VALUES
(1, 'Surdurulebilir Yasam Semineri', '2024-11-15', '2024-11-15'),
(2, 'Besiktas Fidan Dikimi', '2024-12-05', '2024-12-05'),
(3, 'Kizilay Atik Toplama', '2025-01-10', '2025-01-10'),
(4, 'Deniz Kirliligi Farkindalik Yuruyusu', '2025-03-22', '2025-03-22'),
(5, 'Su Yonetimi Calistayi', '2025-05-01', '2025-05-02'),
(6, 'Besiktas Sahil Temizligi', '2025-06-15', '2025-06-15'),
(7, 'Gonullu Oryantasyon Egitimi', '2025-07-20', '2025-07-20'),
(8, 'Belgrad Ormani Doga Yuruyusu', '2025-08-03', '2025-08-03');

-- --------------------------------------------------------

--
-- Table structure for table `etkinliktur`
--

DROP TABLE IF EXISTS `etkinliktur`;
CREATE TABLE `etkinliktur` (
  `etkinlikID` int(11) NOT NULL,
  `turID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `etkinliktur`
--

INSERT INTO `etkinliktur` (`etkinlikID`, `turID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(6, 3),
(4, 4);

-- --------------------------------------------------------

--
-- Table structure for table `etkinlik_konum`
--

DROP TABLE IF EXISTS `etkinlik_konum`;
CREATE TABLE `etkinlik_konum` (
  `etkinlikID` int(11) NOT NULL,
  `konumID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `etkinlik_konum`
--

INSERT INTO `etkinlik_konum` (`etkinlikID`, `konumID`) VALUES
(6, 1),
(3, 2),
(4, 3),
(2, 4),
(1, 5),
(5, 5),
(7, 5),
(8, 6);

-- --------------------------------------------------------

--
-- Table structure for table `katilim`
--

DROP TABLE IF EXISTS `katilim`;
CREATE TABLE `katilim` (
  `uyeID` int(11) NOT NULL,
  `etkinlikID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `katilim`
--

INSERT INTO `katilim` (`uyeID`, `etkinlikID`) VALUES
(1, 1),
(5, 1),
(3, 2),
(2, 3),
(4, 4),
(7, 5),
(6, 6),
(8, 7);

-- --------------------------------------------------------

--
-- Table structure for table `konum`
--

DROP TABLE IF EXISTS `konum`;
CREATE TABLE `konum` (
  `konumID` int(11) NOT NULL,
  `konumAd` varchar(100) NOT NULL,
  `KonumAdres` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `konum`
--

INSERT INTO `konum` (`konumID`, `konumAd`, `KonumAdres`) VALUES
(1, 'Istanbul Besiktas Merkez', 'Barbaros Bulvari No:100, Besiktas, Istanbul'),
(2, 'Ankara Kizilay Konferans Salonu', 'Ataturk Bulvari No:50, Kizilay, Ankara'),
(3, 'Izmir Goztepe Sahil', 'Mithatpasa Caddesi No:250, Goztepe, Izmir'),
(4, 'Agaclandirma Alani - Polonezkoy', 'Polonezkoy Yolu, Istanbul'),
(5, 'Seminer Salonu - Vakif Merkezi', 'Vakif Caddesi No:1, Merkez, Istanbul'),
(6, 'Doga Yuruyus Parkuru - Belgrad Ormani', 'Neset Suyu Mevkii, Istanbul');

-- --------------------------------------------------------

--
-- Table structure for table `projeler`
--

DROP TABLE IF EXISTS `projeler`;
CREATE TABLE `projeler` (
  `projeID` int(11) NOT NULL,
  `projeAd` varchar(100) NOT NULL,
  `projeAciklama` varchar(250) NOT NULL,
  `basTarih` date NOT NULL,
  `bitTarih` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `projeler`
--

INSERT INTO `projeler` (`projeID`, `projeAd`, `projeAciklama`, `basTarih`, `bitTarih`) VALUES
(1, 'Yesil Gelecek Projesi', 'Sehirlerdeki yesil alanlari artirmaya yonelik uzun soluklu bir proje.', '2023-01-01', '2025-12-31'),
(2, 'Su Kaynaklarini Koruma', 'Yerel su kaynaklarinin temizligini ve surdurulebilirligini saglamayi amaclar.', '2023-05-15', '2024-11-30'),
(3, 'Atik Yonetimi Bilinclendirme', 'Hane halki ve isletmelerde dogru atik ayristirma bilincini olusturma.', '2024-03-01', '2024-10-30'),
(4, 'Gunes Enerjisi Cozumleri', 'Yerel topluluklara yenilenebilir enerji cozumleri sunma pilot projesi.', '2024-06-01', '2025-06-01'),
(5, 'Deniz Temizligi Hareketi', 'Kiyi ve deniz yuzeyi temizligini iceren acil mudhale projesi.', '2024-09-01', '2024-12-31');

-- --------------------------------------------------------

--
-- Table structure for table `proje_konum`
--

DROP TABLE IF EXISTS `proje_konum`;
CREATE TABLE `proje_konum` (
  `konumID` int(11) NOT NULL,
  `projeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `proje_konum`
--

INSERT INTO `proje_konum` (`konumID`, `projeID`) VALUES
(4, 1),
(2, 2),
(1, 3),
(5, 4),
(3, 5);

-- --------------------------------------------------------

--
-- Table structure for table `proje_yetkili`
--

DROP TABLE IF EXISTS `proje_yetkili`;
CREATE TABLE `proje_yetkili` (
  `projeID` int(11) NOT NULL,
  `yetkiliID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `proje_yetkili`
--

INSERT INTO `proje_yetkili` (`projeID`, `yetkiliID`) VALUES
(1, 1),
(2, 1),
(4, 5),
(5, 5),
(3, 6),
(4, 6);

-- --------------------------------------------------------

--
-- Table structure for table `tur`
--

DROP TABLE IF EXISTS `tur`;
CREATE TABLE `tur` (
  `turID` int(11) NOT NULL,
  `turAd` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tur`
--

INSERT INTO `tur` (`turID`, `turAd`) VALUES
(1, 'Seminer'),
(2, 'Fidan Dikimi'),
(3, 'Temizlik Kampanyasi'),
(4, 'Farkindalik Yuruyusu');

-- --------------------------------------------------------

--
-- Table structure for table `uyeler`
--

DROP TABLE IF EXISTS `uyeler`;
CREATE TABLE `uyeler` (
  `uyeID` int(11) NOT NULL,
  `uyeAd` varchar(100) NOT NULL,
  `uyeSoyad` varchar(100) NOT NULL,
  `uyeDogumTarih` date NOT NULL,
  `uyeTC` char(11) NOT NULL,
  `uyeTel` varchar(50) NOT NULL,
  `uyeEmail` varchar(100) NOT NULL,
  `uyelikTarihi` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `uyeler`
--

INSERT INTO `uyeler` (`uyeID`, `uyeAd`, `uyeSoyad`, `uyeDogumTarih`, `uyeTC`, `uyeTel`, `uyeEmail`, `uyelikTarihi`) VALUES
(1, 'Elif', 'Yilmaz', '1995-05-15', '11111111111', '5051111111', 'elif.yilmaz@mail.com', '2023-01-10'),
(2, 'Ahmet', 'Kaya', '1988-11-23', '22222222222', '5322222222', 'ahmet.kaya@mail.com', '2023-03-20'),
(3, 'Zeynep', 'Demir', '2001-07-01', '33333333333', '5443333333', 'zeynep.demir@mail.com', '2023-05-01'),
(4, 'Mehmet', 'Sahin', '1976-02-10', '44444444444', '5554444444', 'mehmet.sahin@mail.com', '2023-08-15'),
(5, 'Ayse', 'Ozturk', '1990-09-28', '55555555555', '5075555555', 'ayse.ozturk@mail.com', '2023-10-05'),
(6, 'Burak', 'Aslan', '1985-04-12', '66666666666', '5426666666', 'burak.aslan@mail.com', '2024-01-25'),
(7, 'Cansu', 'Guler', '1993-01-05', '77777777777', '5337777777', 'cansu.guler@mail.com', '2024-02-14'),
(8, 'Deniz', 'Celik', '1998-12-30', '88888888888', '5548888888', 'deniz.celik@mail.com', '2024-03-10'),
(9, 'Emre', 'Acar', '1980-06-18', '99999999999', '5419999999', 'emre.acar@mail.com', '2024-04-01'),
(10, 'Fatma', 'Yildirim', '1996-03-22', '10000000000', '5060000000', 'fatma.yildirim@mail.com', '2024-05-12');

-- --------------------------------------------------------

--
-- Table structure for table `yetkililer`
--

DROP TABLE IF EXISTS `yetkililer`;
CREATE TABLE `yetkililer` (
  `yetkiliID` int(11) NOT NULL,
  `yetkiliAd` varchar(50) NOT NULL,
  `yetkiliSoyad` varchar(50) NOT NULL,
  `pozisyon` varchar(50) NOT NULL,
  `yetkiliTC` char(11) NOT NULL,
  `maas` decimal(10,2) NOT NULL,
  `yetkiliTel` varchar(15) NOT NULL,
  `yetkiliEmail` varchar(100) NOT NULL,
  `yetkiliDogumT` date NOT NULL,
  `girisTarihi` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `yetkililer`
--

INSERT INTO `yetkililer` (`yetkiliID`, `yetkiliAd`, `yetkiliSoyad`, `pozisyon`, `yetkiliTC`, `maas`, `yetkiliTel`, `yetkiliEmail`, `yetkiliDogumT`, `girisTarihi`) VALUES
(1, 'Ali', 'Korkmaz', 'Proje Koordinatoru', '12345678901', '15000.00', '5301112233', 'ali.korkmaz@vakif.org', '1985-07-20', '2020-09-01'),
(2, 'Selin', 'Ozdemir', 'Etkinlik Yoneticisi', '23456789012', '12000.00', '5402223344', 'selin.ozdemir@vakif.org', '1992-04-10', '2021-03-15'),
(3, 'Can', 'Aksoy', 'Finans Sorumlusu', '34567890123', '13500.00', '5503334455', 'can.aksoy@vakif.org', '1980-01-01', '2022-01-20'),
(4, 'Melis', 'Tunc', 'Iletisim Uzmani', '45678901234', '11000.00', '5384445566', 'melis.tunc@vakif.org', '1995-10-25', '2022-08-01'),
(5, 'Okan', 'Gunes', 'Gonullu Koordinatoru', '56789012345', '10500.00', '5455556677', 'okan.gunes@vakif.org', '1991-03-03', '2023-02-10'),
(6, 'Pinar', 'Kara', 'Proje Asistani', '67890123456', '9000.00', '5396667788', 'pinar.kara@vakif.org', '1995-04-03', '2023-06-05'),
(7, 'Eren', 'Dogan', 'Etkinlik Asistani', '78901234567', '9500.00', '5527778899', 'eren.dogan@vakif.org', '2000-08-08', '2024-01-01'),
(8, 'Gizem', 'Bulut', 'Muhasebe Uzmani', '89012345678', '14000.00', '5318889900', 'gizem.bulut@vakif.org', '1987-05-19', '2021-11-11'),
(9, 'Hakan', 'Erdem', 'IT Destek', '90123456789', '12500.00', '5439990011', 'hakan.erdem@vakif.org', '1994-02-23', '2023-09-01'),
(10, 'Ipek', 'Kurt', 'Hukuk Danismani', '01234567890', '16000.00', '5000001122', 'ipek.kurt@vakif.org', '1983-12-12', '2020-05-01');

-- --------------------------------------------------------

--
-- Table structure for table `yetkili_etkinlik`
--

DROP TABLE IF EXISTS `yetkili_etkinlik`;
CREATE TABLE `yetkili_etkinlik` (
  `etkinlikID` int(11) NOT NULL,
  `yetkiliID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `yetkili_etkinlik`
--

INSERT INTO `yetkili_etkinlik` (`etkinlikID`, `yetkiliID`) VALUES
(1, 2),
(3, 2),
(5, 2),
(2, 5),
(4, 7);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bagislar`
--
ALTER TABLE `bagislar`
  ADD PRIMARY KEY (`bagisID`),
  ADD KEY `fk_uyeID_bagislar` (`uyeID`);

--
-- Indexes for table `etkinlikler`
--
ALTER TABLE `etkinlikler`
  ADD PRIMARY KEY (`etkinlikID`);

--
-- Indexes for table `etkinliktur`
--
ALTER TABLE `etkinliktur`
  ADD PRIMARY KEY (`etkinlikID`,`turID`),
  ADD KEY `fk_turID_etkinlikTur` (`turID`);

--
-- Indexes for table `etkinlik_konum`
--
ALTER TABLE `etkinlik_konum`
  ADD PRIMARY KEY (`etkinlikID`,`konumID`),
  ADD KEY `fk_konumID_etkinlik_konum` (`konumID`);

--
-- Indexes for table `katilim`
--
ALTER TABLE `katilim`
  ADD PRIMARY KEY (`uyeID`,`etkinlikID`),
  ADD KEY `fk_etkinlikID_etkinlik` (`etkinlikID`);

--
-- Indexes for table `konum`
--
ALTER TABLE `konum`
  ADD PRIMARY KEY (`konumID`);

--
-- Indexes for table `projeler`
--
ALTER TABLE `projeler`
  ADD PRIMARY KEY (`projeID`);

--
-- Indexes for table `proje_konum`
--
ALTER TABLE `proje_konum`
  ADD PRIMARY KEY (`konumID`,`projeID`),
  ADD KEY `fk_projeID_proje_konum` (`projeID`);

--
-- Indexes for table `proje_yetkili`
--
ALTER TABLE `proje_yetkili`
  ADD PRIMARY KEY (`projeID`,`yetkiliID`),
  ADD KEY `fk_yetkili_ID` (`yetkiliID`);

--
-- Indexes for table `tur`
--
ALTER TABLE `tur`
  ADD PRIMARY KEY (`turID`);

--
-- Indexes for table `uyeler`
--
ALTER TABLE `uyeler`
  ADD PRIMARY KEY (`uyeID`),
  ADD UNIQUE KEY `uyeTC` (`uyeTC`),
  ADD UNIQUE KEY `uyeTel` (`uyeTel`),
  ADD UNIQUE KEY `uyeEmail` (`uyeEmail`);

--
-- Indexes for table `yetkililer`
--
ALTER TABLE `yetkililer`
  ADD PRIMARY KEY (`yetkiliID`),
  ADD UNIQUE KEY `yetkiliTC` (`yetkiliTC`),
  ADD UNIQUE KEY `yetkiliTel` (`yetkiliTel`),
  ADD UNIQUE KEY `yetkiliEmail` (`yetkiliEmail`);

--
-- Indexes for table `yetkili_etkinlik`
--
ALTER TABLE `yetkili_etkinlik`
  ADD PRIMARY KEY (`etkinlikID`,`yetkiliID`),
  ADD KEY `fk_yetkiliID` (`yetkiliID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bagislar`
--
ALTER TABLE `bagislar`
  MODIFY `bagisID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `etkinlikler`
--
ALTER TABLE `etkinlikler`
  MODIFY `etkinlikID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `konum`
--
ALTER TABLE `konum`
  MODIFY `konumID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `projeler`
--
ALTER TABLE `projeler`
  MODIFY `projeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tur`
--
ALTER TABLE `tur`
  MODIFY `turID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `uyeler`
--
ALTER TABLE `uyeler`
  MODIFY `uyeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `yetkililer`
--
ALTER TABLE `yetkililer`
  MODIFY `yetkiliID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bagislar`
--
ALTER TABLE `bagislar`
  ADD CONSTRAINT `fk_uyeID_bagislar` FOREIGN KEY (`uyeID`) REFERENCES `uyeler` (`uyeID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `etkinliktur`
--
ALTER TABLE `etkinliktur`
  ADD CONSTRAINT `fk_etkinlikID_etkinlikTur` FOREIGN KEY (`etkinlikID`) REFERENCES `etkinlikler` (`etkinlikID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_turID_etkinlikTur` FOREIGN KEY (`turID`) REFERENCES `tur` (`turID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `etkinlik_konum`
--
ALTER TABLE `etkinlik_konum`
  ADD CONSTRAINT `fk_etkinlikID_etkinlik_konum` FOREIGN KEY (`etkinlikID`) REFERENCES `etkinlikler` (`etkinlikID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_konumID_etkinlik_konum` FOREIGN KEY (`konumID`) REFERENCES `konum` (`konumID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `katilim`
--
ALTER TABLE `katilim`
  ADD CONSTRAINT `fk_etkinlikID_etkinlik` FOREIGN KEY (`etkinlikID`) REFERENCES `etkinlikler` (`etkinlikID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_uyeID_uyeler` FOREIGN KEY (`uyeID`) REFERENCES `uyeler` (`uyeID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `proje_konum`
--
ALTER TABLE `proje_konum`
  ADD CONSTRAINT `fk_konumID_proje_konum` FOREIGN KEY (`konumID`) REFERENCES `konum` (`konumID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_projeID_proje_konum` FOREIGN KEY (`projeID`) REFERENCES `projeler` (`projeID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `proje_yetkili`
--
ALTER TABLE `proje_yetkili`
  ADD CONSTRAINT `fk_projeID` FOREIGN KEY (`projeID`) REFERENCES `projeler` (`projeID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_yetkili_ID` FOREIGN KEY (`yetkiliID`) REFERENCES `yetkililer` (`yetkiliID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `yetkili_etkinlik`
--
ALTER TABLE `yetkili_etkinlik`
  ADD CONSTRAINT `fk_etkinlikID` FOREIGN KEY (`etkinlikID`) REFERENCES `etkinlikler` (`etkinlikID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_yetkiliID` FOREIGN KEY (`yetkiliID`) REFERENCES `yetkililer` (`yetkiliID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
