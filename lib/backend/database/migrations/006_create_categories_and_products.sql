CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    barcode VARCHAR(100) UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id INT REFERENCES categories(id) ON DELETE SET NULL,
    purchase_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    selling_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    tax_percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
    stock_quantity NUMERIC(12,3) NOT NULL DEFAULT 0,
    unit VARCHAR(30) NOT NULL DEFAULT 'pcs',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_product_code ON products(product_code);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
