import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:erp_software/theme/app_colors.dart';

/// A real, working image picker: tap to choose a file from disk/gallery.
class ImagePickerField extends StatelessWidget {
  final String label;
  final String? base64Value;
  final void Function(String base64) onChanged;
  final double previewHeight;

  const ImagePickerField({
    super.key,
    required this.label,
    required this.base64Value,
    required this.onChanged,
    this.previewHeight = 140,
  });

  Future<void> _pick() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (file == null) return;

    final Uint8List bytes = await file.readAsBytes();
    onChanged(base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  base64Value != null ? 'Change file' : 'Choose file — No file chosen',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (base64Value != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              base64Decode(base64Value!),
              height: previewHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
