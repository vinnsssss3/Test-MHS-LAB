-- GachaMerch Database Schema
-- MySQL / MariaDB (XAMPP 8.2.12)
-- Run: mysql -u root < database/schema.sql

CREATE DATABASE IF NOT EXISTS gachamerch
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gachamerch;

-- ─────────────────────────────────────────────
-- Users
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(50)  NOT NULL UNIQUE,
  email          VARCHAR(120) NOT NULL UNIQUE,
  password_hash  VARCHAR(255),
  oauth_provider ENUM('local','google') NOT NULL DEFAULT 'local',
  oauth_sub      VARCHAR(255),
  role           ENUM('user','admin') NOT NULL DEFAULT 'user',
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
-- Items
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS items (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  store       ENUM('honkai_star_retail','genshin_import','wuthering_wares') NOT NULL,
  name        VARCHAR(120) NOT NULL,
  type        VARCHAR(40)  NOT NULL,
  description TEXT         NOT NULL,
  stock       INT          NOT NULL DEFAULT 0,
  image       VARCHAR(255) NOT NULL,
  price       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_items_store (store),
  INDEX idx_items_store_type (store, type),
  CONSTRAINT chk_stock_nn CHECK (stock >= 0),
  CONSTRAINT chk_price_nn CHECK (price >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
-- Purchases
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS purchases (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  item_id     INT NOT NULL,
  store       ENUM('honkai_star_retail','genshin_import','wuthering_wares') NOT NULL,
  quantity    INT NOT NULL,
  unit_price  DECIMAL(12,2) NOT NULL,
  total       DECIMAL(12,2) NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
  INDEX idx_purchases_user (user_id, created_at DESC),
  CONSTRAINT chk_qty_pos CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
