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
    await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS name VARCHAR(150);');
    await connection.execute('ALTER TABLE users ALTER COLUMN name DROP NOT NULL;');
    await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;');
    await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP;');
    await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;');
    await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;');

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
    await connection.execute('ALTER TABLE employees ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;');
    await connection.execute('ALTER TABLE employees ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;');

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
    await connection.execute('ALTER TABLE categories ADD COLUMN IF NOT EXISTS description TEXT;');
    await connection.execute('ALTER TABLE categories ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT \'active\';');
    await connection.execute('ALTER TABLE categories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;');

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
    await connection.execute('ALTER TABLE products ADD COLUMN IF NOT EXISTS brand VARCHAR(100);');
    await connection.execute('ALTER TABLE products ADD COLUMN IF NOT EXISTS opening_stock NUMERIC(12,3) DEFAULT 0;');
    await connection.execute('ALTER TABLE products ADD COLUMN IF NOT EXISTS minimum_stock NUMERIC(12,3) DEFAULT 5;');
    await connection.execute('ALTER TABLE products ADD COLUMN IF NOT EXISTS supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL;');
    await connection.execute('ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url TEXT;');
    await connection.execute('ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT;');

    await connection.execute('CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_products_product_code ON products(product_code);');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);');

    // 5. Purchases & Purchase Items
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS purchases (
        id SERIAL PRIMARY KEY,
        invoice_number VARCHAR(50) UNIQUE NOT NULL,
        supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL,
        purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        subtotal NUMERIC(12,2) DEFAULT 0,
        tax_amount NUMERIC(12,2) DEFAULT 0,
        discount_amount NUMERIC(12,2) DEFAULT 0,
        total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        payment_status VARCHAR(30) DEFAULT 'paid',
        created_by INT REFERENCES users(id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

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
        reference_id VARCHAR(100),
        notes TEXT,
        created_by INT REFERENCES users(id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 7. Expenses
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id SERIAL PRIMARY KEY,
        category_name VARCHAR(100) NOT NULL,
        amount NUMERIC(12,2) NOT NULL,
        description TEXT,
        expense_date DATE DEFAULT CURRENT_DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS pos_orders (
        id SERIAL PRIMARY KEY,
        order_number VARCHAR(50) UNIQUE NOT NULL,
        customer_id INT,
        cashier_id INT NOT NULL REFERENCES users(id),
        subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
        discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        grand_total NUMERIC(12,2) NOT NULL DEFAULT 0,
        payment_status VARCHAR(30) NOT NULL DEFAULT 'pending',
        order_status VARCHAR(30) NOT NULL DEFAULT 'paid',
        amount_received NUMERIC(12,2) NOT NULL DEFAULT 0,
        change_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_pos_orders_order_number ON pos_orders(order_number);');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_pos_orders_created_at ON pos_orders(created_at);');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_pos_orders_cashier_id ON pos_orders(cashier_id);');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS pos_order_items (
        id SERIAL PRIMARY KEY,
        order_id INT NOT NULL REFERENCES pos_orders(id) ON DELETE CASCADE,
        product_id INT NOT NULL REFERENCES products(id),
        product_name VARCHAR(255) NOT NULL,
        quantity NUMERIC(12,3) NOT NULL,
        unit_price NUMERIC(12,2) NOT NULL,
        discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        total_amount NUMERIC(12,2) NOT NULL DEFAULT 0
      );
    ''');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_pos_order_items_order_id ON pos_order_items(order_id);');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        order_id INT NOT NULL REFERENCES pos_orders(id) ON DELETE CASCADE,
        payment_method VARCHAR(30) NOT NULL,
        amount NUMERIC(12,2) NOT NULL,
        reference_number VARCHAR(100),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS refunds (
        id SERIAL PRIMARY KEY,
        refund_number VARCHAR(50) UNIQUE NOT NULL,
        order_id INT NOT NULL REFERENCES pos_orders(id),
        refund_amount NUMERIC(12,2) NOT NULL,
        refund_method VARCHAR(30) NOT NULL,
        reason TEXT,
        processed_by INT NOT NULL REFERENCES users(id),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_refunds_order_id ON refunds(order_id);');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS refund_items (
        id SERIAL PRIMARY KEY,
        refund_id INT NOT NULL REFERENCES refunds(id) ON DELETE CASCADE,
        order_item_id INT NOT NULL REFERENCES pos_order_items(id),
        product_id INT NOT NULL REFERENCES products(id),
        quantity NUMERIC(12,3) NOT NULL,
        refund_amount NUMERIC(12,2) NOT NULL
      );
    ''');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_refund_items_refund_id ON refund_items(refund_id);');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS barcodes (
        id SERIAL PRIMARY KEY,
        product_id INT NOT NULL REFERENCES products(id),
        barcode VARCHAR(100) NOT NULL,
        label_quantity INT NOT NULL DEFAULT 1,
        created_by INT REFERENCES users(id),
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_barcodes_product_id ON barcodes(product_id);');

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

        final userId = userResult.first[0] as int;

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

    // 7. Seed sample categories & products if products table is empty
    final productCheck = await connection.execute('SELECT COUNT(*) FROM products');
    final productCount = (productCheck.first[0] as num).toInt();
    if (productCount == 0) {
      await connection.runTx((session) async {
        final catFood = await session.execute("INSERT INTO categories (name) VALUES ('Food & Snacks') RETURNING id");
        final catDrinks = await session.execute("INSERT INTO categories (name) VALUES ('Beverages') RETURNING id");
        final catElec = await session.execute("INSERT INTO categories (name) VALUES ('Electronics') RETURNING id");
        final catStationery = await session.execute("INSERT INTO categories (name) VALUES ('Stationery') RETURNING id");

        final foodId = catFood.first[0] as int;
        final drinksId = catDrinks.first[0] as int;
        final elecId = catElec.first[0] as int;
        final statId = catStationery.first[0] as int;

        final sampleProducts = [
          {'code': 'PRD001', 'barcode': '890103000001', 'name': 'Organic Almond Milk 1L', 'cat': drinksId, 'pPrice': 2.50, 'sPrice': 4.20, 'tax': 5.0, 'stock': 45.0, 'unit': 'pcs'},
          {'code': 'PRD002', 'barcode': '890103000002', 'name': 'Whole Grain Wheat Bread', 'cat': foodId, 'pPrice': 1.20, 'sPrice': 2.50, 'tax': 0.0, 'stock': 30.0, 'unit': 'pcs'},
          {'code': 'PRD003', 'barcode': '890103000003', 'name': 'USB-C Fast Charging Cable 2m', 'cat': elecId, 'pPrice': 3.00, 'sPrice': 8.99, 'tax': 18.0, 'stock': 60.0, 'unit': 'pcs'},
          {'code': 'PRD004', 'barcode': '890103000004', 'name': 'Executive Ballpoint Pen (Blue)', 'cat': statId, 'pPrice': 0.50, 'sPrice': 1.50, 'tax': 12.0, 'stock': 120.0, 'unit': 'pcs'},
        ];

        for (final p in sampleProducts) {
          await session.execute(
            Sql.named('''
              INSERT INTO products (product_code, barcode, name, category_id, purchase_price, selling_price, tax_percentage, stock_quantity, unit, is_active)
              VALUES (@code, @barcode, @name, @cat, @pPrice, @sPrice, @tax, @stock, @unit, true)
            '''),
            parameters: p,
          );
        }
      });
      stdout.writeln('Sample Cashier products and categories seeded successfully.');
    }
  }

  Future<void> close() async {
    await connection.close();
  }
}
