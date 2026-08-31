-- Migration 015: Add missing columns to users table
-- The auth_repository queries reference columns that were not in the
-- original 002 migration. This migration adds them safely with IF NOT
-- EXISTS guards so it is idempotent.

-- extra profile fields used by employee_service & auth_repository
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(150);
ALTER TABLE users ADD COLUMN IF NOT EXISTS employee_id VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(50);

-- authentication fields referenced by auth_repository
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS plain_password TEXT;

-- Index for employee-id based lookups (used by findUserByIdentifier)
CREATE INDEX IF NOT EXISTS idx_users_employee_id ON users(employee_id);
