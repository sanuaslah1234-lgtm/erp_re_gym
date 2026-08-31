import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _controller;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  final List<Map<String, String>> _presets = [
    {
      'label': 'Wi-Fi LAN (Current PC)',
      'url': 'http://192.168.1.18:5000',
      'icon': 'wifi',
    },
    {
      'label': 'Android Emulator',
      'url': 'http://10.0.2.2:5000',
      'icon': 'phone_android',
    },
    {
      'label': 'Localhost / USB ADB',
      'url': 'http://localhost:5000',
      'icon': 'computer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: AppConstants.apiBaseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final uri = Uri.parse(url.endsWith('/') ? '${url}api/health' : '$url/api/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        setState(() {
          _isTesting = false;
          _testSuccess = true;
          _testResult = 'Connected successfully! (HTTP 200 OK)';
        });
      } else {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _testResult = 'Server returned status ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testResult = 'Connection failed: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _save() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    AppConstants.setBaseUrl(url);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_api_base_url', AppConstants.apiBaseUrl);
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pop();
    ErpToast.showSuccess(
      context,
      'Server URL set to: ${AppConstants.apiBaseUrl}',
      title: 'Server Config Updated',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E293B),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dns_rounded, color: Color(0xFF60A5FA), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend Server URL',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Configure host address for mobile / desktop',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Server URL Input
            const Text(
              'Server Base URL (IP:Port)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. http://192.168.1.18:5000',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF60A5FA), size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                  onPressed: () => _controller.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Presets
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final isSelected = _controller.text.trim() == preset['url'];
                return ActionChip(
                  backgroundColor: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                  side: BorderSide(color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF334155)),
                  avatar: Icon(
                    preset['icon'] == 'wifi'
                        ? Icons.wifi
                        : (preset['icon'] == 'phone_android' ? Icons.phone_android : Icons.computer),
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  ),
                  label: Text(
                    preset['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.text = preset['url']!;
                      _testResult = null;
                    });
                  },
                );
              }).toList(),
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _testSuccess
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                      size: 18,
                      color: _testSuccess ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.speed_rounded, size: 16),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCBD5E1),
                    side: const BorderSide(color: Color(0xFF475569)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Save & Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
