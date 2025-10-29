-- setup.sql: create database and users table
CREATE DATABASE IF NOT EXISTS sport_borrow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sport_borrow;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  fullname VARCHAR(255) DEFAULT '',
  role VARCHAR(50) DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
