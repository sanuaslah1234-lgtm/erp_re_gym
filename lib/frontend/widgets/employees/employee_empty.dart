import 'package:flutter/material.dart';

class EmployeeEmpty extends StatelessWidget {
  const EmployeeEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 32,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'No employees found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Try changing your search or filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
