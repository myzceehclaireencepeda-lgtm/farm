-- ===========================================
--  Animal Farming Database Schema
--  Compatible with MySQL/MariaDB
-- ===========================================

-- 🏡 Farmlot Ownership Table
CREATE TABLE IF NOT EXISTS `animal_farmlots` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `lot_type` VARCHAR(20) NOT NULL,          -- cow / pig / chicken
    `label` VARCHAR(100) NOT NULL DEFAULT '',
    `coords` LONGTEXT NOT NULL,               -- json coords (vector4)
    `bounds` LONGTEXT NULL,                   -- json bounds (optional)
    `price` INT DEFAULT 0,
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_lot_type` (`lot_type`)
);

-- 🐄 Livestock Data Table
CREATE TABLE IF NOT EXISTS `animal_livestock` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner_cid` VARCHAR(50) NOT NULL,
    `lot_id` INT NOT NULL,
    `animal_type` VARCHAR(20) NOT NULL,       -- cow / pig / chicken
    `gender` ENUM('male','female') NOT NULL,
    `health` FLOAT DEFAULT 100,
    `hunger` FLOAT DEFAULT 100,
    `thirst` FLOAT DEFAULT 100,
    `last_fed` TIMESTAMP NULL DEFAULT NULL,
    `last_watered` TIMESTAMP NULL DEFAULT NULL,
    `last_product` TIMESTAMP NULL DEFAULT NULL, -- last time item produced
    `is_dead` TINYINT(1) DEFAULT 0,
    `spawned` TINYINT(1) DEFAULT 0,           -- whether currently spawned
    `coords` LONGTEXT NULL,                   -- spawn position (JSON vec3)
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_owner_cid` (`owner_cid`),
    INDEX `idx_lot_id` (`lot_id`),
    INDEX `idx_animal_type` (`animal_type`),
    INDEX `idx_is_dead` (`is_dead`),
    FOREIGN KEY (`lot_id`) REFERENCES `animal_farmlots`(`id`) ON DELETE CASCADE
);

-- 🚰 Water Troughs Table
CREATE TABLE IF NOT EXISTS `animal_water_troughs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `lot_id` INT NOT NULL,
    `coords` LONGTEXT NOT NULL,               -- json coords
    `water_level` FLOAT DEFAULT 100,
    `last_refilled` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_lot_id` (`lot_id`),
    FOREIGN KEY (`lot_id`) REFERENCES `animal_farmlots`(`id`) ON DELETE CASCADE
);

-- 💰 Transaction Log Table
CREATE TABLE IF NOT EXISTS `animal_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `type` ENUM('buy_lot', 'buy_animal', 'sell_product', 'butcher') NOT NULL,
    `ref_id` INT NULL,                        -- Reference to lot/animal ID
    `animal_type` VARCHAR(20) NULL,
    `amount` INT DEFAULT 0,                   -- Money amount
    `meta` LONGTEXT NULL,                     -- Additional JSON metadata
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_at` (`created_at`)
);

-- 📦 Production Log Table
CREATE TABLE IF NOT EXISTS `animal_production_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `animal_id` INT NOT NULL,
    `owner_cid` VARCHAR(50) NOT NULL,
    `product` VARCHAR(50) NOT NULL,           -- Item name produced
    `amount` INT DEFAULT 1,
    `quality` INT DEFAULT 100,               -- Quality percentage (0-100)
    `at_health` FLOAT DEFAULT 0,             -- Animal health at time of production
    `at_hunger` FLOAT DEFAULT 0,             -- Animal hunger at time of production
    `at_thirst` FLOAT DEFAULT 0,             -- Animal thirst at time of production
    `produced_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_animal_id` (`animal_id`),
    INDEX `idx_owner_cid` (`owner_cid`),
    INDEX `idx_product` (`product`),
    INDEX `idx_produced_at` (`produced_at`)
);

