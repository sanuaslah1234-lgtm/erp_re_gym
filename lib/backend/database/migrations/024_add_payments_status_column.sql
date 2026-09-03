-- Migration 024: Add missing columns to payments table
ALTER TABLE payments ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'PAID';
