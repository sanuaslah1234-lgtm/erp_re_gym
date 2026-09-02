import 'package:erp_software/frontend/widgets/common/hamburger_button.dart';
import 'package:flutter/material.dart';
import 'package:erp_software/core/models/gym/gym_plan_model.dart';
import 'package:erp_software/frontend/services/gym/gym_service.dart';
import 'package:erp_software/frontend/widgets/gym/add_edit_plan_dialog.dart';
import 'package:erp_software/frontend/widgets/erp_toast.dart';
import 'package:erp_software/theme/app_colors.dart';

class GymPlansScreen extends StatefulWidget {
  final String initialTab;

  const GymPlansScreen({
    super.key,
    this.initialTab = 'All',
  });

  @override
  State<GymPlansScreen> createState() => _GymPlansScreenState();
}

class _GymPlansScreenState extends State<GymPlansScreen> {
  final GymApiService gymService = GymApiService();

  List<GymPlanModel> _allPlans = [];
  List<GymPlanModel> _filteredPlans = [];

  late String _selectedTab;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    loadPlans();
  }

  Future<void> loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await gymService.getPlans();
      if (!mounted) return;
      setState(() {
        _allPlans = list;
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
    // Exclude inactive / soft-deleted plans from the visible list
    List<GymPlanModel> list = _allPlans.where((p) => p.status != 'INACTIVE').toList();

    if (_selectedTab == 'Monthly') {
      list = list.where((p) => p.durationDays <= 30).toList();
    } else if (_selectedTab == 'Quarterly') {
      list = list.where((p) => p.durationDays > 30 && p.durationDays <= 90).toList();
    } else if (_selectedTab == 'Half-Yearly') {
      list = list.where((p) => p.durationDays > 90 && p.durationDays <= 180).toList();
    } else if (_selectedTab == 'Yearly') {
      list = list.where((p) => p.durationDays > 180).toList();
    }

    setState(() {
      _filteredPlans = list;
    });
  }

  Future<void> _deletePlan(GymPlanModel plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          plan.status == 'INACTIVE'
              ? 'Are you sure you want to remove the plan "${plan.name}"?'
              : 'Are you sure you want to delete the plan "${plan.name}"?\n\nIf existing member subscriptions are linked to this plan, it will be safely deactivated/archived to preserve member history.',
        ),
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
        final result = await gymService.deletePlan(plan.id!);
        if (!mounted) return;
        final msg = result['message']?.toString() ?? 'Plan processed successfully';
        final isArchived = result['data']?['archived'] == true || result['archived'] == true;
        if (isArchived) {
          ErpToast.showInfo(context, msg, title: 'Plan Deactivated');
        } else {
          ErpToast.showSuccess(context, msg, title: 'Plan Deleted');
        }
        loadPlans();
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
        title: const Text('Gym Plans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Plan',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddEditPlanDialog(onSaved: loadPlans),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadPlans,
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
                    'Membership Plans',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Create and manage pricing tiers, duration, and discounts', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddEditPlanDialog(onSaved: loadPlans),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create New Plan'),
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

              // Tab Filter Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabPill('All', _allPlans.length),
                    const SizedBox(width: 8),
                    _buildTabPill('Monthly', _allPlans.where((p) => p.durationDays <= 30).length),
                    const SizedBox(width: 8),
                    _buildTabPill('Quarterly', _allPlans.where((p) => p.durationDays > 30 && p.durationDays <= 90).length),
                    const SizedBox(width: 8),
                    _buildTabPill('Half-Yearly', _allPlans.where((p) => p.durationDays > 90 && p.durationDays <= 180).length),
                    const SizedBox(width: 8),
                    _buildTabPill('Yearly', _allPlans.where((p) => p.durationDays > 180).length),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoading) ...[
                const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.primary)))
              ] else if (_error != null) ...[
                _buildErrorBanner(),
              ] else if (_filteredPlans.isEmpty) ...[
                _buildEmptyState(),
              ] else ...[
                _buildPlansGrid(isMobile),
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
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
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
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
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
          TextButton(onPressed: loadPlans, child: const Text('Retry')),
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
            child: const Icon(Icons.fitness_center_rounded, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          const Text('No membership plans found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Create standard or customized membership plans to begin enrolling members.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildPlansGrid(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _filteredPlans.map((plan) {
            return SizedBox(
              width: cardWidth,
              child: _buildPlanCard(plan),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPlanCard(GymPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: Text('${plan.durationDays} Days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: plan.status == 'ACTIVE' ? AppColors.successLight : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: plan.status == 'ACTIVE' ? AppColors.successText : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            plan.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            plan.description ?? 'Full gym access with standard equipment and locker facilities.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Price Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${plan.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${plan.durationDays} days',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),

          if (plan.discount > 0) ...[
            const SizedBox(height: 4),
            Text('Base: \$${plan.price.toStringAsFixed(0)}  •  Discount: -\$${plan.discount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A))),
          ],

          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                tooltip: 'Edit Plan',
                onPressed: () {
                  showDialog(context: context, builder: (_) => AddEditPlanDialog(plan: plan, onSaved: loadPlans));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                tooltip: 'Delete Plan',
                onPressed: () => _deletePlan(plan),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
