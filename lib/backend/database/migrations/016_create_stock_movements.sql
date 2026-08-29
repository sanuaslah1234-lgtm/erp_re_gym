CREATE TABLE IF NOT EXISTS stock_movements (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL DEFAULT 'ADJUSTMENT',
    quantity INTEGER NOT NULL DEFAULT 0,
    reference_no VARCHAR(100),
    remarks TEXT,
    performed_by VARCHAR(100) DEFAULT 'system',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_type ON stock_movements(type);
