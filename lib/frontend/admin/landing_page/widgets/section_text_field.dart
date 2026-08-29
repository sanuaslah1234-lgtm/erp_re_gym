import 'package:flutter/material.dart';
import 'package:erp_software/theme/app_colors.dart';

/// A plain text field bound to provider state.
class SectionTextField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;
  final int maxLines;
  final TextInputType? keyboardType;

  const SectionTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  State<SectionTextField> createState() => _SectionTextFieldState();
}

class _SectionTextFieldState extends State<SectionTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SectionTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
