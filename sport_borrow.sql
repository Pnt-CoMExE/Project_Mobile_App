-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 06, 2025 at 12:52 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sport_borrow`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `generate_item_id` (`cat_id` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE cat_code VARCHAR(10);
    DECLARE item_count INT;
    DECLARE new_id VARCHAR(50);
    
    SELECT UPPER(SUBSTRING(category_name, 1, 3)) INTO cat_code
    FROM sport_category WHERE category_id = cat_id;
    
    SELECT COUNT(*) INTO item_count
    FROM sport_item WHERE category_id = cat_id;
    
    SET new_id = CONCAT(cat_code, '-', LPAD(cat_id, 3, '0'), '-', LPAD(item_count + 1, 4, '0'));
    
    RETURN new_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `borrow_request`
--

CREATE TABLE `borrow_request` (
  `request_id` int(11) NOT NULL,
  `student_id` smallint(10) NOT NULL COMMENT 'FK to user.u_id (student ที่ยืม)',
  `item_id` varchar(50) NOT NULL COMMENT 'FK to sport_item.item_id (อุปกรณ์ที่ยืม)',
  `borrow_date` date NOT NULL COMMENT 'วันที่ยืม (วันที่กดยืม)',
  `return_date` date NOT NULL COMMENT 'วันที่ต้องคืน (Today/Tomorrow)',
  `actual_return_date` date DEFAULT NULL COMMENT 'วันที่คืนจริง (staff บันทึก)',
  `request_status` enum('Pending','Approved','Rejected') DEFAULT 'Pending' COMMENT 'สถานะจาก lender',
  `return_status` enum('-','On time','Overdue') DEFAULT '-' COMMENT 'สถานะการคืน: - (ยังไม่คืน), On time (คืนตรงเวลา), Overdue (เลยเวลา)',
  `lender_id` smallint(10) DEFAULT NULL COMMENT 'FK to user.u_id (lender ที่อนุมัติ/ปฏิเสธ)',
  `request_description` text DEFAULT NULL COMMENT 'เหตุผลที่ lender ปฏิเสธ (เมื่อ status = Rejected)',
  `staff_id` smallint(10) DEFAULT NULL COMMENT 'FK to user.u_id (staff ที่กดคืนของ)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `borrow_request`
--

INSERT INTO `borrow_request` (`request_id`, `student_id`, `item_id`, `borrow_date`, `return_date`, `actual_return_date`, `request_status`, `return_status`, `lender_id`, `request_description`, `staff_id`) VALUES
(4, 1, 'BAD-001-0002', '2025-11-05', '2025-11-07', NULL, 'Pending', '-', NULL, NULL, NULL);

--
-- Triggers `borrow_request`
--
DELIMITER $$
CREATE TRIGGER `after_borrow_request_insert` AFTER INSERT ON `borrow_request` FOR EACH ROW BEGIN
    IF NEW.request_status = 'Pending' THEN
        UPDATE sport_item
           SET status = 'Pending'
         WHERE item_id = NEW.item_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_borrow_request_update_status` AFTER UPDATE ON `borrow_request` FOR EACH ROW BEGIN
    -- อนุมัติจาก Pending → อุปกรณ์เป็น Borrowed
    IF NEW.request_status = 'Approved' AND OLD.request_status = 'Pending' THEN
        UPDATE sport_item
           SET status = 'Borrowed'
         WHERE item_id = NEW.item_id;
    END IF;

    -- ปฏิเสธจาก Pending → อุปกรณ์กลับเป็น Available
    IF NEW.request_status = 'Rejected' AND OLD.request_status = 'Pending' THEN
        UPDATE sport_item
           SET status = 'Available'
         WHERE item_id = NEW.item_id;
    END IF;

    -- เมื่อลงวันคืนจริงครั้งแรก → อุปกรณ์กลับเป็น Available
    IF NEW.actual_return_date IS NOT NULL AND OLD.actual_return_date IS NULL THEN
        UPDATE sport_item
           SET status = 'Available'
         WHERE item_id = NEW.item_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_borrow_request_update` BEFORE UPDATE ON `borrow_request` FOR EACH ROW BEGIN
    -- ให้ตั้งค่า return_status เฉพาะตอนที่เปลี่ยนจาก NULL -> มีค่าวันคืนจริงเท่านั้น
    IF NEW.actual_return_date IS NOT NULL AND OLD.actual_return_date IS NULL THEN
        IF NEW.actual_return_date <= NEW.return_date THEN
            SET NEW.return_status = 'On time';
        ELSE
            SET NEW.return_status = 'Overdue';
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `category_status_view`
-- (See below for the actual view)
--
CREATE TABLE `category_status_view` (
`category_id` int(11)
,`category_name` varchar(100)
,`category_image` varchar(255)
,`total_items` bigint(21)
,`available_count` decimal(22,0)
,`borrowed_count` decimal(22,0)
,`pending_count` decimal(22,0)
,`disable_count` decimal(22,0)
,`category_status` varchar(9)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `history_view`
-- (See below for the actual view)
--
CREATE TABLE `history_view` (
`request_id` int(11)
,`student_id` smallint(10)
,`item_image` varchar(255)
,`item_name` varchar(100)
,`category_name` varchar(100)
,`request_status` enum('Pending','Approved','Rejected')
,`borrow_date` date
,`return_date` date
,`actual_return_date` date
,`return_status` enum('-','On time','Overdue')
,`request_description` text
,`staff_id` smallint(10)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `request_result_view`
-- (See below for the actual view)
--
CREATE TABLE `request_result_view` (
`request_id` int(11)
,`student_id` smallint(10)
,`item_image` varchar(255)
,`item_name` varchar(100)
,`category_name` varchar(100)
,`borrow_date` date
,`return_date` date
,`request_status` enum('Pending','Approved','Rejected')
);

-- --------------------------------------------------------

--
-- Table structure for table `sport_category`
--

CREATE TABLE `sport_category` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL COMMENT 'ชื่อประเภทกีฬา เช่น Badminton, Balls, Tennis',
  `category_image` varchar(255) NOT NULL COMMENT 'รูปภาพประเภทกีฬา'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sport_category`
