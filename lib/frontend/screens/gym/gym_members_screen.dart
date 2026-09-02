import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_member_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/gym/add_edit_member_dialog.dart';
import 'package:erp_software/frontend/widgets/gym/member_details_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymMembersScreen extends StatefulWidget {
  final String initialFilter;

  const GymMembersScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<GymMembersScreen> createState() => _GymMembersScreenState();
}

class _GymMembersScreenState extends State<GymMembersScreen> {
  final GymApiService gymService = GymApiService();

  List<GymMemberModel> _allMembers = [];
  List<GymMemberModel> _filteredMembers = [];

  String _searchQuery = '';
  late String _selectedTab;
  String _selectedSort = 'NEWEST';
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialFilter;
    loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final members = await gymService.getMembers();
      if (!mounted) return;
      setState(() {
        _allMembers = members;
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
    List<GymMemberModel> list = List.from(_allMembers);

    // Tab Filter
    if (_selectedTab == 'Active') {
      list = list.where((m) => m.isActive).toList();
    } else if (_selectedTab == 'Expired') {
      list = list.where((m) => m.isExpired).toList();
    } else if (_selectedTab == 'Expiring Soon') {
      list = list.where((m) => m.isExpiringSoon).toList();
    }

    // Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((m) {
        return m.name.toLowerCase().contains(q) ||
            m.memberCode.toLowerCase().contains(q) ||
            m.phone.toLowerCase().contains(q) ||
            (m.email?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'NAME A-Z':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'NAME Z-A':
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'DAYS REMAINING':
        list.sort((a, b) => (a.daysRemaining ?? 999).compareTo(b.daysRemaining ?? 999));
        break;
      case 'NEWEST':
      default:
        list.sort((a, b) {
          final aDate = a.createdAt ?? a.joinDate;
          final bDate = b.createdAt ?? b.joinDate;
          return bDate.compareTo(aDate);
        });
        break;
    }

    setState(() {
      _filteredMembers = list;
    });
  }

  Future<void> _deleteMember(GymMemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Member', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${member.name}" (${member.memberCode})? This will delete associated membership and attendance records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await gymService.deleteMember(member.id!);
        if (!mounted) return;
        ErpToast.showSuccess(context, 'Member deleted successfully');
        loadMembers();
      } catch (e) {
        if (!mounted) return;
        ErpToast.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const HamburgerButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Gym Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            tooltip: 'Add Member',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddEditMemberDialog(onSaved: loadMembers),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadMembers,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Members List',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Manage member registrations, plans, and attendance', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddEditMemberDialog(onSaved: loadMembers),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Register New Member'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

                          // Search & Filter Card
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
                                // Tab Buttons Row
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildTabPill('All', _allMembers.length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('Active', _allMembers.where((m) => m.isActive).length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('Expiring Soon', _allMembers.where((m) => m.isExpiringSoon).length),
                                      const SizedBox(width: 8),
                                      _buildTabPill('Expired', _allMembers.where((m) => m.isExpired).length),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Search input & Sort
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (v) {
                                          setState(() => _searchQuery = v);
                                          _applyFilters();
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Search members by name, code, phone...',
                                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                          prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 20),
                                          suffixIcon: _searchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear, size: 16),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() => _searchQuery = '');
                                                    _applyFilters();
                                                  },
                                                )
                                              : null,
                                          filled: true,
                                          fillColor: const Color(0xFFFAFAFA),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildSortDropdown(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Members List / Table
                          if (_isLoading) ...[
                            const Center(
                              child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)),
                            ),
                          ] else if (_error != null) ...[
                            _buildErrorBanner(),
                          ] else if (_filteredMembers.isEmpty) ...[
                            _buildEmptyState(),
                          ] else ...[
                            _buildMembersTable(isMobile),
                          ],
                        ],
                      ),
                    ),
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
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSort,
          icon: const Icon(Icons.sort, size: 18, color: Color(0xFF2563EB)),
          items: const [
            DropdownMenuItem(value: 'NEWEST', child: Text('Sort: Newest', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            DropdownMenuItem(value: 'NAME A-Z', child: Text('Sort: Name A-Z', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            DropdownMenuItem(value: 'NAME Z-A', child: Text('Sort: Name Z-A', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            DropdownMenuItem(value: 'DAYS REMAINING', child: Text('Sort: Expiry Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ],
          onChanged: (v) {
            setState(() => _selectedSort = v ?? 'NEWEST');
            _applyFilters();
          },
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
          TextButton(onPressed: loadMembers, child: const Text('Retry')),
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
            child: const Icon(Icons.person_search_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No members found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Try adjusting search filters or register a new member profile.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(context: context, builder: (_) => AddEditMemberDialog(onSaved: loadMembers));
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Member'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTable(bool isMobile) {
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
        itemCount: _filteredMembers.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final m = _filteredMembers[index];

          return InkWell(
            onTap: () {
              if (m.id != null) {
                showDialog(
                  context: context,
                  builder: (_) => MemberDetailsDialog(memberId: m.id!, onUpdated: loadMembers),
                );
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('Code: ${m.memberCode}  •  ${m.phone}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      _buildStatusBadge(m.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fitness_center_rounded, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            m.currentPlanName ?? 'No Active Plan',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF334155)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          m.currentMembershipEndDate != null
                              ? 'Expires: ${m.currentMembershipEndDate!.toIso8601String().split('T').first} (${m.daysRemaining}d)'
                              : 'Joined: ${m.joinDate.toIso8601String().split('T').first}',
                          style: TextStyle(
                            fontSize: 11,
                            color: m.isExpiringSoon ? const Color(0xFFD97706) : (m.isExpired ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                            fontWeight: m.isExpiringSoon || m.isExpired ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        icon: const Icon(Icons.visibility_outlined, size: 15),
                        label: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          if (m.id != null) {
                            showDialog(
                              context: context,
                              builder: (_) => MemberDetailsDialog(memberId: m.id!, onUpdated: loadMembers),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddEditMemberDialog(member: m, onSaved: loadMembers),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        icon: const Icon(Icons.delete_outline, size: 15),
                        label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _deleteMember(m),
                      ),
                    ],
                  ),
                ],
              ),
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
        bg = AppColors.dangerLight;
        text = AppColors.dangerText;
        break;
      case 'SUSPENDED':
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
