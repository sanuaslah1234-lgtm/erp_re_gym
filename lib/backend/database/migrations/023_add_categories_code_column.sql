-- Migration 023: Add missing code column to categories
ALTER TABLE categories ADD COLUMN IF NOT EXISTS code VARCHAR(100);
