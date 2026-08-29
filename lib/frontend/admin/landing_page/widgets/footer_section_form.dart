import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/landing_page_provider.dart';
import 'section_text_field.dart';

class FooterSectionForm extends StatelessWidget {
  const FooterSectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandingPageProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Footer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 16),
        SectionTextField(
          label: 'Footer Text',
          value: provider.draft.footerText,
          onChanged: (v) => provider.update(footerText: v),
        ),
      ],
    );
  }
}
