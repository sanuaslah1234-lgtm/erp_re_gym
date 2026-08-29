import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/landing_page_provider.dart';
import 'section_text_field.dart';

class NavbarSectionForm extends StatelessWidget {
  const NavbarSectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandingPageProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Navbar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 16),
        SectionTextField(
          label: 'Logo Text',
          value: provider.draft.logoText,
          onChanged: (v) => provider.update(logoText: v),
        ),
        const SizedBox(height: 16),
        SectionTextField(
          label: 'Logo Highlight',
          value: provider.draft.logoHighlight,
          onChanged: (v) => provider.update(logoHighlight: v),
        ),
        const SizedBox(height: 16),
        SectionTextField(
          label: 'Login Button Text',
          value: provider.draft.loginButtonText,
          onChanged: (v) => provider.update(loginButtonText: v),
        ),
      ],
    );
  }
}
