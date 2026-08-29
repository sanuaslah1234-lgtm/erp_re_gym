import 'package:postgres/postgres.dart';

class LandingPageRepository {
  final Connection connection;

  LandingPageRepository(this.connection);

  static const _selectColumns = '''
    logo_text, logo_highlight, login_button_text,
    hero_tag, hero_title, hero_description, hero_button_text,
    hero_dashboard_image_base64, hero_background_image_base64,
    dashboard_title, dashboard_subtitle,
    about_tag, about_title, about_description,
    about_image_1_base64, about_image_2_base64, about_image_3_base64, about_image_4_base64,
    footer_text, updated_at
  ''';

  static const _defaults = {
    'logo_text': 'ERP',
    'logo_highlight': 'Clouds',
    'login_button_text': 'Login →',
    'hero_tag': 'CLOUD ERP PLATFORM',
    'hero_title': 'Run Your Business Smarter.',
    'hero_description':
        'Manage inventory, products, warehouses, purchases, suppliers, sales, billing, and business operations with a powerful cloud-based ERP system built for modern businesses.',
    'hero_button_text': 'Get Started Today →',
    'dashboard_title': 'ERP Dashboard',
    'dashboard_subtitle': 'Real-Time Business Overview',
    'about_tag': 'ABOUT ERP CLOUD',
    'about_title': 'One Platform. Complete Business Control.',
    'about_description':
        'ERPCloud brings your entire business into one powerful platform. Manage inventory, billing, products, warehouses, purchases, suppliers, and business operations with real-time visibility and complete control.',
    'footer_text': '© ERP Cloud. All Rights Reserved.',
  };

  Future<Map<String, dynamic>> getSettings() async {
    final result = await connection.execute('''
      SELECT $_selectColumns FROM landing_page_settings WHERE id = 1
    ''');

    if (result.isEmpty) {
      return updateSettings(_defaults);
    }

    return _mapRow(result.first);
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final result = await connection.execute(
      Sql.named('''
        INSERT INTO landing_page_settings (
          id, logo_text, logo_highlight, login_button_text,
          hero_tag, hero_title, hero_description, hero_button_text,
          hero_dashboard_image_base64, hero_background_image_base64,
          dashboard_title, dashboard_subtitle,
          about_tag, about_title, about_description,
          about_image_1_base64, about_image_2_base64, about_image_3_base64, about_image_4_base64,
          footer_text, updated_at
        )
        VALUES (
          1, @logo_text, @logo_highlight, @login_button_text,
          @hero_tag, @hero_title, @hero_description, @hero_button_text,
          @hero_dashboard_image_base64, @hero_background_image_base64,
          @dashboard_title, @dashboard_subtitle,
          @about_tag, @about_title, @about_description,
          @about_image_1_base64, @about_image_2_base64, @about_image_3_base64, @about_image_4_base64,
          @footer_text, CURRENT_TIMESTAMP
        )
        ON CONFLICT (id) DO UPDATE SET
          logo_text = EXCLUDED.logo_text,
          logo_highlight = EXCLUDED.logo_highlight,
          login_button_text = EXCLUDED.login_button_text,
          hero_tag = EXCLUDED.hero_tag,
          hero_title = EXCLUDED.hero_title,
          hero_description = EXCLUDED.hero_description,
          hero_button_text = EXCLUDED.hero_button_text,
          hero_dashboard_image_base64 = COALESCE(EXCLUDED.hero_dashboard_image_base64, landing_page_settings.hero_dashboard_image_base64),
          hero_background_image_base64 = COALESCE(EXCLUDED.hero_background_image_base64, landing_page_settings.hero_background_image_base64),
          dashboard_title = EXCLUDED.dashboard_title,
          dashboard_subtitle = EXCLUDED.dashboard_subtitle,
          about_tag = EXCLUDED.about_tag,
          about_title = EXCLUDED.about_title,
          about_description = EXCLUDED.about_description,
          about_image_1_base64 = COALESCE(EXCLUDED.about_image_1_base64, landing_page_settings.about_image_1_base64),
          about_image_2_base64 = COALESCE(EXCLUDED.about_image_2_base64, landing_page_settings.about_image_2_base64),
          about_image_3_base64 = COALESCE(EXCLUDED.about_image_3_base64, landing_page_settings.about_image_3_base64),
          about_image_4_base64 = COALESCE(EXCLUDED.about_image_4_base64, landing_page_settings.about_image_4_base64),
          footer_text = EXCLUDED.footer_text,
          updated_at = CURRENT_TIMESTAMP
        RETURNING $_selectColumns
      '''),
      parameters: {
        'logo_text': data['logo_text'] ?? '',
        'logo_highlight': data['logo_highlight'] ?? '',
        'login_button_text': data['login_button_text'] ?? '',
        'hero_tag': data['hero_tag'] ?? '',
        'hero_title': data['hero_title'] ?? '',
        'hero_description': data['hero_description'],
        'hero_button_text': data['hero_button_text'] ?? '',
        'hero_dashboard_image_base64': data['hero_dashboard_image_base64'],
        'hero_background_image_base64': data['hero_background_image_base64'],
        'dashboard_title': data['dashboard_title'] ?? '',
        'dashboard_subtitle': data['dashboard_subtitle'] ?? '',
        'about_tag': data['about_tag'] ?? '',
        'about_title': data['about_title'] ?? '',
        'about_description': data['about_description'],
        'about_image_1_base64': data['about_image_1_base64'],
        'about_image_2_base64': data['about_image_2_base64'],
        'about_image_3_base64': data['about_image_3_base64'],
        'about_image_4_base64': data['about_image_4_base64'],
        'footer_text': data['footer_text'] ?? '',
      },
    );

    return _mapRow(result.first);
  }

  Future<Map<String, dynamic>> resetToDefaults() async {
    // Reset clears text back to defaults but intentionally leaves images
    // alone (COALESCE keeps existing images since defaults has none) —
    // avoids silently deleting uploaded images on a text reset.
    return updateSettings(_defaults);
  }

  Map<String, dynamic> _mapRow(ResultRow row) {
    return {
      'logo_text': row[0],
      'logo_highlight': row[1],
      'login_button_text': row[2],
      'hero_tag': row[3],
      'hero_title': row[4],
      'hero_description': row[5],
      'hero_button_text': row[6],
      'hero_dashboard_image_base64': row[7],
      'hero_background_image_base64': row[8],
      'dashboard_title': row[9],
      'dashboard_subtitle': row[10],
      'about_tag': row[11],
      'about_title': row[12],
      'about_description': row[13],
      'about_image_1_base64': row[14],
      'about_image_2_base64': row[15],
      'about_image_3_base64': row[16],
      'about_image_4_base64': row[17],
      'footer_text': row[18],
      'updated_at': row[19]?.toString(),
    };
  }
}