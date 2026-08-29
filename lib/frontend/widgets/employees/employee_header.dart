import 'package:flutter/material.dart';

class EmployeeHeader extends StatelessWidget {
  final VoidCallback onAdd;

  const EmployeeHeader({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employees',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage employees and roles',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onAdd,
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
