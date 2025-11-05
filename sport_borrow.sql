-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 29, 2025 at 06:37 AM
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

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `u_id` smallint(10) NOT NULL AUTO_INCREMENT,
  `u_username` varchar(20) NOT NULL,
  `u_password` varchar(60) NOT NULL,
  `u_role` smallint(10) NOT NULL COMMENT '1=student, 2=staff, 3=lender',
  PRIMARY KEY (`u_id`),
  UNIQUE KEY `u_username` (`u_username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- Table structure for table `sport_category` (ประเภทกีฬา - หน้า Home)
-- --------------------------------------------------------

CREATE TABLE `sport_category` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `category_name` VARCHAR(100) NOT NULL COMMENT 'ชื่อประเภทกีฬา เช่น Badminton, Balls, Tennis',
  `category_image` VARCHAR(255) NOT NULL COMMENT 'รูปภาพประเภทกีฬา',
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `category_name` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- Table structure for table `sport_item` (อุปกรณ์กีฬาแต่ละชิ้น - หน้ารายละเอียด)
-- --------------------------------------------------------

CREATE TABLE `sport_item` (
  `item_id` VARCHAR(50) NOT NULL COMMENT 'รหัสอุปกรณ์ เช่น BAD-001-0001',
  `category_id` INT NOT NULL COMMENT 'FK เชื่อมกับ sport_category',
  `item_name` VARCHAR(100) NOT NULL COMMENT 'ชื่ออุปกรณ์ เช่น Yonex Badminton Racket',
  `item_image` VARCHAR(255) NOT NULL COMMENT 'รูปภาพอุปกรณ์',
  `status` ENUM('Available', 'Borrowed', 'Pending', 'Disable') DEFAULT 'Available' COMMENT 'สถานะของอุปกรณ์',
  PRIMARY KEY (`item_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `sport_item_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `sport_category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- Table structure for table `borrow_request` (คำขอยืม - สำหรับ Request Result และ History)
-- --------------------------------------------------------

CREATE TABLE `borrow_request` (
  `request_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` smallint(10) NOT NULL COMMENT 'FK to user.u_id (student ที่ยืม)',
  `item_id` VARCHAR(50) NOT NULL COMMENT 'FK to sport_item.item_id (อุปกรณ์ที่ยืม)',
  `borrow_date` DATE NOT NULL COMMENT 'วันที่ยืม (วันที่กดยืม)',
  `return_date` DATE NOT NULL COMMENT 'วันที่ต้องคืน (Today/Tomorrow)',
  `actual_return_date` DATE DEFAULT NULL COMMENT 'วันที่คืนจริง (staff บันทึก)',
  `request_status` ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending' COMMENT 'สถานะจาก lender',
  `return_status` ENUM('-', 'On time', 'Overdue') DEFAULT '-' COMMENT 'สถานะการคืน: - (ยังไม่คืน), On time (คืนตรงเวลา), Overdue (เลยเวลา)',
  `lender_id` smallint(10) DEFAULT NULL COMMENT 'FK to user.u_id (lender ที่อนุมัติ/ปฏิเสธ)',
  `request_description` TEXT DEFAULT NULL COMMENT 'เหตุผลที่ lender ปฏิเสธ (เมื่อ status = Rejected)',
  `staff_id` smallint(10) DEFAULT NULL COMMENT 'FK to user.u_id (staff ที่กดคืนของ)',
  PRIMARY KEY (`request_id`),
  KEY `student_id` (`student_id`),
  KEY `item_id` (`item_id`),
  KEY `lender_id` (`lender_id`),
  KEY `staff_id` (`staff_id`),
  CONSTRAINT `borrow_request_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `user` (`u_id`),
  CONSTRAINT `borrow_request_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `sport_item` (`item_id`),
  CONSTRAINT `borrow_request_ibfk_3` FOREIGN KEY (`lender_id`) REFERENCES `user` (`u_id`),
  CONSTRAINT `borrow_request_ibfk_4` FOREIGN KEY (`staff_id`) REFERENCES `user` (`u_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- View: category_status_view (หน้า Home)
-- --------------------------------------------------------

CREATE OR REPLACE VIEW category_status_view AS
SELECT 
    sc.category_id,
    sc.category_name,
    sc.category_image,
    COUNT(si.item_id) AS total_items,
    SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) AS available_count,
    SUM(CASE WHEN si.status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed_count,
    SUM(CASE WHEN si.status = 'Pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN si.status = 'Disable' THEN 1 ELSE 0 END) AS disable_count,
    CASE
        WHEN SUM(CASE WHEN si.status = 'Available' THEN 1 ELSE 0 END) > 0 THEN 'Available'
        WHEN SUM(CASE WHEN si.status = 'Borrowed' THEN 1 ELSE 0 END) > 0 
             AND SUM(CASE WHEN si.status IN ('Available', 'Pending') THEN 1 ELSE 0 END) = 0 THEN 'Borrowed'
        WHEN SUM(CASE WHEN si.status = 'Pending' THEN 1 ELSE 0 END) > 0 
             AND SUM(CASE WHEN si.status IN ('Available', 'Borrowed') THEN 1 ELSE 0 END) = 0 THEN 'Available'
        WHEN SUM(CASE WHEN si.status = 'Disable' THEN 1 ELSE 0 END) = COUNT(si.item_id) THEN 'Disable'
        ELSE 'Available'
    END AS category_status
FROM sport_category sc
LEFT JOIN sport_item si ON sc.category_id = si.category_id
GROUP BY sc.category_id, sc.category_name, sc.category_image;

-- --------------------------------------------------------
-- View: request_result_view (หน้า Request Result - Pending เท่านั้น)
-- --------------------------------------------------------

CREATE OR REPLACE VIEW request_result_view AS
SELECT 
    br.request_id,
    br.student_id,
    si.item_image,
    si.item_name,
    sc.category_name,
    br.borrow_date,
    br.return_date,
    br.request_status
FROM borrow_request br
JOIN sport_item si ON br.item_id = si.item_id
JOIN sport_category sc ON si.category_id = sc.category_id
WHERE br.request_status = 'Pending'
ORDER BY br.request_id DESC;

-- --------------------------------------------------------
-- View: history_view (หน้า History - แสดงทั้ง Approved และ Rejected)
-- --------------------------------------------------------

CREATE OR REPLACE VIEW history_view AS
SELECT 
    br.request_id,
    br.student_id,
    si.item_image,
    si.item_name,
    sc.category_name,
    br.request_status,
    br.borrow_date,
    br.return_date,
    br.actual_return_date,
    br.return_status,
    br.request_description,
    br.staff_id
FROM borrow_request br
JOIN sport_item si ON br.item_id = si.item_id
JOIN sport_category sc ON si.category_id = sc.category_id
WHERE br.request_status IN ('Approved', 'Rejected')
ORDER BY br.request_id DESC;

-- --------------------------------------------------------
-- Triggers
-- --------------------------------------------------------

-- เคลียร์ตัวเก่าให้หมดก่อน (กันชื่อชน)
DROP TRIGGER IF EXISTS after_borrow_request_insert;
DROP TRIGGER IF EXISTS after_borrow_request_update;
DROP TRIGGER IF EXISTS before_borrow_request_update;
DROP TRIGGER IF EXISTS after_borrow_request_update_status;

DELIMITER //

/* 1) INSERT: เมื่อสร้างคำขอยืม Pending → ตัวอุปกรณ์เป็น Pending */
CREATE TRIGGER after_borrow_request_insert
AFTER INSERT ON borrow_request
FOR EACH ROW
BEGIN
    IF NEW.request_status = 'Pending' THEN
        UPDATE sport_item
           SET status = 'Pending'
         WHERE item_id = NEW.item_id;
    END IF;
END;
//

/* 2) BEFORE UPDATE: คำนวณ/ตั้งค่า NEW.return_status ตอนที่กรอก actual_return_date ครั้งแรก */
CREATE TRIGGER before_borrow_request_update
BEFORE UPDATE ON borrow_request
FOR EACH ROW
BEGIN
    -- ให้ตั้งค่า return_status เฉพาะตอนที่เปลี่ยนจาก NULL -> มีค่าวันคืนจริงเท่านั้น
    IF NEW.actual_return_date IS NOT NULL AND OLD.actual_return_date IS NULL THEN
        IF NEW.actual_return_date <= NEW.return_date THEN
            SET NEW.return_status = 'On time';
        ELSE
            SET NEW.return_status = 'Overdue';
        END IF;
    END IF;
END;
//

/* 3) AFTER UPDATE: เปลี่ยนสถานะใน sport_item ตามผลอนุมัติ/ปฏิเสธ และเมื่อคืนของจริง */
CREATE TRIGGER after_borrow_request_update_status
AFTER UPDATE ON borrow_request
FOR EACH ROW
BEGIN
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
END;
//

DELIMITER ;
-- --------------------------------------------------------
-- Function: สร้าง Item ID อัตโนมัติ
-- --------------------------------------------------------

DELIMITER //
CREATE FUNCTION generate_item_id(cat_id INT) 
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE cat_code VARCHAR(10);
    DECLARE item_count INT;
    DECLARE new_id VARCHAR(50);
    
    SELECT UPPER(SUBSTRING(category_name, 1, 3)) INTO cat_code
    FROM sport_category WHERE category_id = cat_id;
    
    SELECT COUNT(*) INTO item_count
    FROM sport_item WHERE category_id = cat_id;
    
    SET new_id = CONCAT(cat_code, '-', LPAD(cat_id, 3, '0'), '-', LPAD(item_count + 1, 4, '0'));
    
    RETURN new_id;
END;//
DELIMITER ;

--
-- Indexes for dumped tables
--

-- Indexes สำหรับ user ถูกกำหนดไว้ในตอนสร้างตารางแล้ว

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `u_id` smallint(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `borrow_request`
--
ALTER TABLE `borrow_request`
  MODIFY `request_id` INT NOT NULL AUTO_INCREMENT;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;