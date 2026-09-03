-- Migration: 019_update_pos_and_payments_schema.sql

-- Create payments table if it doesn't exist (was missing from earlier migrations)
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    payment_number VARCHAR(50),
    order_id VARCHAR(100),
    payment_method VARCHAR(50) NOT NULL DEFAULT 'cash',
    method VARCHAR(50),
    amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    reference_number VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Ensure payments has order_id and payment_method columns
ALTER TABLE payments ADD COLUMN IF NOT EXISTS order_id VARCHAR(100);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) DEFAULT 'cash';
ALTER TABLE payments ADD COLUMN IF NOT EXISTS method VARCHAR(50);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS amount NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS reference_number VARCHAR(100);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_number VARCHAR(50);
UPDATE payments SET payment_method = method WHERE payment_method IS NULL AND method IS NOT NULL;
UPDATE payments SET method = payment_method WHERE method IS NULL AND payment_method IS NOT NULL;

-- Ensure pos_orders exists and has proper columns
CREATE TABLE IF NOT EXISTS pos_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT REFERENCES customers(id),
    cashier_id INT,
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    grand_total NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'paid',
    order_status VARCHAR(30) NOT NULL DEFAULT 'paid',
    amount_received NUMERIC(12,2) NOT NULL DEFAULT 0,
    change_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Ensure pos_order_items exists
CREATE TABLE IF NOT EXISTS pos_order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES pos_orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    quantity NUMERIC(12,3) NOT NULL DEFAULT 1,
    unit_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0
);

-- Ensure barcodes table exists
CREATE TABLE IF NOT EXISTS barcodes (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    barcode VARCHAR(100) NOT NULL,
    label_quantity INT NOT NULL DEFAULT 1,
    created_by INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
