import 'package:erp_software/core/models/cashier/cashier_settings_model.dart';
import 'package:erp_software/backend/database/postgres_service.dart';
import 'package:postgres/postgres.dart';

class CashierSettingsRepository {
  final PostgresService db;

  CashierSettingsRepository(this.db);

  Future<CashierSettingsModel> getSettings() async {
    final result = await db.connection.execute('SELECT * FROM cashier_settings ORDER BY id ASC LIMIT 1');
    if (result.isEmpty) {
      return CashierSettingsModel();
    }
    return CashierSettingsModel.fromJson(result.first.toColumnMap());
  }

  Future<CashierSettingsModel> updateSettings(CashierSettingsModel settings) async {
    final sql = '''
      UPDATE cashier_settings SET
        store_name = @storeName,
        store_address = @storeAddress,
        phone = @phone,
        email = @email,
        receipt_footer = @receiptFooter,
        show_logo = @showLogo,
        show_tax = @showTax,
        show_cashier_name = @showCashierName,
        show_customer_name = @showCustomerName,
        auto_print_receipt = @autoPrintReceipt,
        default_tax_percentage = @defaultTaxPercentage,
        allow_negative_stock = @allowNegativeStock,
        require_customer = @requireCustomer,
        allow_discount = @allowDiscount,
        maximum_discount_percentage = @maximumDiscountPercentage,
        auto_clear_cart = @autoClearCart,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = (SELECT id FROM cashier_settings ORDER BY id ASC LIMIT 1)
      RETURNING *
    ''';

    final result = await db.connection.execute(
      Sql.named(sql),
      parameters: {
        'storeName': settings.storeName,
        'storeAddress': settings.storeAddress,
        'phone': settings.phone,
        'email': settings.email,
        'receiptFooter': settings.receiptFooter,
        'showLogo': settings.showLogo,
        'showTax': settings.showTax,
        'showCashierName': settings.showCashierName,
        'showCustomerName': settings.showCustomerName,
        'autoPrintReceipt': settings.autoPrintReceipt,
        'defaultTaxPercentage': settings.defaultTaxPercentage,
        'allowNegativeStock': settings.allowNegativeStock,
        'requireCustomer': settings.requireCustomer,
        'allowDiscount': settings.allowDiscount,
        'maximumDiscountPercentage': settings.maximumDiscountPercentage,
        'autoClearCart': settings.autoClearCart,
      },
    );

    if (result.isEmpty) {
      // If table was empty, insert default
      final insRes = await db.connection.execute(
        Sql.named('''
          INSERT INTO cashier_settings (store_name, store_address, phone, email, receipt_footer)
          VALUES (@storeName, @storeAddress, @phone, @email, @receiptFooter)
          RETURNING *
        '''),
        parameters: {
          'storeName': settings.storeName,
          'storeAddress': settings.storeAddress,
          'phone': settings.phone,
          'email': settings.email,
          'receiptFooter': settings.receiptFooter,
        },
      );
      return CashierSettingsModel.fromJson(insRes.first.toColumnMap());
    }

    return CashierSettingsModel.fromJson(result.first.toColumnMap());
  }
}

