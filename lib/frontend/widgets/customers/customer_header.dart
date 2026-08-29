import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomersHeader extends StatelessWidget {
  const CustomersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration:  BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              size: 28,
              color: AppColors.white
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E6EB),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 14),

                  Icon(
                    Icons.search,
                    color: Color(0xFF718096),
                    size: 23,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Search ERP Enterprise Ltd...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A929D),
                      ),
                      
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF425466),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2864D7),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AU',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 4),

          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF718096),
          ),
        ],
      ),
    );
  }
}
