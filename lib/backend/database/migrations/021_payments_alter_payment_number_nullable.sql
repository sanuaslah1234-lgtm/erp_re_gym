-- Migration 021: Make payment_number default or nullable for POS payments
ALTER TABLE payments ALTER COLUMN payment_number DROP NOT NULL;
ALTER TABLE payments ALTER COLUMN payment_number SET DEFAULT ('PAY-' || floor(random() * 9000000 + 1000000)::text);
