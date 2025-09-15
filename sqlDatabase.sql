-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: metro.proxy.rlwy.net    Database: railway
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `categoryID` int NOT NULL AUTO_INCREMENT,
  `categoryName` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `dateAdded` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`categoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'hello','2025-07-02 22:52:55'),(2,'iphones','2025-07-02 22:53:22'),(4,'aaaa100','2025-07-03 09:48:48'),(5,'printer','2025-07-07 20:40:29'),(6,'Scanner','2025-07-21 20:35:19'),(7,'ganesh','2025-07-23 18:13:01'),(9,'australia','2025-07-23 18:25:38'),(10,'computers','2025-09-14 02:22:54'),(11,'mobiles','2025-09-14 02:30:11');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipient` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_general_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'All','hi this is admin!','2025-08-30 08:27:11'),(2,'All','Attention all! this is an emergency call. please listen carefully.','2025-08-30 08:44:18'),(3,'All','this is very important notice! tomorrow is public holiday!','2025-08-30 08:47:21');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `productName` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` int NOT NULL,
  `availability` enum('Yes','No') COLLATE utf8mb4_general_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `warehouseLocation` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `supplierName` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastUpdated` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modifiedBy` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dateAdded` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (5,'scanner 12345',2,'Yes','Scanner','A23','ganesh','2025-07-24 18:20:28','manager','2025-07-22 20:56:52'),(6,'sisa',123,'Yes','printer','g77','pawan','2025-07-23 13:27:35','manager','2025-07-23 13:27:35'),(7,'speaker',12345,'Yes','hello','h78','susank','2025-07-23 13:46:23','manager','2025-07-23 13:46:23'),(8,'pantop',600,'Yes','australia','k90','pawan','2025-07-24 22:31:05','manager','2025-07-23 13:49:13'),(9,'samsunh note A23',1,'Yes','hello','h89','susank','2025-07-24 22:33:28','manager','2025-07-23 15:42:05'),(10,'lenovo ideapad 10',50,'Yes','Scanner','h89','pawan','2025-07-25 08:28:30','manager','2025-07-24 20:00:52'),(12,'plant',123,'Yes','australia','g67','ganesh','2025-07-24 12:51:11','manager','2025-07-24 12:51:11');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin'),(3,'employee'),(2,'manager');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `supplierID` int NOT NULL AUTO_INCREMENT,
  `supplierName` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `categoryID` int NOT NULL,
  `contact` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastOrderDate` date DEFAULT NULL,
  `dateAdded` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`supplierID`),
  KEY `categoryID` (`categoryID`),
  CONSTRAINT `suppliers_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (2,'pawan',1,'987676545','ppp@gmail.com','2025-07-08','2025-07-08 20:14:18'),(3,'susank',4,'123456789','sss@gmail.com','2025-07-07','2025-07-08 20:30:10'),(4,'ganesh',7,'0909089786','ggg@gmail.com','2025-07-24','2025-07-24 18:24:26');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `password` text COLLATE utf8mb4_general_ci NOT NULL,
  `reset_code` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `login_code` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `registration_code` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_verified_email` tinyint(1) DEFAULT '0',
  `is_approved` tinyint(1) NOT NULL DEFAULT '0',
  `first_login` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=167 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (140,'test1','niskarshshrestha@gmail.com','admin','$2y$10$egoEeO/anTF4M4rQiJpvD.gdto/SzZlHGxM2fhsqhfqbo4ZyzVbFy',NULL,NULL,'0915',1,1,1,0),(141,'test2','niskarshshrestha.vu@gmail.com','manager','$2y$10$b7cbO.ltcUpCXUm.qV6Mk.kitdntQXCpW4ce.A2MPmrhXbmk7UIGK',NULL,NULL,'3670',1,1,1,0),(166,'hello','zaynick4@gmail.com','employee','$2y$10$HgLr7zgy1mEFsD6OIspArOJZa4Jn1bEm6jbW2LVJ173CreuDycZ.6',NULL,NULL,'7595',1,1,1,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-15 20:24:51
