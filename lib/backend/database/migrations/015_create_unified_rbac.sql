-- Migration 015: Create Unified Role-Based Access Control (RBAC) System

-- 1. Roles Table (UUID string primary key)
CREATE TABLE IF NOT EXISTS roles (
    id VARCHAR(100) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE roles ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE roles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE roles ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_roles_name ON roles(name);

-- 2. Permissions Table
CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    module VARCHAR(20) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_permissions_name ON permissions(name);
CREATE INDEX IF NOT EXISTS idx_permissions_module ON permissions(module);

-- 3. Role-Permissions Join Table (role_id VARCHAR matches roles.id)
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id VARCHAR(100) NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE INDEX IF NOT EXISTS idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_perm ON role_permissions(permission_id);

-- 4. Extend Users Table with role_id Foreign Key
ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id VARCHAR(100) REFERENCES roles(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

-- 5. Seed ERP Permissions (18 Total)
INSERT INTO permissions (name, module, description) VALUES
    ('erp.dashboard.view', 'erp', 'View ERP executive dashboard and analytics'),
    ('erp.users.manage', 'erp', 'Create, update, and manage user accounts'),
    ('erp.roles.manage', 'erp', 'Manage roles and permission bindings'),
    ('erp.employees.manage', 'erp', 'Manage employees, staff records, and designations'),
    ('erp.customers.manage', 'erp', 'Manage retail and business customer CRM records'),
    ('erp.suppliers.manage', 'erp', 'Manage suppliers and vendor contracts'),
    ('erp.products.manage', 'erp', 'Manage product catalog, barcode, and pricing'),
    ('erp.categories.manage', 'erp', 'Manage product categories, brands, and units'),
    ('erp.inventory.manage', 'erp', 'Manage inventory stock levels and movements'),
    ('erp.warehouse.manage', 'erp', 'Manage warehouse locations and bins'),
    ('erp.purchase.manage', 'erp', 'Create and process purchase orders'),
    ('erp.sales.manage', 'erp', 'Create and process sales orders'),
    ('erp.pos.manage', 'erp', 'Access Point of Sale (POS) cashier terminal'),
    ('erp.invoices.manage', 'erp', 'Issue, view, and manage sales invoices'),
    ('erp.payments.manage', 'erp', 'Record, verify, and manage payments'),
    ('erp.reports.view', 'erp', 'Access sales, inventory, and finance reports'),
    ('erp.audit_logs.view', 'erp', 'View system activity and security audit logs'),
    ('erp.settings.manage', 'erp', 'Configure system, branch, and company settings')
ON CONFLICT (name) DO NOTHING;

-- 6. Seed Gym Permissions (11 Total)
INSERT INTO permissions (name, module, description) VALUES
    ('gym.dashboard.view', 'gym', 'View Gym dashboard, metrics, and KPI summaries'),
    ('gym.members.manage', 'gym', 'Manage gym members (register, edit, history)'),
    ('gym.plans.manage', 'gym', 'Manage gym membership tiers and pricing'),
    ('gym.memberships.manage', 'gym', 'Manage gym subscriptions, renewals, and expiries'),
    ('gym.trainers.manage', 'gym', 'Manage gym trainers, specializations, and assignments'),
    ('gym.attendance.manage', 'gym', 'Manage daily member check-ins and attendance logs'),
    ('gym.payments.manage', 'gym', 'Record gym membership payments and receipts'),
    ('gym.workouts.manage', 'gym', 'Create and manage member workout routines'),
    ('gym.schedules.manage', 'gym', 'Manage gym schedules, classes, and trainer timing'),
    ('gym.reports.view', 'gym', 'Access gym member, attendance, and revenue reports'),
    ('gym.settings.manage', 'gym', 'Configure gym module settings')
ON CONFLICT (name) DO NOTHING;

-- 7. Seed System Roles with String UUIDs
INSERT INTO roles (id, name, description) VALUES
    (gen_random_uuid()::text, 'SUPER_ADMIN', 'Full access to all ERP and Gym Management features'),
    (gen_random_uuid()::text, 'ERP_MANAGER', 'Full access to all ERP operations and analytics'),
    (gen_random_uuid()::text, 'ERP_CASHIER', 'Access to POS terminal, invoicing, and payment processing'),
    (gen_random_uuid()::text, 'INVENTORY_MANAGER', 'Access to products, categories, suppliers, inventory, and warehouses'),
    (gen_random_uuid()::text, 'GYM_MANAGER', 'Full access to all Gym operations, trainers, and reports'),
    (gen_random_uuid()::text, 'GYM_RECEPTIONIST', 'Front-desk operations: members, memberships, attendance, and payments'),
    (gen_random_uuid()::text, 'GYM_TRAINER', 'Fitness trainer: assigned members, workout plans, attendance, and schedules')
ON CONFLICT (name) DO NOTHING;

-- 8. Bind Permissions to Roles in role_permissions

-- SUPER_ADMIN & ADMIN (All 29 permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE UPPER(r.name) IN ('SUPER_ADMIN', 'ADMIN')
ON CONFLICT DO NOTHING;

-- ERP_MANAGER / RETAIL_MANAGER / MANAGER (All 18 ERP permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.module = 'erp'
WHERE UPPER(r.name) IN ('ERP_MANAGER', 'RETAIL_MANAGER', 'MANAGER')
ON CONFLICT DO NOTHING;

-- ERP_CASHIER / CASHIER (POS + Payments + Invoices + Sales)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'erp.pos.manage',
    'erp.payments.manage',
    'erp.invoices.manage',
    'erp.sales.manage'
)
WHERE UPPER(r.name) IN ('ERP_CASHIER', 'CASHIER')
ON CONFLICT DO NOTHING;

-- INVENTORY_MANAGER (Inventory + Warehouse + Products + Categories + Suppliers + Purchases)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'erp.inventory.manage',
    'erp.warehouse.manage',
    'erp.products.manage',
    'erp.categories.manage',
    'erp.suppliers.manage',
    'erp.purchase.manage'
)
WHERE UPPER(r.name) = 'INVENTORY_MANAGER'
ON CONFLICT DO NOTHING;

-- GYM_MANAGER (All 11 Gym permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.module = 'gym'
WHERE UPPER(r.name) = 'GYM_MANAGER'
ON CONFLICT DO NOTHING;

-- GYM_RECEPTIONIST / RECEPTIONIST (Dashboard + Members + Memberships + Attendance + Payments)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'gym.dashboard.view',
    'gym.members.manage',
    'gym.memberships.manage',
    'gym.attendance.manage',
    'gym.payments.manage'
)
WHERE UPPER(r.name) IN ('GYM_RECEPTIONIST', 'RECEPTIONIST')
ON CONFLICT DO NOTHING;

-- GYM_TRAINER / TRAINER (Assigned Members + Workouts + Attendance + Schedules)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'gym.members.manage',
    'gym.workouts.manage',
    'gym.attendance.manage',
    'gym.schedules.manage'
)
WHERE UPPER(r.name) IN ('GYM_TRAINER', 'TRAINER')
ON CONFLICT DO NOTHING;

-- STAFF (Front desk basics)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'erp.pos.manage',
    'gym.members.manage',
    'gym.attendance.manage'
)
WHERE UPPER(r.name) = 'STAFF'
ON CONFLICT DO NOTHING;

