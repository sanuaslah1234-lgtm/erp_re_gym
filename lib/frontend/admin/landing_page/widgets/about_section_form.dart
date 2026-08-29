import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/landing_page_provider.dart';
import 'image_picker_field.dart';
import 'section_text_field.dart';

class AboutSectionForm extends StatelessWidget {
  const AboutSectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandingPageProvider>();
    final d = provider.draft;
    final isNarrow = MediaQuery.of(context).size.width < 700;

    final images = [
      ImagePickerField(label: 'About Image 1', base64Value: d.aboutImage1Base64, onChanged: (v) => provider.update(aboutImage1Base64: v)),
      ImagePickerField(label: 'About Image 2', base64Value: d.aboutImage2Base64, onChanged: (v) => provider.update(aboutImage2Base64: v)),
      ImagePickerField(label: 'About Image 3', base64Value: d.aboutImage3Base64, onChanged: (v) => provider.update(aboutImage3Base64: v)),
      ImagePickerField(label: 'About Image 4', base64Value: d.aboutImage4Base64, onChanged: (v) => provider.update(aboutImage4Base64: v)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 16),
        SectionTextField(label: 'About Tag', value: d.aboutTag, onChanged: (v) => provider.update(aboutTag: v)),
        const SizedBox(height: 16),
        SectionTextField(label: 'About Title', value: d.aboutTitle, onChanged: (v) => provider.update(aboutTitle: v)),
        const SizedBox(height: 16),
        SectionTextField(
          label: 'About Description',
          value: d.aboutDescription,
          onChanged: (v) => provider.update(aboutDescription: v),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        if (isNarrow)
          Column(
            children: [
              for (int i = 0; i < images.length; i++) ...[
                images[i],
                if (i != images.length - 1) const SizedBox(height: 16),
              ],
            ],
          )
        else
          Column(
            children: [
              Row(children: [Expanded(child: images[0]), const SizedBox(width: 20), Expanded(child: images[1])]),
              const SizedBox(height: 16),
              Row(children: [Expanded(child: images[2]), const SizedBox(width: 20), Expanded(child: images[3])]),
            ],
          ),
      ],
    );
  }
}
