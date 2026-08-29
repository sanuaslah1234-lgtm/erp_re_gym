import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:erp_software/theme/app_colors.dart';

import '../providers/settings_provider.dart';

class BusinessProfileForm extends StatefulWidget {
  const BusinessProfileForm({super.key});

  @override
  State<BusinessProfileForm> createState() => _BusinessProfileFormState();
}

class _BusinessProfileFormState extends State<BusinessProfileForm> {
  late TextEditingController _companyNameCtrl;
  late TextEditingController _legalNameCtrl;
  late TextEditingController _taxNumberCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  bool _controllersInitialized = false;
  String? _lastSyncedLogo;

  @override
  void dispose() {
    if (_controllersInitialized) {
      _companyNameCtrl.dispose();
      _legalNameCtrl.dispose();
      _taxNumberCtrl.dispose();
      _emailCtrl.dispose();
      _phoneCtrl.dispose();
      _addressCtrl.dispose();
    }
    super.dispose();
  }

  void _initControllers(SettingsProvider provider) {
    _companyNameCtrl = TextEditingController(text: provider.draft.companyName)
      ..addListener(() => provider.updateDraft(companyName: _companyNameCtrl.text));
    _legalNameCtrl = TextEditingController(text: provider.draft.legalTradeName)
      ..addListener(() => provider.updateDraft(legalTradeName: _legalNameCtrl.text));
    _taxNumberCtrl = TextEditingController(text: provider.draft.taxVatNumber)
      ..addListener(() => provider.updateDraft(taxVatNumber: _taxNumberCtrl.text));
    _emailCtrl = TextEditingController(text: provider.draft.officialEmail)
      ..addListener(() => provider.updateDraft(officialEmail: _emailCtrl.text));
    _phoneCtrl = TextEditingController(text: provider.draft.businessPhone)
      ..addListener(() => provider.updateDraft(businessPhone: _phoneCtrl.text));
    _addressCtrl = TextEditingController(text: provider.draft.headquartersAddress)
      ..addListener(() => provider.updateDraft(headquartersAddress: _addressCtrl.text));
    _controllersInitialized = true;
    _lastSyncedLogo = provider.draft.companyLogoBase64;
  }

  Future<void> _pickLogo(SettingsProvider provider) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;

    final Uint8List bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    provider.updateDraft(companyLogoBase64: base64Str);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    if (!_controllersInitialized) {
      _initControllers(provider);
    } else if (provider.draft.companyLogoBase64 != _lastSyncedLogo &&
        provider.draft.companyName == _companyNameCtrl.text) {
      _companyNameCtrl.text = provider.draft.companyName;
      _legalNameCtrl.text = provider.draft.legalTradeName;
      _taxNumberCtrl.text = provider.draft.taxVatNumber;
      _emailCtrl.text = provider.draft.officialEmail;
      _phoneCtrl.text = provider.draft.businessPhone;
      _addressCtrl.text = provider.draft.headquartersAddress;
      _lastSyncedLogo = provider.draft.companyLogoBase64;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Business Details & Identity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Company branding, tax registration, contact information, and main address.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        const Divider(color: AppColors.border),
        const SizedBox(height: 20),
        const Text('Company Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: provider.draft.companyLogoBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(provider.draft.companyLogoBase64!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickLogo(provider),
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: const Text('Upload New Logo'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Recommended format: PNG, JPG, or SVG (Max 5MB).',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _row([
          _field('Company Name *', _companyNameCtrl),
          _field('Legal / Trade Name', _legalNameCtrl),
        ]),
        const SizedBox(height: 16),
        _row([
          _field('Tax / VAT Registration Number', _taxNumberCtrl),
          _field('Official Business Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
        ]),
        const SizedBox(height: 16),
        _row([
          _field('Business Phone Number', _phoneCtrl, keyboardType: TextInputType.phone),
          const SizedBox.shrink(),
        ]),
        const SizedBox(height: 16),
        _field('Headquarters Address', _addressCtrl, maxLines: 3),
      ],
    );
  }

  Widget _row(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 560;
      if (isNarrow) {
        return Column(children: [
          children[0],
          const SizedBox(height: 16),
          children[1],
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: children[0]),
        const SizedBox(width: 20),
        Expanded(child: children[1]),
      ]);
    });
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
