-- ============================================
-- GLAMOUR STORE - Database Schema
-- IS 2 Project
-- ============================================

CREATE DATABASE IF NOT EXISTS glamour_store;
USE glamour_store;

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('customer', 'admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- CATEGORIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT DEFAULT NULL,
    type ENUM('clothing', 'jewelry') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- ============================================
-- PRODUCTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    category_id INT NOT NULL,
    stock_quantity INT DEFAULT 0,
    image_url VARCHAR(500),
    material VARCHAR(100),
    brand VARCHAR(100),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- ============================================
-- PRODUCT VARIANTS (sizes/colors)
-- ============================================
CREATE TABLE IF NOT EXISTS product_variants (
    variant_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    size VARCHAR(20),
    color VARCHAR(50),
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- ============================================
-- ADDRESSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    street VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    county VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Kenya',
    postal_code VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_id INT,
    total_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    shipping_amount DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE SET NULL
);

-- ============================================
-- ORDER ITEMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id) ON DELETE SET NULL
);

-- ============================================
-- CART TABLE (session-based)
-- ============================================
CREATE TABLE IF NOT EXISTS cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT,
    quantity INT DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id) ON DELETE SET NULL,
    UNIQUE KEY unique_cart_item (user_id, product_id, variant_id)
);

-- ============================================
-- WISHLIST TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_wishlist_item (user_id, product_id)
);

-- ============================================
-- REVIEWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_review (product_id, user_id)
);

-- ============================================
-- COUPONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    max_uses INT DEFAULT NULL,
    used_count INT DEFAULT 0,
    expires_at DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SEED DATA
-- ============================================

-- Categories
INSERT INTO categories (name, description, type) VALUES
('Women Clothing', 'Fashion clothing for women', 'clothing'),
('Men Clothing', 'Fashion clothing for men', 'clothing'),
('Dresses', 'All types of dresses', 'clothing'),
('Tops & Blouses', 'Tops, blouses and shirts', 'clothing'),
('Necklaces', 'Gold, silver and gemstone necklaces', 'jewelry'),
('Earrings', 'Stud, hoop and drop earrings', 'jewelry'),
('Bracelets', 'Bangles, chains and charm bracelets', 'jewelry'),
('Rings', 'Engagement, wedding and fashion rings', 'jewelry');

-- Products
INSERT INTO products (name, description, price, original_price, category_id, stock_quantity, image_url, material, brand, is_featured) VALUES
('Floral Maxi Dress', 'Elegant floral print maxi dress perfect for any occasion', 3500.00, 5000.00, 3, 25, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=400', 'Chiffon', 'Glamour', TRUE),
('Gold Chain Necklace', '18K gold plated chain necklace, 45cm length', 2800.00, NULL, 5, 50, 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400', '18K Gold Plated', 'Luxe Jewels', TRUE),
('Pearl Drop Earrings', 'Classic freshwater pearl drop earrings', 1500.00, 2000.00, 6, 40, 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400', 'Sterling Silver, Pearl', 'Luxe Jewels', TRUE),
('Men''s Slim Fit Blazer', 'Modern slim fit blazer for formal occasions', 6500.00, 8000.00, 2, 15, 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400', 'Polyester Blend', 'ClassicMen', TRUE),
('Silk Blouse', 'Lightweight silk blouse with floral embroidery', 2200.00, NULL, 4, 30, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d253?w=400', '100% Silk', 'Glamour', FALSE),
('Diamond Tennis Bracelet', 'Elegant cubic zirconia tennis bracelet', 4500.00, 6000.00, 7, 20, 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=400', 'Sterling Silver, CZ', 'Luxe Jewels', TRUE),
('Cocktail Dress', 'Chic cocktail dress with lace details', 4200.00, 5500.00, 3, 18, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400', 'Lace, Polyester', 'Glamour', FALSE),
('Gold Hoop Earrings', 'Classic medium gold hoop earrings', 1200.00, NULL, 6, 60, 'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=400', '14K Gold Plated', 'Luxe Jewels', FALSE),
('Men''s Casual Shirt', 'Breathable linen casual shirt', 1800.00, 2500.00, 2, 35, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400', '100% Linen', 'ClassicMen', FALSE),
('Statement Ring', 'Bold statement cocktail ring with gemstones', 950.00, 1500.00, 8, 45, 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400', 'Brass, Gemstone', 'Luxe Jewels', FALSE),
('Wrap Dress', 'Versatile wrap dress in bold print', 3200.00, NULL, 3, 22, 'https://images.unsplash.com/photo-1550639525-c97d455acf70?w=400', 'Jersey', 'Glamour', TRUE),
('Silver Layered Necklace', 'Delicate multi-layer silver necklace set', 2100.00, 3000.00, 5, 38, 'https://images.unsplash.com/photo-1576053139778-7e32f2ae3cfd?w=400', 'Sterling Silver', 'Luxe Jewels', FALSE);

-- Product Variants
INSERT INTO product_variants (product_id, size, color, stock_quantity) VALUES
(1, 'S', 'Blue/Floral', 8), (1, 'M', 'Blue/Floral', 10), (1, 'L', 'Blue/Floral', 7),
(3, NULL, 'White', 20), (3, NULL, 'Rose Gold', 20),
(4, 'S', 'Navy', 5), (4, 'M', 'Navy', 6), (4, 'L', 'Navy', 4),
(5, 'S', 'White', 10), (5, 'M', 'White', 12), (5, 'L', 'White', 8),
(7, 'S', 'Black', 6), (7, 'M', 'Black', 8), (7, 'L', 'Black', 4),
(9, 'S', 'Blue', 10), (9, 'M', 'Blue', 15), (9, 'L', 'Blue', 10),
(11, 'XS', 'Green Print', 5), (11, 'S', 'Green Print', 8), (11, 'M', 'Green Print', 9);

-- Admin user (password: Admin@1234)
INSERT INTO users (first_name, last_name, email, password_hash, role) VALUES
('Admin', 'User', 'admin@glamourstore.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Sample coupon
INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, max_uses, expires_at) VALUES
('WELCOME10', 'percentage', 10.00, 1000.00, 100, '2025-12-31 23:59:59'),
('FLAT500', 'fixed', 500.00, 3000.00, 50, '2025-12-31 23:59:59');
