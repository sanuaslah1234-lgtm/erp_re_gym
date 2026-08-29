-- Migration 014: Create Gym Management Module Tables


-- ============================================================
-- 1. GYM MEMBERSHIP PLANS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_membership_plans (
    id SERIAL PRIMARY KEY,

    name VARCHAR(150) NOT NULL,
    description TEXT,

    duration_days INT NOT NULL DEFAULT 30,

    price NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    tax NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_plans_status
ON gym_membership_plans(status);


-- ============================================================
-- 2. GYM MEMBERS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_members (
    id SERIAL PRIMARY KEY,

    member_code VARCHAR(50) UNIQUE NOT NULL,

    -- FIXED: customers.id is INTEGER
    customer_id INT
        REFERENCES customers(id)
        ON DELETE SET NULL,

    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255),

    gender VARCHAR(20),
    date_of_birth DATE,

    address TEXT,
    emergency_contact VARCHAR(100),

    join_date DATE NOT NULL DEFAULT CURRENT_DATE,

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    photo TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_members_code
ON gym_members(member_code);

CREATE INDEX IF NOT EXISTS idx_gym_members_phone
ON gym_members(phone);

CREATE INDEX IF NOT EXISTS idx_gym_members_status
ON gym_members(status);

CREATE INDEX IF NOT EXISTS idx_gym_members_customer_id
ON gym_members(customer_id);


-- ============================================================
-- 3. GYM MEMBERSHIPS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_memberships (
    id SERIAL PRIMARY KEY,

    member_id INT NOT NULL
        REFERENCES gym_members(id)
        ON DELETE CASCADE,

    plan_id INT NOT NULL
        REFERENCES gym_membership_plans(id)
        ON DELETE RESTRICT,

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    tax NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    final_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    auto_renew BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_memberships_member
ON gym_memberships(member_id);

CREATE INDEX IF NOT EXISTS idx_gym_memberships_dates
ON gym_memberships(start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_gym_memberships_status
ON gym_memberships(status);


-- ============================================================
-- 4. GYM TRAINERS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_trainers (
    id SERIAL PRIMARY KEY,

    employee_id INT UNIQUE
        REFERENCES employees(id)
        ON DELETE CASCADE,

    name VARCHAR(150),
    phone VARCHAR(50),
    email VARCHAR(255),

    specialization VARCHAR(255) NOT NULL,
    experience VARCHAR(100),

    salary NUMERIC(12,2) DEFAULT 0.00,

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_trainers_status
ON gym_trainers(status);


-- ============================================================
-- 5. TRAINER ASSIGNMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_trainer_assignments (
    id SERIAL PRIMARY KEY,

    member_id INT NOT NULL
        REFERENCES gym_members(id)
        ON DELETE CASCADE,

    trainer_id INT NOT NULL
        REFERENCES gym_trainers(id)
        ON DELETE CASCADE,

    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_trainer_assign_member
ON gym_trainer_assignments(member_id);

CREATE INDEX IF NOT EXISTS idx_gym_trainer_assign_trainer
ON gym_trainer_assignments(trainer_id);


-- ============================================================
-- 6. GYM ATTENDANCE
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_attendance (
    id SERIAL PRIMARY KEY,

    member_id INT NOT NULL
        REFERENCES gym_members(id)
        ON DELETE CASCADE,

    attendance_date DATE NOT NULL DEFAULT CURRENT_DATE,

    check_in TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_out TIMESTAMP,

    status VARCHAR(50) NOT NULL DEFAULT 'PRESENT',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_attendance_member
ON gym_attendance(member_id);

CREATE INDEX IF NOT EXISTS idx_gym_attendance_date
ON gym_attendance(attendance_date);


-- ============================================================
-- 7. GYM PAYMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_payments (
    id SERIAL PRIMARY KEY,

    member_id INT NOT NULL
        REFERENCES gym_members(id)
        ON DELETE CASCADE,

    membership_id INT
        REFERENCES gym_memberships(id)
        ON DELETE SET NULL,

    -- IMPORTANT:
    -- This assumes sales_orders.id is INTEGER/SERIAL.
    invoice_id INT
        REFERENCES sales_orders(id)
        ON DELETE SET NULL,

    amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,

    payment_method VARCHAR(50) NOT NULL DEFAULT 'CASH',

    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    reference_number VARCHAR(100),

    status VARCHAR(50) NOT NULL DEFAULT 'PAID',

    notes TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_payments_member
ON gym_payments(member_id);

CREATE INDEX IF NOT EXISTS idx_gym_payments_membership
ON gym_payments(membership_id);

CREATE INDEX IF NOT EXISTS idx_gym_payments_date
ON gym_payments(payment_date);


-- ============================================================
-- 8. WORKOUT PLANS
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_workout_plans (
    id SERIAL PRIMARY KEY,

    member_id INT NOT NULL
        REFERENCES gym_members(id)
        ON DELETE CASCADE,

    trainer_id INT
        REFERENCES gym_trainers(id)
        ON DELETE SET NULL,

    name VARCHAR(150) NOT NULL,

    goal VARCHAR(255),

    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    notes TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_workout_plans_member
ON gym_workout_plans(member_id);


-- ============================================================
-- 9. WORKOUT EXERCISES
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_workout_exercises (
    id SERIAL PRIMARY KEY,

    workout_plan_id INT NOT NULL
        REFERENCES gym_workout_plans(id)
        ON DELETE CASCADE,

    exercise_name VARCHAR(150) NOT NULL,

    muscle_group VARCHAR(100),

    sets INT NOT NULL DEFAULT 3,

    reps VARCHAR(50) NOT NULL DEFAULT '10-12',

    weight VARCHAR(50),
    duration VARCHAR(50),

    notes TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_exercises_plan
ON gym_workout_exercises(workout_plan_id);


-- ============================================================
-- 10. GYM SCHEDULES
-- ============================================================

CREATE TABLE IF NOT EXISTS gym_schedules (
    id SERIAL PRIMARY KEY,

    trainer_id INT
        REFERENCES gym_trainers(id)
        ON DELETE SET NULL,

    title VARCHAR(200) NOT NULL,

    description TEXT,

    start_time VARCHAR(20) NOT NULL,
    end_time VARCHAR(20) NOT NULL,

    date DATE NOT NULL DEFAULT CURRENT_DATE,

    status VARCHAR(50) NOT NULL DEFAULT 'SCHEDULED',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gym_schedules_date
ON gym_schedules(date);

CREATE INDEX IF NOT EXISTS idx_gym_schedules_trainer
ON gym_schedules(trainer_id);


-- ============================================================
-- DEFAULT MEMBERSHIP PLANS
-- ============================================================

INSERT INTO gym_membership_plans
(
    name,
    description,
    duration_days,
    price,
    discount,
    tax,
    total_amount,
    status
)
SELECT
    'Monthly Basic',
    'Full gym access with standard equipment for 30 days',
    30,
    1500.00,
    0.00,
    75.00,
    1575.00,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1
    FROM gym_membership_plans
    WHERE name = 'Monthly Basic'
);


INSERT INTO gym_membership_plans
(
    name,
    description,
    duration_days,
    price,
    discount,
    tax,
    total_amount,
    status
)
SELECT
    'Quarterly Fitness',
    '3 Months complete fitness package including cardio and weights',
    90,
    4000.00,
    200.00,
    190.00,
    3990.00,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1
    FROM gym_membership_plans
    WHERE name = 'Quarterly Fitness'
);


INSERT INTO gym_membership_plans
(
    name,
    description,
    duration_days,
    price,
    discount,
    tax,
    total_amount,
    status
)
SELECT
    'Half-Yearly Pro',
    '6 Months access with personal trainer consultation',
    180,
    7500.00,
    500.00,
    350.00,
    7350.00,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1
    FROM gym_membership_plans
    WHERE name = 'Half-Yearly Pro'
);


INSERT INTO gym_membership_plans
(
    name,
    description,
    duration_days,
    price,
    discount,
    tax,
    total_amount,
    status
)
SELECT
    'Yearly VIP Platinum',
    '12 Months unlimited gym access, sauna, diet plan and personal locker',
    365,
    14000.00,
    1500.00,
    625.00,
    13125.00,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1
    FROM gym_membership_plans
    WHERE name = 'Yearly VIP Platinum'
);