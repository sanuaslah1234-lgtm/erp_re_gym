import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audit_log_provider.dart';

class AuditFiltersBar extends StatelessWidget {
  const AuditFiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditLogProvider>();
    final isNarrow = MediaQuery.of(context).size.width < 800;

    final searchField = TextField(
      onChanged: provider.setSearch,
      decoration: InputDecoration(
        hintText: 'Search employee name, email, ID...',
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );

    final actionDropdown = _dropdown(
      value: provider.selectedAction,
      items: AuditLogProvider.actionOptions,
      onChanged: provider.setAction,
    );

    final moduleDropdown = _dropdown(
      value: provider.selectedModule,
      items: AuditLogProvider.moduleOptions,
      onChanged: provider.setModule,
    );

    final resetButton = OutlinedButton(
      onPressed: provider.resetFilters,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Reset'),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 10),
          Row(children: [Expanded(child: actionDropdown), const SizedBox(width: 10), Expanded(child: moduleDropdown)]),
          const SizedBox(height: 10),
          resetButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: searchField),
        const SizedBox(width: 12),
        Expanded(child: actionDropdown),
        const SizedBox(width: 12),
        Expanded(child: moduleDropdown),
        const SizedBox(width: 12),
        resetButton,
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required void Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
