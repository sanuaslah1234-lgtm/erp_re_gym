import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_software/core/constants/app_constants.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class _Role {
  final String id;
  final String name;
  final String description;
  _Role({required this.id, required this.name, required this.description});
  factory _Role.fromJson(Map<String, dynamic> json) => _Role(
    id: json['id'].toString(),
    name: (json['name'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
  );
}

class DesignationsRolesScreen extends StatefulWidget {
  const DesignationsRolesScreen({super.key});

  @override
  State<DesignationsRolesScreen> createState() => _DesignationsRolesScreenState();
}

class _DesignationsRolesScreenState extends State<DesignationsRolesScreen> {
  List<_Role> _roles = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('${AppConstants.apiBaseUrl}/api/roles'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        if (mounted) setState(() { _roles = data.map((e) => _Role.fromJson(e)).toList(); _isLoading = false; });
      } else {
        if (mounted) setState(() { _error = 'Failed to load roles (${res.statusCode})'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  List<_Role> get _filtered {
    if (_search.isEmpty) return _roles;
    final q = _search.toLowerCase();
    return _roles.where((r) => r.name.toLowerCase().contains(q) || r.description.toLowerCase().contains(q)).toList();
  }

  IconData _roleIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('admin')) return Icons.admin_panel_settings;
    if (lower.contains('manager')) return Icons.manage_accounts;
    if (lower.contains('cashier')) return Icons.point_of_sale;
    if (lower.contains('employee')) return Icons.person;
    if (lower.contains('gym')) return Icons.fitness_center;
    if (lower.contains('warehouse')) return Icons.warehouse;
    return Icons.badge;
  }

  Color _roleColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFFEF4444);
    if (lower.contains('manager')) return const Color(0xFFF59E0B);
    if (lower.contains('cashier')) return const Color(0xFF10B981);
    if (lower.contains('gym')) return const Color(0xFF8B5CF6);
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0, title: const Text('Roles appBar: AppBar(leading: const HamburgerButton(), backgroundColor: Colors.white, elevation: 0), Designations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Designations & Roles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Manage user roles and permission assignments', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
                          child: Row(children: [
                            Expanded(child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(hintText: 'Search roles...', prefixIcon: const Icon(Icons.search, size: 18), isDense: true, filled: true, fillColor: AppColors.surfaceSecondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            )),
                            const SizedBox(width: 8),
                            Text('${_filtered.length} role${_filtered.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _loadRoles),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                        else if (_error != null)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.danger)),
                            child: Column(children: [
                              const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(onPressed: _loadRoles, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                            ]),
                          )
                        else if (_filtered.isEmpty)
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                            child: Column(children: const [
                              Icon(Icons.badge_outlined, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 14),
                              Text('No roles found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            ]),
                          )
                        else
                          _buildGrid(_filtered),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_Role> roles) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: roles.map((role) {
        final color = _roleColor(role.name);
        return Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppShadows.soft),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_roleIcon(role.name), color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(role.description.isNotEmpty ? role.description : 'No description', style: TextStyle(fontSize: 12, color: role.description.isNotEmpty ? AppColors.textSecondary : AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
