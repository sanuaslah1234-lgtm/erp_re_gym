-- Migration 022: Add missing columns to employees table
ALTER TABLE employees ADD COLUMN IF NOT EXISTS department VARCHAR(100);
ALTER TABLE employees ADD COLUMN IF NOT EXISTS designation VARCHAR(100);
