-- Migration 015: Add missing columns to users table
-- The auth_repository queries reference columns that were not in the
-- original 002 migration.  This migration adds them safely with IF NOT
-- EXISTS guards so it is idempotent.

-- extra profile fields used by employee_service & auth_repository
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(150);
ALTER TABLE users ADD COLUMN IF NOT EXISTS employee_id VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(50);

-- authentication fields referenced by auth_repository
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS plain_password TEXT;

-- keep the old is_active column in sync: if is_verified was added fresh
-- its default is TRUE, which matches the old is_active default.
-- For any existing rows that had is_active = FALSE, copy that into
-- is_verified so de-activated accounts stay de-activated.
UPDATE users SET is_verified = is_active WHERE is_verified IS DISTINCT FROM is_active;

-- Index for employee-id based lookups (used by findUserByIdentifier)
CREATE INDEX IF NOT EXISTS idx_users_employee_id ON users(employee_id);
