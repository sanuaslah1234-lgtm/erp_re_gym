CREATE TABLE IF NOT EXISTS dashboard_events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    location VARCHAR(150),
    event_date DATE NOT NULL,
    start_time VARCHAR(20),
    end_time VARCHAR(20),
    accent VARCHAR(20) NOT NULL DEFAULT 'blue',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dashboard_highlights (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    top_performer_name VARCHAR(150),
    top_performer_role VARCHAR(150),
    best_selling_sku_name VARCHAR(200),
    best_selling_sku_category VARCHAR(100),
    best_selling_sku_units INT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dashboard_approvals (
    id SERIAL PRIMARY KEY,
    employee_name VARCHAR(150) NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    role_label VARCHAR(100),
    request_date VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dashboard_notices (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    added_on DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dashboard_todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    due_label VARCHAR(50),
    is_done BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
