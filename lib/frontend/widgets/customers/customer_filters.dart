import 'package:erp_software/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomerFilters extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onReset;

  const CustomerFilters({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  @override
  State<CustomerFilters> createState() => _CustomerFiltersState();
}

class _CustomerFiltersState extends State<CustomerFilters> {
  final TextEditingController searchController =
      TextEditingController();

  String filter = 'All';
  String sort = 'DEFAULT';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // SEARCH
          TextField(
            controller: searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DropdownButton(
                  icon: Icons.filter_alt_outlined,
                  title: 'Filter: $filter',
                  onTap: _showFilterMenu,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _DropdownButton(
                  icon: Icons.arrow_downward,
                  title: 'Sort: $sort',
                  onTap: _showSortMenu,
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                height: 48,
                width: 48,
                child: OutlinedButton(
                  onPressed: () {
                    searchController.clear();

                    setState(() {
                      filter = 'All';
                      sort = 'DEFAULT';
                    });

                    widget.onReset();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Filter Customers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _menuItem('All'),
              _menuItem('Active'),
              _menuItem('Inactive'),
            ],
          ),
        );
      },
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Sort Customers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _sortItem('DEFAULT'),
              _sortItem('NAME A-Z'),
              _sortItem('NAME Z-A'),
              _sortItem('NEWEST'),
            ],
          ),
        );
      },
    );
  }

  Widget _menuItem(String value) {
    return ListTile(
      title: Text(value),
      onTap: () {
        setState(() {
          filter = value;
        });

        widget.onFilterChanged(value);

        Navigator.pop(context);
      },
    );
  }

  Widget _sortItem(String value) {
    return ListTile(
      title: Text(value),
      onTap: () {
        setState(() {
          sort = value;
        });

        widget.onSortChanged(value);

        Navigator.pop(context);
      },
    );
  }
}

class _DropdownButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DropdownButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        side: const BorderSide(
          color: AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),

          const Icon(
            Icons.keyboard_arrow_down,
            size: 17,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
