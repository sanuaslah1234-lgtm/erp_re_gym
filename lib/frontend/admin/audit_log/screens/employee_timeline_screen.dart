import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audit_log_provider.dart';
import '../widgets/timeline_entry_tile.dart';

class EmployeeTimelineScreen extends StatefulWidget {
  final int employeeDbId;

  const EmployeeTimelineScreen({super.key, required this.employeeDbId});

  @override
  State<EmployeeTimelineScreen> createState() => _EmployeeTimelineScreenState();
}

class _EmployeeTimelineScreenState extends State<EmployeeTimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditLogProvider>().fetchEmployeeTimeline(widget.employeeDbId);
    });
  }

  @override
  void dispose() {
    // Clear so re-opening the list screen doesn't briefly show stale data.
    context.read<AuditLogProvider>().clearTimeline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditLogProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Employee Activity Timeline'),
      ),
      body: _body(provider),
    );
  }

  Widget _body(AuditLogProvider provider) {
    if (provider.isTimelineLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.timelineError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(provider.timelineError!, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => provider.fetchEmployeeTimeline(widget.employeeDbId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final page = provider.timeline;
    if (page == null) return const SizedBox.shrink();

    final grouped = page.groupedByDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to All Audit Logs'),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF6D28D9),
                  child: Text(
                    page.employee.fullName.isNotEmpty
                        ? page.employee.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page.employee.fullName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(page.employee.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Employee ID: ${page.employee.employeeId}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                _statBlock(page.stats.totalActivities, 'Total Activities'),
                const SizedBox(width: 20),
                _statBlock(page.stats.logins, 'Logins'),
                const SizedBox(width: 20),
                _statBlock(page.stats.updates, 'Updates'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (grouped.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text('No activity recorded yet.', style: TextStyle(color: Colors.grey.shade600)),
              ),
            )
          else
            ...grouped.entries.map((group) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 14, top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(group.key,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    ...group.value.map((entry) => TimelineEntryTile(entry: entry)),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _statBlock(int value, String label) {
    return Column(
      children: [
        Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
