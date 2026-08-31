-- Ensure suppliers table has all required columns
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS contact_person VARCHAR(255);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS tax_number VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS gst_vat_number VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS supplier_code VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Backfill company_name from name if missing
UPDATE suppliers SET company_name = name WHERE company_name IS NULL AND name IS NOT NULL;
UPDATE suppliers SET name = company_name WHERE name IS NULL AND company_name IS NOT NULL;

-- Generate supplier_code for existing suppliers that don't have one
UPDATE suppliers SET supplier_code = 'SUP-' || id WHERE supplier_code IS NULL;
