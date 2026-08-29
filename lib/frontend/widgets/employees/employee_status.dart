import 'package:flutter/material.dart';

import 'package:erp_software/theme/app_colors.dart';

class EmployeeStatus extends StatelessWidget {
  final bool verified;

  const EmployeeStatus({
    super.key,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        verified
            ? AppColors.successLight
            : AppColors.warningLight;

    final foreground =
        verified
            ? AppColors.successText
            : AppColors.warningText;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            verified
                ? 'Verified'
                : 'Pending',
            style:
                TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
