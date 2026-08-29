import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/landing_page_provider.dart';
import 'image_picker_field.dart';
import 'section_text_field.dart';

class HeroSectionForm extends StatelessWidget {
  const HeroSectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandingPageProvider>();
    final d = provider.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hero Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 16),
        SectionTextField(label: 'Hero Tag', value: d.heroTag, onChanged: (v) => provider.update(heroTag: v)),
        const SizedBox(height: 16),
        SectionTextField(label: 'Hero Title', value: d.heroTitle, onChanged: (v) => provider.update(heroTitle: v)),
        const SizedBox(height: 16),
        SectionTextField(
          label: 'Hero Description',
          value: d.heroDescription,
          onChanged: (v) => provider.update(heroDescription: v),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        SectionTextField(label: 'Hero Button Text', value: d.heroButtonText, onChanged: (v) => provider.update(heroButtonText: v)),
        const SizedBox(height: 16),
        ImagePickerField(
          label: 'Hero Dashboard Image',
          base64Value: d.heroDashboardImageBase64,
          onChanged: (v) => provider.update(heroDashboardImageBase64: v),
        ),
        const SizedBox(height: 16),
        ImagePickerField(
          label: 'Hero Background Image',
          base64Value: d.heroBackgroundImageBase64,
          onChanged: (v) => provider.update(heroBackgroundImageBase64: v),
        ),
        const SizedBox(height: 16),
        SectionTextField(label: 'Dashboard Title', value: d.dashboardTitle, onChanged: (v) => provider.update(dashboardTitle: v)),
        const SizedBox(height: 16),
        SectionTextField(label: 'Dashboard Subtitle', value: d.dashboardSubtitle, onChanged: (v) => provider.update(dashboardSubtitle: v)),
      ],
    );
  }
}
