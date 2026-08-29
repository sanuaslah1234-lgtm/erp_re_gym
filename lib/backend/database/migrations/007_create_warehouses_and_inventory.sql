CREATE TABLE IF NOT EXISTS warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(30),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_warehouses_name ON warehouses(name);

CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id INT NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0,
    minimum_stock INTEGER NOT NULL DEFAULT 10,
    maximum_stock INTEGER NOT NULL DEFAULT 1000,
    reorder_level INTEGER NOT NULL DEFAULT 20,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, warehouse_id)
);

CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_warehouse_id ON inventory(warehouse_id);
