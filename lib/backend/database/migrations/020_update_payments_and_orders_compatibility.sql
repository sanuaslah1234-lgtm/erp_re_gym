-- Migration 020: Update payments and POS orders schema compatibility
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Note: payments.id remains SERIAL (integer) — do not try to set UUID default

-- Ensure payments table columns for POS orders
ALTER TABLE payments ADD COLUMN IF NOT EXISTS order_id VARCHAR(100);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) DEFAULT 'cash';
ALTER TABLE payments ADD COLUMN IF NOT EXISTS method VARCHAR(50);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS reference_number VARCHAR(100);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Drop foreign key constraint on pos_order_items if exists
ALTER TABLE pos_order_items DROP CONSTRAINT IF EXISTS pos_order_items_product_id_fkey;

-- Ensure pos_order_items.product_id can store varchar product UUIDs
ALTER TABLE pos_order_items ALTER COLUMN product_id TYPE VARCHAR(100) USING product_id::text;