-- 9. Sync existing users to proper role_id and role name
UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'SUPER_ADMIN' LIMIT 1),
    role = 'SUPER_ADMIN'
WHERE role_id IS NULL AND (UPPER(role) = 'ADMIN' OR UPPER(role) = 'SUPER_ADMIN');

UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'ERP_MANAGER' OR UPPER(name) = 'MANAGER' LIMIT 1),
    role = 'ERP_MANAGER'
WHERE role_id IS NULL AND UPPER(role) = 'MANAGER';

UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'ERP_CASHIER' OR UPPER(name) = 'CASHIER' LIMIT 1),
    role = 'ERP_CASHIER'
WHERE role_id IS NULL AND UPPER(role) = 'CASHIER';

UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'GYM_MANAGER' LIMIT 1),
    role = 'GYM_MANAGER'
WHERE role_id IS NULL AND UPPER(role) = 'GYM_MANAGER';

UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'GYM_TRAINER' OR UPPER(name) = 'TRAINER' LIMIT 1),
    role = 'GYM_TRAINER'
WHERE role_id IS NULL AND UPPER(role) = 'TRAINER';

UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'GYM_RECEPTIONIST' OR UPPER(name) = 'RECEPTIONIST' LIMIT 1),
    role = 'GYM_RECEPTIONIST'
WHERE role_id IS NULL AND UPPER(role) = 'RECEPTIONIST';

UPDATE users 
SET role_id = (SELECT id FROM roles WHERE UPPER(name) = 'STAFF' LIMIT 1),
    role = 'STAFF'
WHERE role_id IS NULL AND UPPER(role) = 'STAFF';
