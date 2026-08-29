CREATE TABLE IF NOT EXISTS business_settings (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    company_name VARCHAR(150) NOT NULL,
    tax_id VARCHAR(50),
    currency VARCHAR(10) DEFAULT 'KWD',
    timezone VARCHAR(50) DEFAULT 'Asia/Kuwait',
    logo_url TEXT,
    contact_email VARCHAR(150),
    contact_phone VARCHAR(50),
    address TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS landing_page_settings (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    hero_title VARCHAR(200) NOT NULL DEFAULT 'Welcome to ERP System',
    hero_subtitle TEXT,
    hero_image_url TEXT,
    about_text TEXT,
    features_json TEXT,
    contact_email VARCHAR(150),
    contact_phone VARCHAR(50),
    facebook_url TEXT,
    twitter_url TEXT,
    instagram_url TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
