import 'package:postgres/postgres.dart';

class SettingsRepository {
  final Connection connection;

  SettingsRepository(this.connection);

  static const _defaults = {
    'company_logo_base64': null,
    'company_name': 'ERP Software Inc.',
    'legal_trade_name': 'ERP Enterprise Solutions Inc.',
    'tax_vat_number': 'TAX-99887766',
    'official_email': 'support@erp-enterprise.com',
    'business_phone': '+1 (555) 019-2834',
    'headquarters_address': '100 Innovation Way, Suite 400, Tech Park, NY 10001',
  };

  Future<Map<String, dynamic>> getSettings() async {
    final result = await connection.execute('''
      SELECT
        company_logo_base64, company_name, legal_trade_name, tax_vat_number,
        official_email, business_phone, headquarters_address, updated_at
      FROM business_settings
      WHERE id = 1
    ''');

    if (result.isEmpty) {
      // Table exists but somehow no row — create the default one.
      return updateSettings(_defaults);
    }

    return _mapRow(result.first);
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final result = await connection.execute(
      Sql.named('''
        INSERT INTO business_settings (
          id, company_logo_base64, company_name, legal_trade_name,
          tax_vat_number, official_email, business_phone, headquarters_address, updated_at
        )
        VALUES (
          1, @company_logo_base64, @company_name, @legal_trade_name,
          @tax_vat_number, @official_email, @business_phone, @headquarters_address, CURRENT_TIMESTAMP
        )
        ON CONFLICT (id) DO UPDATE SET
          company_logo_base64  = COALESCE(EXCLUDED.company_logo_base64, business_settings.company_logo_base64),
          company_name         = EXCLUDED.company_name,
          legal_trade_name     = EXCLUDED.legal_trade_name,
          tax_vat_number       = EXCLUDED.tax_vat_number,
          official_email       = EXCLUDED.official_email,
          business_phone       = EXCLUDED.business_phone,
          headquarters_address = EXCLUDED.headquarters_address,
          updated_at           = CURRENT_TIMESTAMP
        RETURNING
          company_logo_base64, company_name, legal_trade_name, tax_vat_number,
          official_email, business_phone, headquarters_address, updated_at
      '''),
      parameters: {
        'company_logo_base64': data['company_logo_base64'],
        'company_name': data['company_name'] ?? '',
        'legal_trade_name': data['legal_trade_name'],
        'tax_vat_number': data['tax_vat_number'],
        'official_email': data['official_email'],
        'business_phone': data['business_phone'],
        'headquarters_address': data['headquarters_address'],
      },
    );

    return _mapRow(result.first);
  }

  Future<Map<String, dynamic>> resetToDefaults() async {
    return updateSettings(_defaults);
  }

  Map<String, dynamic> _mapRow(ResultRow row) {
    return {
      'company_logo_base64': row[0],
      'company_name': row[1],
      'legal_trade_name': row[2],
      'tax_vat_number': row[3],
      'official_email': row[4],
      'business_phone': row[5],
      'headquarters_address': row[6],
      'updated_at': row[7]?.toString(),
    };
  }
}