import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_membership_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/common/erp_sidebar.dart';
import 'package:erp_software/frontend/widgets/common/erp_topbar.dart';
import 'package:erp_software/frontend/widgets/gym/add_membership_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/renew_membership_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/member_details_dialog.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymMembershipsScreen extends StatefulWidget {
  final String initialTab;

  const GymMembershipsScreen({
    super.key,
    this.initialTab = 'All',
  });

  @override
  State<GymMembershipsScreen> createState() => _GymMembershipsScreenState();
}

class _GymMembershipsScreenState extends State<GymMembershipsScreen> {
  final GymApiService gymService = GymApiService();

  List<GymMembershipModel> _allMemberships = [];
  List<GymMembershipModel> _filteredMemberships = [];

  String _searchQuery = '';
  late String _selectedTab;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    loadMemberships();
  }

  Future<void> loadMemberships() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await gymService.getMemberships();
      if (!mounted) return;
      setState(() {
        _allMemberships = list;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<GymMembershipModel> list = List.from(_allMemberships);

    if (_selectedTab == 'Active') {
      list = list.where((m) => m.isActive && !m.isExpired).toList();
    } else if (_selectedTab == 'Expired') {
      list = list.where((m) => m.isExpired).toList();
    } else if (_selectedTab == 'Renewals') {
      list = list.where((m) => m.isExpired || m.daysLeft <= 7).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((m) {
        return (m.memberName?.toLowerCase().contains(q) ?? false) ||
            (m.memberCode?.toLowerCase().contains(q) ?? false) ||
            (m.planName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    setState(() {
      _filteredMemberships = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? const Drawer(child: ErpSidebar(activeItem: 'Memberships', isDrawer: true)) : null,
      body: Row(
        children: [
          if (!isMobile) const ErpSidebar(activeItem: 'Memberships'),
          Expanded(
            child: Column(
              children: [
                const ErpTopbar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadMemberships,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gym Memberships',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Track subscription active periods, renewals, and billing', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddMembershipDialog(onSaved: loadMemberships),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('+ New Membership'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Search & Tab Filters
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
                            ),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildTabPill('All', _allMemberships.length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('Active', _allMemberships.where((m) => m.isActive && !m.isExpired).length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('Renewals', _allMemberships.where((m) => m.isExpired || m.daysLeft <= 7).length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('Expired', _allMemberships.where((m) => m.isExpired).length),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  onChanged: (v) {
                                    setState(() => _searchQuery = v);
                                    _applyFilters();
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search memberships by member name, code, plan...',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 20),
                                    filled: true,
                                    fillColor: const Color(0xFFFAFAFA),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isLoading) ...[
                            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)))
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (_filteredMemberships.isEmpty) ...[
                            _buildEmptyState(),
                          ] else ...[
                            _buildMembershipsTable(isMobile),
                          ],
                        ],
                      ),
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

  Widget _buildTabPill(String title, int count) {
    final isSelected = _selectedTab == title;

    return InkWell(
      onTap: () {
        setState(() => _selectedTab = title);
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
          TextButton(onPressed: loadMemberships, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: const Icon(Icons.card_membership_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No memberships found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Activate a membership plan for an existing or new gym member.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildMembershipsTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredMemberships.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final ms = _filteredMemberships[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ms.isExpired ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.card_membership_rounded,
                    color: ms.isExpired ? const Color(0xFFEF4444) : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Member info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ms.memberName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('Code: ${ms.memberCode ?? '-'}  •  Plan: ${ms.planName ?? 'Standard'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),

                // Dates & Expiry
                if (!isMobile) ...[
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ms.startDate.toIso8601String().split('T').first}  →  ${ms.endDate.toIso8601String().split('T').first}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ms.isExpired ? 'Expired' : '${ms.daysLeft} days remaining',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ms.isExpired ? const Color(0xFFEF4444) : (ms.daysLeft <= 7 ? const Color(0xFFD97706) : const Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Amount
                Text(
                  '\$${ms.finalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 12),

                // Status
                _buildStatusBadge(ms.status),
                const SizedBox(width: 10),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => RenewMembershipDialog(membership: ms, onRenewed: loadMemberships),
                        );
                      },
                      icon: const Icon(Icons.autorenew_rounded, size: 16),
                      label: const Text('Renew', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline, size: 18, color: Color(0xFF64748B)),
                      tooltip: 'View Member',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => MemberDetailsDialog(memberId: ms.memberId, onUpdated: loadMemberships),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    switch (status.toUpperCase()) {
      case 'ACTIVE':
        bg = AppColors.successLight;
        text = AppColors.successText;
        break;
      case 'EXPIRED':
      case 'CANCELLED':
        bg = AppColors.dangerLight;
        text = AppColors.dangerText;
        break;
      case 'PENDING':
        bg = AppColors.warningLight;
        text = AppColors.warningText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }
}