--

INSERT INTO `sport_category` (`category_id`, `category_name`, `category_image`) VALUES
(1, 'Badminton', 'images/badminton.png'),
(2, 'Basketball', 'images/basketball.png'),
(3, 'Petanque', 'images/petanque.png'),
(4, 'Tennis', 'images/tennis.png'),
(5, 'Volleyball', 'images/volleyball.png');

-- --------------------------------------------------------

--
-- Table structure for table `sport_item`
--

CREATE TABLE `sport_item` (
  `item_id` varchar(50) NOT NULL COMMENT 'รหัสอุปกรณ์ เช่น BAD-001-0001',
  `category_id` int(11) NOT NULL COMMENT 'FK เชื่อมกับ sport_category',
  `item_name` varchar(100) NOT NULL COMMENT 'ชื่ออุปกรณ์ เช่น Yonex Badminton Racket',
  `item_image` varchar(255) NOT NULL COMMENT 'รูปภาพอุปกรณ์',
  `status` enum('Available','Borrowed','Pending','Disable') DEFAULT 'Available' COMMENT 'สถานะของอุปกรณ์'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sport_item`
--

INSERT INTO `sport_item` (`item_id`, `category_id`, `item_name`, `item_image`, `status`) VALUES
('BAD-001-0001', 1, 'Racket', 'images/badminton.png', 'Available'),
('BAD-001-0002', 1, 'Shuttle', 'images/shuttle.png', 'Pending'),
('BAL-002-0001', 2, 'Basketball', 'images/basketball.png', 'Available'),
('PET-001-0001', 3, 'Petanque ball', 'images/petanque.png', 'Disable'),
('TEN-003-0001', 4, 'Tennis Racket', 'images/tennis.png', 'Available'),
('VOL-001-0001', 5, 'Volleyball\'s Ball', 'images/volleyball.png', 'Available');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `u_id` smallint(10) NOT NULL,
  `u_username` varchar(20) NOT NULL,
  `u_password` varchar(60) NOT NULL,
  `u_role` smallint(10) NOT NULL COMMENT '1=student, 2=staff, 3=lender'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`u_id`, `u_username`, `u_password`, `u_role`) VALUES
(1, 'student1', '$2b$10$fe0VNm/r7uQn1DOyP9UNpuERY72agdOZk7VPkHcyy1NNktRosFcYe', 1),
(2, 'student2', '$2b$10$MrQd/jpH9VMYY/.9sWrh/O.OGNL/zNuuP.HgOGw95bAyIzxl/cVHO', 1);

-- --------------------------------------------------------

--
-- Structure for view `category_status_view`
--
DROP TABLE IF EXISTS `category_status_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `category_status_view`  AS SELECT `sc`.`category_id` AS `category_id`, `sc`.`category_name` AS `category_name`, `sc`.`category_image` AS `category_image`, count(`si`.`item_id`) AS `total_items`, sum(case when `si`.`status` = 'Available' then 1 else 0 end) AS `available_count`, sum(case when `si`.`status` = 'Borrowed' then 1 else 0 end) AS `borrowed_count`, sum(case when `si`.`status` = 'Pending' then 1 else 0 end) AS `pending_count`, sum(case when `si`.`status` = 'Disable' then 1 else 0 end) AS `disable_count`, CASE WHEN sum(case when `si`.`status` = 'Available' then 1 else 0 end) > 0 THEN 'Available' WHEN sum(case when `si`.`status` = 'Borrowed' then 1 else 0 end) > 0 AND sum(case when `si`.`status` in ('Available','Pending') then 1 else 0 end) = 0 THEN 'Borrowed' WHEN sum(case when `si`.`status` = 'Pending' then 1 else 0 end) > 0 AND sum(case when `si`.`status` in ('Available','Borrowed') then 1 else 0 end) = 0 THEN 'Available' WHEN sum(case when `si`.`status` = 'Disable' then 1 else 0 end) = count(`si`.`item_id`) THEN 'Disable' ELSE 'Available' END AS `category_status` FROM (`sport_category` `sc` left join `sport_item` `si` on(`sc`.`category_id` = `si`.`category_id`)) GROUP BY `sc`.`category_id`, `sc`.`category_name`, `sc`.`category_image` ;

-- --------------------------------------------------------

--
-- Structure for view `history_view`
--
DROP TABLE IF EXISTS `history_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `history_view`  AS SELECT `br`.`request_id` AS `request_id`, `br`.`student_id` AS `student_id`, `si`.`item_image` AS `item_image`, `si`.`item_name` AS `item_name`, `sc`.`category_name` AS `category_name`, `br`.`request_status` AS `request_status`, `br`.`borrow_date` AS `borrow_date`, `br`.`return_date` AS `return_date`, `br`.`actual_return_date` AS `actual_return_date`, `br`.`return_status` AS `return_status`, `br`.`request_description` AS `request_description`, `br`.`staff_id` AS `staff_id` FROM ((`borrow_request` `br` join `sport_item` `si` on(`br`.`item_id` = `si`.`item_id`)) join `sport_category` `sc` on(`si`.`category_id` = `sc`.`category_id`)) WHERE `br`.`request_status` in ('Approved','Rejected') ORDER BY `br`.`request_id` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `request_result_view`
--
DROP TABLE IF EXISTS `request_result_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `request_result_view`  AS SELECT `br`.`request_id` AS `request_id`, `br`.`student_id` AS `student_id`, `si`.`item_image` AS `item_image`, `si`.`item_name` AS `item_name`, `sc`.`category_name` AS `category_name`, `br`.`borrow_date` AS `borrow_date`, `br`.`return_date` AS `return_date`, `br`.`request_status` AS `request_status` FROM ((`borrow_request` `br` join `sport_item` `si` on(`br`.`item_id` = `si`.`item_id`)) join `sport_category` `sc` on(`si`.`category_id` = `sc`.`category_id`)) WHERE `br`.`request_status` = 'Pending' ORDER BY `br`.`request_id` DESC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `borrow_request`
--
ALTER TABLE `borrow_request`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `lender_id` (`lender_id`),
  ADD KEY `staff_id` (`staff_id`);

--
-- Indexes for table `sport_category`
--
ALTER TABLE `sport_category`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `category_name` (`category_name`);

--
-- Indexes for table `sport_item`
--
ALTER TABLE `sport_item`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`u_id`),
  ADD UNIQUE KEY `u_username` (`u_username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `borrow_request`
--
ALTER TABLE `borrow_request`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `sport_category`
--
ALTER TABLE `sport_category`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `u_id` smallint(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `borrow_request`
--
ALTER TABLE `borrow_request`
  ADD CONSTRAINT `borrow_request_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `user` (`u_id`),
  ADD CONSTRAINT `borrow_request_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `sport_item` (`item_id`),
  ADD CONSTRAINT `borrow_request_ibfk_3` FOREIGN KEY (`lender_id`) REFERENCES `user` (`u_id`),
  ADD CONSTRAINT `borrow_request_ibfk_4` FOREIGN KEY (`staff_id`) REFERENCES `user` (`u_id`);

--
-- Constraints for table `sport_item`
--
ALTER TABLE `sport_item`
  ADD CONSTRAINT `sport_item_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `sport_category` (`category_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
