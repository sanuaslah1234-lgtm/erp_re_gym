import 'package:flutter/material.dart';
import 'package:erp_software/core/models/branch_model.dart';
import 'branch_actions_menu.dart';
import 'status_badge.dart';

class BranchDataTable extends StatelessWidget {
  final List<BranchModel> branches;
  final dynamic branchProvider;

  const BranchDataTable({super.key, required this.branches, required this.branchProvider});

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFF8FAFC),
              child: const Row(
                children: [
                  SizedBox(width: 60, child: Text('CODE', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('BRANCH NAME', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('LOCATION', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('CONTACT', style: _headerStyle)),
                  SizedBox(width: 80, child: Text('STATUS', style: _headerStyle)),
                  SizedBox(width: 48, child: Text('')),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Rows
            ...List.generate(branches.length, (index) {
              final b = branches[index];
              final isLast = index == branches.length - 1;
              return _BranchRow(
                branch: b,
                branchProvider: branchProvider,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontWeight: FontWeight.w700,
  color: Color(0xFF64748B),
  fontSize: 10,
  letterSpacing: 0.8,
);

class _BranchRow extends StatefulWidget {
  final BranchModel branch;
  final dynamic branchProvider;
  final bool isLast;

  const _BranchRow({required this.branch, required this.branchProvider, this.isLast = false});

  @override
  State<_BranchRow> createState() => _BranchRowState();
}

class _BranchRowState extends State<_BranchRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.branch;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF8FAFC) : Colors.white,
          border: widget.isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Code
            SizedBox(
              width: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b.code,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name + Address
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.address,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // City, State
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_city_outlined, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${b.city}, ${b.state}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Phone + Email
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(b.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          b.email,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status
            SizedBox(width: 80, child: StatusBadge(isActive: b.isActive)),

            // Actions
            SizedBox(width: 48, child: BranchActionsMenu(branch: b, branchProvider: widget.branchProvider)),
          ],
        ),
      ),
    );
  }
}
