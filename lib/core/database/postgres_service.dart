import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:erp_software/core/config/app_config.dart';
import 'package:postgres/postgres.dart';

class PostgresService {
  late Connection connection;

  Future<void> connect() async {
    final host = AppConfig.dbHost;
    final port = AppConfig.dbPort;
    final database = AppConfig.dbName;
    final username = AppConfig.dbUser;
    final password = AppConfig.dbPassword;

    connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    stdout.writeln('PostgreSQL database connected successfully');

    await _initializeTables();
  }

  Future<void> _initializeTables() async {
    // 0. Ensure extensions for UUID generation
    try {
      await connection.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto";');
    } catch (_) {}
    try {
      await connection.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";');
    } catch (_) {}

    // Explicit fixes for existing tables
    final tableDefaults = [
      // Categories
      "ALTER TABLE categories ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE categories ALTER COLUMN code DROP NOT NULL;",
      "ALTER TABLE categories ALTER COLUMN code SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE categories ADD COLUMN IF NOT EXISTS description TEXT;",
      "ALTER TABLE categories ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';",

      // Products
      "ALTER TABLE products ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE products ALTER COLUMN sku DROP NOT NULL;",
      "ALTER TABLE products ALTER COLUMN cost_price SET DEFAULT 0.00;",
      "ALTER TABLE products ALTER COLUMN selling_price SET DEFAULT 0.00;",
      "ALTER TABLE products ALTER COLUMN purchase_price SET DEFAULT 0.00;",
      "ALTER TABLE products ALTER COLUMN tax_percentage SET DEFAULT 0.00;",
      "ALTER TABLE products ALTER COLUMN stock_quantity SET DEFAULT 0;",
      "ALTER TABLE products ALTER COLUMN is_active SET DEFAULT true;",

      // Brands
      "ALTER TABLE brands ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE brands ALTER COLUMN status SET DEFAULT 'ACTIVE';",

      // Units
      "ALTER TABLE units ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE units ALTER COLUMN status SET DEFAULT 'ACTIVE';",

      // Suppliers
      "ALTER TABLE suppliers ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE suppliers ALTER COLUMN phone DROP NOT NULL;",
      "ALTER TABLE suppliers ALTER COLUMN status SET DEFAULT 'ACTIVE';",
      "ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);",
      "ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS contact_person VARCHAR(255);",
      "ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS tax_number VARCHAR(50);",
      "ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS supplier_code VARCHAR(50);",
      "ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS gst_vat_number VARCHAR(50);",
      "ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;",
      "UPDATE suppliers SET company_name = name WHERE company_name IS NULL AND name IS NOT NULL;",
      "UPDATE suppliers SET name = company_name WHERE name IS NULL AND company_name IS NOT NULL;",
      "UPDATE suppliers SET supplier_code = 'SUP-' || id WHERE supplier_code IS NULL;",

      // Purchases
      "ALTER TABLE purchases ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE purchases ALTER COLUMN purchase_no DROP NOT NULL;",
      "ALTER TABLE purchases ALTER COLUMN total_amount SET DEFAULT 0.00;",
      "ALTER TABLE purchases ALTER COLUMN status SET DEFAULT 'received';",

      // Stock Movements
      "ALTER TABLE stock_movements ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE stock_movements ALTER COLUMN quantity SET DEFAULT 0;",

      // Warehouses
      "ALTER TABLE warehouses ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE warehouses ALTER COLUMN code DROP NOT NULL;",
      "ALTER TABLE warehouses ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'ACTIVE';",
      "ALTER TABLE warehouses ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;",

      // Inventory
      "ALTER TABLE inventory ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",

      // Payments
      "ALTER TABLE payments ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;",
      "ALTER TABLE payments ADD COLUMN IF NOT EXISTS order_id VARCHAR(100);",
      "ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) DEFAULT 'cash';",
      "UPDATE payments SET payment_method = method WHERE payment_method IS NULL AND method IS NOT NULL;",
      "UPDATE payments SET method = payment_method WHERE method IS NULL AND payment_method IS NOT NULL;",

      // Foreign Key Cascades & Nullifications
      "ALTER TABLE products DROP CONSTRAINT IF EXISTS products_unit_id_fkey;",
      "ALTER TABLE products ADD CONSTRAINT products_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;",
      "ALTER TABLE products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "ALTER TABLE products DROP CONSTRAINT IF EXISTS products_brand_id_fkey;",
      "ALTER TABLE products ADD CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "ALTER TABLE purchases DROP CONSTRAINT IF EXISTS purchases_supplier_id_fkey;",
      "ALTER TABLE purchases ADD CONSTRAINT purchases_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "CREATE TABLE IF NOT EXISTS purchase_items (id SERIAL PRIMARY KEY, purchase_id INT NOT NULL, product_id INT, quantity NUMERIC(12,3) NOT NULL, purchase_price NUMERIC(12,2) NOT NULL, tax_amount NUMERIC(12,2) DEFAULT 0, discount_amount NUMERIC(12,2) DEFAULT 0, total_amount NUMERIC(12,2) NOT NULL);",
      "ALTER TABLE purchase_items DROP CONSTRAINT IF EXISTS purchase_items_product_id_fkey;",
      "ALTER TABLE purchase_items ADD CONSTRAINT purchase_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "ALTER TABLE invoice_items DROP CONSTRAINT IF EXISTS invoice_items_product_id_fkey;",
      "ALTER TABLE invoice_items ADD CONSTRAINT invoice_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "ALTER TABLE return_items DROP CONSTRAINT IF EXISTS return_items_product_id_fkey;",
      "ALTER TABLE return_items ADD CONSTRAINT return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL ON UPDATE CASCADE;",
      "ALTER TABLE stock_transfer_items DROP CONSTRAINT IF EXISTS stock_transfer_items_product_id_fkey;",
      "ALTER TABLE stock_transfer_items ADD CONSTRAINT stock_transfer_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL ON UPDATE CASCADE;",
    ];

    for (final cmd in tableDefaults) {
      try {
        await connection.execute(cmd);
      } catch (_) {}
    }

    // Helper to fix missing default on any existing table's 'id' column
    Future<void> ensureAllTableDefaults() async {
      try {
        await connection.execute('''
          DO \$\$
          DECLARE
            tbl text;
            col_type text;
            col_def text;
          BEGIN
            FOR tbl IN 
              SELECT table_name 
              FROM information_schema.tables 
              WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            LOOP
              SELECT data_type, column_default INTO col_type, col_def
              FROM information_schema.columns 
              WHERE table_schema = 'public' AND table_name = tbl AND column_name = 'id';

              IF col_type IS NOT NULL AND col_def IS NULL THEN
                IF col_type = 'uuid' THEN
                  BEGIN
                    EXECUTE format('ALTER TABLE %I ALTER COLUMN id SET DEFAULT gen_random_uuid()', tbl);
                  EXCEPTION WHEN OTHERS THEN NULL;
                  END;
                ELSIF col_type IN ('character varying', 'varchar', 'text') THEN
                  BEGIN
                    EXECUTE format('ALTER TABLE %I ALTER COLUMN id SET DEFAULT gen_random_uuid()::text', tbl);
                  EXCEPTION WHEN OTHERS THEN NULL;
                  END;
                ELSIF col_type IN ('integer', 'bigint', 'smallint') THEN
                  BEGIN
                    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I_id_seq', tbl);
                    EXECUTE format('ALTER TABLE %I ALTER COLUMN id SET DEFAULT nextval(''%s_id_seq'')', tbl, tbl);
                    EXECUTE format('SELECT setval(''%s_id_seq'', COALESCE((SELECT MAX(id) FROM %I), 0) + 1, false)', tbl, tbl);
                  EXCEPTION WHEN OTHERS THEN NULL;
                  END;
                END IF;
              END IF;
            END LOOP;
          END \$\$;
        ''');
      } catch (e) {
        stdout.writeln('Schema default check: $e');
      }
    }

    await ensureAllTableDefaults();

    // 1. Create users table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(150) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'employee',
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        last_login_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 2. Create employees table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id SERIAL PRIMARY KEY,
        user_id INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        employee_id VARCHAR(50) UNIQUE NOT NULL,
        full_name VARCHAR(150) NOT NULL,
        phone VARCHAR(30),
        department VARCHAR(100),
        designation VARCHAR(100),
        joining_date DATE,
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 3. Create otp_verifications table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS otp_verifications (
        id SERIAL PRIMARY KEY,
        email VARCHAR(150) NOT NULL,
        otp_code VARCHAR(10) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        is_used BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 4. Create Cashier & Inventory tables
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS suppliers (
        id SERIAL PRIMARY KEY,
        supplier_code VARCHAR(50) UNIQUE NOT NULL,
        name VARCHAR(150) NOT NULL,
        phone VARCHAR(30),
        email VARCHAR(150),
        address TEXT,
        gst_vat_number VARCHAR(50),
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id SERIAL PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        phone VARCHAR(30),
        email VARCHAR(150),
        address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        description TEXT,
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS brands (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        description TEXT,
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS units (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        short_symbol VARCHAR(50) NOT NULL,
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        product_code VARCHAR(50) UNIQUE NOT NULL,
        barcode VARCHAR(100) UNIQUE,
        name VARCHAR(255) NOT NULL,
        category_id INT REFERENCES categories(id) ON DELETE SET NULL,
        supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL,
        brand VARCHAR(100),
        unit VARCHAR(30) NOT NULL DEFAULT 'pcs',
        purchase_price NUMERIC(12,2) NOT NULL DEFAULT 0,
        selling_price NUMERIC(12,2) NOT NULL DEFAULT 0,
        tax_percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
        opening_stock NUMERIC(12,3) NOT NULL DEFAULT 0,
        stock_quantity NUMERIC(12,3) NOT NULL DEFAULT 0,
        minimum_stock NUMERIC(12,3) NOT NULL DEFAULT 5,
        image_url TEXT,
        description TEXT,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 5. Purchases & Purchase Items
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS purchases (
        id SERIAL PRIMARY KEY,
        po_number VARCHAR(50) UNIQUE NOT NULL,
        supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL,
        supplier_name VARCHAR(150),
        total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        status VARCHAR(20) NOT NULL DEFAULT 'received',
        received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Add missing columns to purchases if table already existed from migration 009
    final purchaseAlterCols = [
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS po_number VARCHAR(50);",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(150);",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS total_amount NUMERIC(12,2) NOT NULL DEFAULT 0;",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'received';",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) DEFAULT 'paid';",
      "ALTER TABLE purchases ADD COLUMN IF NOT EXISTS notes TEXT;",
    ];
    for (final cmd in purchaseAlterCols) {
      try { await connection.execute(cmd); } catch (_) {}
    }

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS purchase_items (
        id SERIAL PRIMARY KEY,
        purchase_id INT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
        product_id INT NOT NULL REFERENCES products(id),
        quantity NUMERIC(12,3) NOT NULL,
        purchase_price NUMERIC(12,2) NOT NULL,
        tax_amount NUMERIC(12,2) DEFAULT 0,
        discount_amount NUMERIC(12,2) DEFAULT 0,
        total_amount NUMERIC(12,2) NOT NULL
      );
    ''');

    // 6. Stock Movements Audit Trail
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS stock_movements (
        id SERIAL PRIMARY KEY,
        product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        movement_type VARCHAR(30) NOT NULL,
        quantity NUMERIC(12,3) NOT NULL,
        previous_stock NUMERIC(12,3) NOT NULL,
        new_stock NUMERIC(12,3) NOT NULL,
        reference_type VARCHAR(50),
        reference_id INT,
        notes TEXT,
        created_by INT REFERENCES users(id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 7. POS Tables
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS pos_orders (
        id SERIAL PRIMARY KEY,
        order_number VARCHAR(50) UNIQUE NOT NULL,
        customer_id INT REFERENCES customers(id),
        cashier_id INT REFERENCES users(id),
        subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
        discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        grand_total NUMERIC(12,2) NOT NULL DEFAULT 0,
        payment_status VARCHAR(30) NOT NULL DEFAULT 'paid',
        order_status VARCHAR(30) NOT NULL DEFAULT 'paid',
        amount_received NUMERIC(12,2) NOT NULL DEFAULT 0,
        change_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS pos_order_items (
        id SERIAL PRIMARY KEY,
        order_id INT NOT NULL REFERENCES pos_orders(id) ON DELETE CASCADE,
        product_id INT NOT NULL REFERENCES products(id),
        product_name VARCHAR(255) NOT NULL,
        quantity NUMERIC(12,3) NOT NULL DEFAULT 1,
        unit_price NUMERIC(12,2) NOT NULL DEFAULT 0,
        discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        total_amount NUMERIC(12,2) NOT NULL DEFAULT 0
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        order_id INT NOT NULL REFERENCES pos_orders(id) ON DELETE CASCADE,
        payment_method VARCHAR(50) NOT NULL DEFAULT 'cash',
        amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        reference_number VARCHAR(100),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS refunds (
        id SERIAL PRIMARY KEY,
        refund_number VARCHAR(50) UNIQUE NOT NULL,
        order_id INT NOT NULL REFERENCES pos_orders(id),
        refund_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        refund_method VARCHAR(50) NOT NULL DEFAULT 'cash',
        reason TEXT,
        processed_by INT REFERENCES users(id),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS refund_items (
        id SERIAL PRIMARY KEY,
        refund_id INT NOT NULL REFERENCES refunds(id) ON DELETE CASCADE,
        order_item_id INT NOT NULL REFERENCES pos_order_items(id),
        product_id INT NOT NULL REFERENCES products(id),
        quantity NUMERIC(12,3) NOT NULL DEFAULT 1,
        refund_amount NUMERIC(12,2) NOT NULL DEFAULT 0
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS barcodes (
        id SERIAL PRIMARY KEY,
        product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        barcode VARCHAR(100) NOT NULL,
        label_quantity INT NOT NULL DEFAULT 1,
        created_by INT REFERENCES users(id),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS barcode_labels (
        id SERIAL PRIMARY KEY,
        product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        barcode VARCHAR(100) NOT NULL,
        label_quantity INT NOT NULL DEFAULT 1,
        created_by INT REFERENCES users(id),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS cashier_settings (
        id SERIAL PRIMARY KEY,
        store_name VARCHAR(255) DEFAULT 'ERP Mart Store',
        store_address TEXT DEFAULT '123 Commerce Way, Tech City',
        phone VARCHAR(50) DEFAULT '+1 (555) 019-2831',
        email VARCHAR(150) DEFAULT 'support@erpmart.com',
        receipt_footer TEXT DEFAULT 'Thank you for shopping with us! Please come again.',
        show_logo BOOLEAN NOT NULL DEFAULT TRUE,
        show_tax BOOLEAN NOT NULL DEFAULT TRUE,
        show_cashier_name BOOLEAN NOT NULL DEFAULT TRUE,
        show_customer_name BOOLEAN NOT NULL DEFAULT TRUE,
        auto_print_receipt BOOLEAN NOT NULL DEFAULT FALSE,
        default_tax_percentage NUMERIC(5,2) NOT NULL DEFAULT 5.00,
        allow_negative_stock BOOLEAN NOT NULL DEFAULT FALSE,
        require_customer BOOLEAN NOT NULL DEFAULT FALSE,
        allow_discount BOOLEAN NOT NULL DEFAULT TRUE,
        maximum_discount_percentage NUMERIC(5,2) NOT NULL DEFAULT 50.00,
        auto_clear_cart BOOLEAN NOT NULL DEFAULT TRUE,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Run table defaults migration once again to cover newly defined tables
    await ensureAllTableDefaults();

    // 5. Seed admin user if users table is empty
    final userCheck = await connection.execute('SELECT COUNT(*) FROM users');
    final count = (userCheck.first[0] as num).toInt();
    if (count == 0) {
      final hashedPassword = BCrypt.hashpw('admin123', BCrypt.gensalt());
      await connection.runTx((session) async {
        final userResult = await session.execute(
          Sql.named('''
            INSERT INTO users (email, password_hash, role, is_active)
            VALUES (@email, @password_hash, @role, true)
            RETURNING id
          '''),
          parameters: {
            'email': 'admin@erp.com',
            'password_hash': hashedPassword,
            'role': 'admin',
          },
        );

        final userId = int.tryParse(userResult.first[0].toString()) ?? userResult.first[0];

        await session.execute(
          Sql.named('''
            INSERT INTO employees (user_id, employee_id, full_name, phone, department, designation, is_verified)
            VALUES (@user_id, 'EMP001', 'System Admin', '+1000000000', 'Executive', 'Administrator', true)
          '''),
          parameters: {
            'user_id': userId,
          },
        );
      });
      stdout.writeln('Default Admin user created (admin@erp.com / admin123)');
    }

    // 6. Seed cashier settings if empty
    final settingsCheck = await connection.execute('SELECT COUNT(*) FROM cashier_settings');
    final settingsCount = (settingsCheck.first[0] as num).toInt();
    if (settingsCount == 0) {
      await connection.execute('''
        INSERT INTO cashier_settings (store_name, store_address, phone, email, receipt_footer)
        VALUES ('ERP Supermart', '452 Enterprise Ave, Suite 100', '+1 (800) 555-0199', 'billing@erpsupermart.com', 'Thank you for your business!');
      ''');
    }
  }

  Future<void> close() async {
    await connection.close();
  }
}