-- 💀 Animal Death Log Table
CREATE TABLE IF NOT EXISTS `animal_death_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `animal_id` INT NOT NULL,
    `owner_cid` VARCHAR(50) NOT NULL,
    `cause` ENUM('neglect', 'butchered', 'old_age', 'disease', 'accident') NOT NULL,
    `by_cid` VARCHAR(50) NULL,               -- Who caused death (for butchering)
    `yields_json` LONGTEXT NULL,             -- What was gained from death (JSON)
    `skill_level` INT DEFAULT 0,             -- Skill level if butchered
    `died_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_animal_id` (`animal_id`),
    INDEX `idx_owner_cid` (`owner_cid`),
    INDEX `idx_cause` (`cause`),
    INDEX `idx_died_at` (`died_at`)
);

-- 📊 Activity Log Table (Optional - for detailed tracking)
CREATE TABLE IF NOT EXISTS `animal_activity_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `animal_id` INT NOT NULL,
    `owner_cid` VARCHAR(50) NOT NULL,
    `action` ENUM('feed', 'water', 'collect', 'move', 'heal') NOT NULL,
    `details` LONGTEXT NULL,                 -- JSON details about the action
    `action_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_animal_id` (`animal_id`),
    INDEX `idx_owner_cid` (`owner_cid`),
    INDEX `idx_action` (`action`),
    INDEX `idx_action_at` (`action_at`)
);

-- ===========================================
-- Suggested Items for ox_inventory
-- Add these to your items table/config
-- ===========================================

-- 🥕 Feeding Items
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('animal_feed', 'Animal Feed', 100, 0, 1),
('hay_bale', 'Hay Bale', 500, 0, 1),
('corn', 'Corn', 50, 0, 1);

-- 🔪 Tools
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('knife', 'Butcher Knife', 200, 0, 1),
('bucket', 'Water Bucket', 300, 0, 1);

-- 🥩 Animal Products
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('raw_beef', 'Raw Beef', 300, 0, 1),
('raw_pork', 'Raw Pork', 300, 0, 1),
('raw_chicken', 'Raw Chicken', 200, 0, 1),
('milk', 'Fresh Milk', 200, 0, 1),
('eggs', 'Chicken Eggs', 100, 0, 1);

-- 💊 Medicine (Optional)
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('animal_medicine', 'Animal Medicine', 150, 0, 1),
('vitamin_supplement', 'Vitamin Supplement', 100, 0, 1);

-- ===========================================
-- Database Performance Optimizations
-- ===========================================

-- Add composite indexes for common queries
ALTER TABLE `animal_livestock` ADD INDEX `idx_owner_spawned` (`owner_cid`, `spawned`);
ALTER TABLE `animal_livestock` ADD INDEX `idx_lot_alive` (`lot_id`, `is_dead`);
ALTER TABLE `animal_production_log` ADD INDEX `idx_owner_product_date` (`owner_cid`, `product`, `produced_at`);

-- ===========================================
-- Cleanup Procedures (Optional)
-- ===========================================

-- Create a stored procedure to clean old logs (run monthly)
DELIMITER //
CREATE PROCEDURE CleanAnimalFarmingLogs()
BEGIN
    -- Clean activity logs older than 30 days
    DELETE FROM `animal_activity_log` WHERE `action_at` < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Clean production logs older than 90 days
    DELETE FROM `animal_production_log` WHERE `produced_at` < DATE_SUB(NOW(), INTERVAL 90 DAY);
    
    -- Clean transaction logs older than 180 days
    DELETE FROM `animal_transactions` WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 180 DAY);
END//
DELIMITER ;

-- ===========================================
-- Database Views for Analytics (Optional)
-- ===========================================

-- View for animal statistics per player
CREATE OR REPLACE VIEW `animal_player_stats` AS
SELECT 
    l.owner_cid,
    COUNT(*) as total_animals,
    COUNT(CASE WHEN l.is_dead = 0 THEN 1 END) as alive_animals,
    COUNT(CASE WHEN l.is_dead = 1 THEN 1 END) as dead_animals,
    COUNT(CASE WHEN l.animal_type = 'cow' AND l.is_dead = 0 THEN 1 END) as cows,
    COUNT(CASE WHEN l.animal_type = 'chicken' AND l.is_dead = 0 THEN 1 END) as chickens,
    COUNT(CASE WHEN l.animal_type = 'pig' AND l.is_dead = 0 THEN 1 END) as pigs,
    AVG(l.health) as avg_health,
    AVG(l.hunger) as avg_hunger,
    AVG(l.thirst) as avg_thirst
FROM `animal_livestock` l
GROUP BY l.owner_cid;

-- View for production statistics
CREATE OR REPLACE VIEW `animal_production_stats` AS
SELECT 
    p.owner_cid,
    p.product,
    COUNT(*) as total_productions,
    SUM(p.amount) as total_amount,
    AVG(p.quality) as avg_quality,
    MAX(p.produced_at) as last_production
FROM `animal_production_log` p
WHERE p.produced_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY p.owner_cid, p.product;