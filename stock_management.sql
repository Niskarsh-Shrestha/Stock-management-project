-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 03, 2025 at 02:00 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `stock_management`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `categoryID` int(11) NOT NULL,
  `categoryName` varchar(100) NOT NULL,
  `dateAdded` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`categoryID`, `categoryName`, `dateAdded`) VALUES
(1, 'hello', '2025-07-02 22:52:55'),
(2, 'iphones', '2025-07-02 22:53:22'),
(4, 'aaaa', '2025-07-02 23:48:48'),
(5, 'printer', '2025-07-07 20:40:29'),
(6, 'Scanner', '2025-07-21 20:35:19'),
(7, 'ganesh', '2025-07-23 18:13:01'),
(9, 'australia', '2025-07-23 18:25:38');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `recipient` varchar(20) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `recipient`, `message`, `created_at`) VALUES
(1, 'All', 'hi this is admin!', '2025-08-30 08:27:11'),
(2, 'All', 'Attention all! this is an emergency call. please listen carefully.', '2025-08-30 08:44:18'),
(3, 'All', 'this is very important notice! tomorrow is public holiday!', '2025-08-30 08:47:21');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `productName` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL,
  `availability` enum('Yes','No') NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `warehouseLocation` varchar(100) DEFAULT NULL,
  `supplierName` varchar(100) DEFAULT NULL,
  `lastUpdated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `modifiedBy` varchar(100) DEFAULT NULL,
  `dateAdded` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `productName`, `quantity`, `availability`, `category`, `warehouseLocation`, `supplierName`, `lastUpdated`, `modifiedBy`, `dateAdded`) VALUES
(5, 'scanner 12345', 2, 'Yes', 'Scanner', 'A23', 'ganesh', '2025-07-24 18:20:28', 'manager', '2025-07-22 20:56:52'),
(6, 'sisa', 123, 'Yes', 'printer', 'g77', 'pawan', '2025-07-23 13:27:35', 'manager', '2025-07-23 13:27:35'),
(7, 'speaker', 12345, 'Yes', 'hello', 'h78', 'susank', '2025-07-23 13:46:23', 'manager', '2025-07-23 13:46:23'),
(8, 'pantop', 600, 'Yes', 'australia', 'k90', 'pawan', '2025-07-24 22:31:05', 'manager', '2025-07-23 13:49:13'),
(9, 'samsunh note A23', 1, 'Yes', 'hello', 'h89', 'susank', '2025-07-24 22:33:28', 'manager', '2025-07-23 15:42:05'),
(10, 'lenovo ideapad 5', 50, 'Yes', 'Scanner', 'h89', 'pawan', '2025-07-24 22:28:30', 'manager', '2025-07-24 10:00:52'),
(12, 'plant', 123, 'Yes', 'australia', 'g67', 'ganesh', '2025-07-24 12:51:11', 'manager', '2025-07-24 12:51:11');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `role_name`) VALUES
(1, 'admin'),
(3, 'employee'),
(2, 'manager');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `supplierID` int(11) NOT NULL,
  `supplierName` varchar(150) NOT NULL,
  `categoryID` int(11) NOT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `lastOrderDate` date DEFAULT NULL,
  `dateAdded` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`supplierID`, `supplierName`, `categoryID`, `contact`, `email`, `lastOrderDate`, `dateAdded`) VALUES
(2, 'pawan', 1, '987676545', 'ppp@gmail.com', '2025-07-08', '2025-07-08 20:14:18'),
(3, 'susank', 4, '123456789', 'sss@gmail.com', '2025-07-07', '2025-07-08 20:30:10'),
(4, 'ganesh', 7, '0909089786', 'ggg@gmail.com', '2025-07-24', '2025-07-24 18:24:26');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `role` varchar(50) NOT NULL,
  `password` text NOT NULL,
  `reset_code` varchar(10) DEFAULT NULL,
  `login_code` varchar(10) DEFAULT NULL,
  `registration_code` varchar(10) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `is_verified_email` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `role`, `password`, `reset_code`, `login_code`, `registration_code`, `is_verified`, `is_verified_email`) VALUES
(24, 'zaynick', 'zaynick4@gmail.com', 'admin', '$2y$10$hyfAj1cmP8eCSfSxT.xPtOuE88sx61UTWTuhfpPYydeH7ZlEDv7Aq', NULL, NULL, NULL, 1, 0),
(35, 'niskarsh', 'niskarshshrestha@gmail.com', 'manager', '$2y$10$fWEUCODecNahmo8cvcVsLe9FH/jO43Sw1AF6/TYeCKVpIyUICFh7W', NULL, NULL, '9530', 1, 1),
(50, 'sydney', 'niskarshshrestha.vu@gmail.com', 'admin', '$2y$10$nHyjF0.FYTrf5KTLfAZWSuDSO6AtSFcHe2tr8W3sM5m9/BP8JFsxO', NULL, NULL, '6818', 1, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`categoryID`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `role_name` (`role_name`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`supplierID`),
  ADD KEY `categoryID` (`categoryID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `categoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `supplierID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD CONSTRAINT `suppliers_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
