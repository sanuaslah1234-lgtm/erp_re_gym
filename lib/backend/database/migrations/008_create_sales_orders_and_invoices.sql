CREATE TABLE IF NOT EXISTS sales_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_name VARCHAR(150) NOT NULL DEFAULT 'Walk-in Customer',
    customer_id INT REFERENCES customers(id) ON DELETE SET NULL,
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount NUMERIC(12,2) NOT NULL DEFAULT 0,
    tax NUMERIC(12,2) NOT NULL DEFAULT 0,
    total NUMERIC(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    branch_id INT REFERENCES branches(id) ON DELETE SET NULL,
    created_by INT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sales_orders_created_at ON sales_orders(created_at);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer ON sales_orders(customer_name);

CREATE TABLE IF NOT EXISTS sales_order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    subtotal NUMERIC(12,2) NOT NULL
);
