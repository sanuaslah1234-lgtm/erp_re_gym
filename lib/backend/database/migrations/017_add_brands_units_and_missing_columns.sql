-- ============================================================
-- Migration 017: Add missing tables and columns
-- Brands, Units tables + missing columns on categories,
-- products, suppliers, purchases
-- ============================================================

-- BRANDS TABLE
CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name);

-- UNITS TABLE
CREATE TABLE IF NOT EXISTS units (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_units_name ON units(name);

-- CATEGORIES: add missing columns
ALTER TABLE categories ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';
ALTER TABLE categories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- PRODUCTS: add missing columns
ALTER TABLE products ADD COLUMN IF NOT EXISTS sku VARCHAR(100);
ALTER TABLE products ADD COLUMN IF NOT EXISTS brand_id INT REFERENCES brands(id) ON DELETE SET NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS unit_id INT REFERENCES units(id) ON DELETE SET NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS cost_price NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS image VARCHAR(500);
ALTER TABLE products ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';

-- Copy purchase_price -> cost_price for existing products
UPDATE products SET cost_price = purchase_price WHERE cost_price = 0 AND purchase_price > 0;
-- Copy product_code -> sku for existing products
UPDATE products SET sku = product_code WHERE sku IS NULL;
-- Sync is_active -> status
UPDATE products SET status = 'active' WHERE is_active = true AND status = 'active';
UPDATE products SET status = 'inactive' WHERE is_active = false;

-- SUPPLIERS: add missing columns
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS contact_person VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS tax_number VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Backfill company_name from name for existing suppliers
UPDATE suppliers SET company_name = name WHERE company_name IS NULL;

-- PRODUCTS: make product_code nullable (repository inserts via sku column instead)
ALTER TABLE products ALTER COLUMN product_code DROP NOT NULL;

-- PURCHASES: add missing columns
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS notes TEXT;
