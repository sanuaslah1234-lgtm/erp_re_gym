class LandingPageModel {
  final String logoText;
  final String logoHighlight;
  final String loginButtonText;

  final String heroTag;
  final String heroTitle;
  final String heroDescription;
  final String heroButtonText;
  final String? heroDashboardImageBase64;
  final String? heroBackgroundImageBase64;
  final String dashboardTitle;
  final String dashboardSubtitle;

  final String aboutTag;
  final String aboutTitle;
  final String aboutDescription;
  final String? aboutImage1Base64;
  final String? aboutImage2Base64;
  final String? aboutImage3Base64;
  final String? aboutImage4Base64;

  final String footerText;
  final DateTime? updatedAt;

  const LandingPageModel({
    this.logoText = '',
    this.logoHighlight = '',
    this.loginButtonText = '',
    this.heroTag = '',
    this.heroTitle = '',
    this.heroDescription = '',
    this.heroButtonText = '',
    this.heroDashboardImageBase64,
    this.heroBackgroundImageBase64,
    this.dashboardTitle = '',
    this.dashboardSubtitle = '',
    this.aboutTag = '',
    this.aboutTitle = '',
    this.aboutDescription = '',
    this.aboutImage1Base64,
    this.aboutImage2Base64,
    this.aboutImage3Base64,
    this.aboutImage4Base64,
    this.footerText = '',
    this.updatedAt,
  });

  factory LandingPageModel.fromJson(Map<String, dynamic> json) => LandingPageModel.fromMap(json);
  factory LandingPageModel.fromMap(Map<String, dynamic> json) {
    return LandingPageModel(
      logoText: json['logo_text']?.toString() ?? '',
      logoHighlight: json['logo_highlight']?.toString() ?? '',
      loginButtonText: json['login_button_text']?.toString() ?? '',
      heroTag: json['hero_tag']?.toString() ?? '',
      heroTitle: json['hero_title']?.toString() ?? '',
      heroDescription: json['hero_description']?.toString() ?? '',
      heroButtonText: json['hero_button_text']?.toString() ?? '',
      heroDashboardImageBase64: json['hero_dashboard_image_base64']?.toString(),
      heroBackgroundImageBase64: json['hero_background_image_base64']?.toString(),
      dashboardTitle: json['dashboard_title']?.toString() ?? '',
      dashboardSubtitle: json['dashboard_subtitle']?.toString() ?? '',
      aboutTag: json['about_tag']?.toString() ?? '',
      aboutTitle: json['about_title']?.toString() ?? '',
      aboutDescription: json['about_description']?.toString() ?? '',
      aboutImage1Base64: json['about_image_1_base64']?.toString(),
      aboutImage2Base64: json['about_image_2_base64']?.toString(),
      aboutImage3Base64: json['about_image_3_base64']?.toString(),
      aboutImage4Base64: json['about_image_4_base64']?.toString(),
      footerText: json['footer_text']?.toString() ?? '',
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => toRequestJson();
  Map<String, dynamic> toRequestJson() {
    return {
      'logo_text': logoText,
      'logo_highlight': logoHighlight,
      'login_button_text': loginButtonText,
      'hero_tag': heroTag,
      'hero_title': heroTitle,
      'hero_description': heroDescription,
      'hero_button_text': heroButtonText,
      'hero_dashboard_image_base64': heroDashboardImageBase64,
      'hero_background_image_base64': heroBackgroundImageBase64,
      'dashboard_title': dashboardTitle,
      'dashboard_subtitle': dashboardSubtitle,
      'about_tag': aboutTag,
      'about_title': aboutTitle,
      'about_description': aboutDescription,
      'about_image_1_base64': aboutImage1Base64,
      'about_image_2_base64': aboutImage2Base64,
      'about_image_3_base64': aboutImage3Base64,
      'about_image_4_base64': aboutImage4Base64,
      'footer_text': footerText,
    };
  }

  LandingPageModel copyWith({
    String? logoText,
    String? logoHighlight,
    String? loginButtonText,
    String? heroTag,
    String? heroTitle,
    String? heroDescription,
    String? heroButtonText,
    String? heroDashboardImageBase64,
    String? heroBackgroundImageBase64,
    String? dashboardTitle,
    String? dashboardSubtitle,
    String? aboutTag,
    String? aboutTitle,
    String? aboutDescription,
    String? aboutImage1Base64,
    String? aboutImage2Base64,
    String? aboutImage3Base64,
    String? aboutImage4Base64,
    String? footerText,
  }) {
    return LandingPageModel(
      logoText: logoText ?? this.logoText,
      logoHighlight: logoHighlight ?? this.logoHighlight,
      loginButtonText: loginButtonText ?? this.loginButtonText,
      heroTag: heroTag ?? this.heroTag,
      heroTitle: heroTitle ?? this.heroTitle,
      heroDescription: heroDescription ?? this.heroDescription,
      heroButtonText: heroButtonText ?? this.heroButtonText,
      heroDashboardImageBase64: heroDashboardImageBase64 ?? this.heroDashboardImageBase64,
      heroBackgroundImageBase64: heroBackgroundImageBase64 ?? this.heroBackgroundImageBase64,
      dashboardTitle: dashboardTitle ?? this.dashboardTitle,
      dashboardSubtitle: dashboardSubtitle ?? this.dashboardSubtitle,
      aboutTag: aboutTag ?? this.aboutTag,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutDescription: aboutDescription ?? this.aboutDescription,
      aboutImage1Base64: aboutImage1Base64 ?? this.aboutImage1Base64,
      aboutImage2Base64: aboutImage2Base64 ?? this.aboutImage2Base64,
      aboutImage3Base64: aboutImage3Base64 ?? this.aboutImage3Base64,
      aboutImage4Base64: aboutImage4Base64 ?? this.aboutImage4Base64,
      footerText: footerText ?? this.footerText,
      updatedAt: updatedAt,
    );
  }
}