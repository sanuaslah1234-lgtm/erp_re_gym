CREATE TABLE IF NOT EXISTS cashier_settings (
    id SERIAL PRIMARY KEY,
    branch_id INT REFERENCES branches(id) ON DELETE SET NULL,
    receipt_header TEXT,
    receipt_footer TEXT,
    print_barcode_on_receipt BOOLEAN DEFAULT TRUE,
    auto_print_receipt BOOLEAN DEFAULT TRUE,
    tax_rate NUMERIC(5,2) DEFAULT 0.00,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS refunds (
    id SERIAL PRIMARY KEY,
    refund_number VARCHAR(50) NOT NULL UNIQUE,
    original_order_id INT REFERENCES sales_orders(id) ON DELETE SET NULL,
    total_refund NUMERIC(12,2) NOT NULL DEFAULT 0,
    reason TEXT,
    processed_by INT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS refund_items (
    id SERIAL PRIMARY KEY,
    refund_id INT NOT NULL REFERENCES refunds(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL,
    refund_amount NUMERIC(12,2) NOT NULL
);
