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

-- PRODUCTS: add all possible columns first to ensure schema compatibility
ALTER TABLE products ADD COLUMN IF NOT EXISTS product_code VARCHAR(100);
ALTER TABLE products ADD COLUMN IF NOT EXISTS barcode VARCHAR(100);
ALTER TABLE products ADD COLUMN IF NOT EXISTS name VARCHAR(255);
ALTER TABLE products ADD COLUMN IF NOT EXISTS category_id INT REFERENCES categories(id) ON DELETE SET NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS brand_id INT REFERENCES brands(id) ON DELETE SET NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS unit_id INT REFERENCES units(id) ON DELETE SET NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS purchase_price NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS cost_price NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS selling_price NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS tax_percentage NUMERIC(5,2) NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_quantity NUMERIC(12,3) NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS unit VARCHAR(30) NOT NULL DEFAULT 'pcs';
ALTER TABLE products ADD COLUMN IF NOT EXISTS sku VARCHAR(100);
ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS image VARCHAR(500);
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';

-- Safe data sync for products
UPDATE products SET cost_price = purchase_price WHERE cost_price = 0 AND purchase_price > 0;
UPDATE products SET purchase_price = cost_price WHERE purchase_price = 0 AND cost_price > 0;
UPDATE products SET sku = product_code WHERE sku IS NULL AND product_code IS NOT NULL;
UPDATE products SET product_code = sku WHERE product_code IS NULL AND sku IS NOT NULL;
UPDATE products SET status = 'active' WHERE is_active = true AND (status IS NULL OR status = '');
UPDATE products SET status = 'inactive' WHERE is_active = false;
UPDATE products SET is_active = (status = 'active') WHERE status IS NOT NULL;

-- SUPPLIERS: add missing columns
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS name VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS contact_person VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS phone VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS email VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS tax_number VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS gst_vat_number VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Backfill company_name / name for existing suppliers
UPDATE suppliers SET company_name = name WHERE company_name IS NULL AND name IS NOT NULL;
UPDATE suppliers SET name = company_name WHERE name IS NULL AND company_name IS NOT NULL;

-- PRODUCTS: make product_code nullable (repository inserts via sku column instead)
ALTER TABLE products ALTER COLUMN product_code DROP NOT NULL;

-- PURCHASES: add missing columns
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS po_number VARCHAR(50);
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS invoice_number VARCHAR(50);
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(150);
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS total_amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'received';
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) DEFAULT 'paid';
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE purchases ADD COLUMN IF NOT EXISTS notes TEXT;

-- Backfill po_number / invoice_number
UPDATE purchases SET po_number = invoice_number WHERE po_number IS NULL AND invoice_number IS NOT NULL;
UPDATE purchases SET invoice_number = po_number WHERE invoice_number IS NULL AND po_number IS NOT NULL;
