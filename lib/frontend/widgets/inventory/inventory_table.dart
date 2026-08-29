import 'package:flutter/material.dart';

import 'package:erp_software/core/models/inventory_model.dart';
import 'package:erp_software/frontend/widgets/inventory/inventory_product_card.dart';
import 'package:erp_software/frontend/widgets/inventory/inventory_status_badge.dart';
import 'package:erp_software/theme/app_colors.dart';

class InventoryTable extends StatelessWidget {
  final List<InventoryModel> items;

  final void Function(InventoryModel item) onView;
  final void Function(InventoryModel item) onEdit;
  final void Function(InventoryModel item) onDelete;

  const InventoryTable({
    super.key,
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyInventory();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return _MobileList(
            items: items,
            onView: onView,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }

        if (constraints.maxWidth < 1050) {
          return _TabletGrid(
            items: items,
            onView: onView,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }

        return _DesktopTable(
          items: items,
          onView: onView,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

/* ============================================================
   DESKTOP
   ============================================================ */

class _DesktopTable extends StatelessWidget {
  final List<InventoryModel> items;

  final void Function(InventoryModel item) onView;
  final void Function(InventoryModel item) onEdit;
  final void Function(InventoryModel item) onDelete;

  const _DesktopTable({
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          _TableHeader(
            count: items.length,
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          const _ColumnHeader(),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          ...List.generate(
            items.length,
            (index) {
              final item = items[index];

              return _TableRow(
                item: item,
                isLast:
                    index == items.length - 1,
                onView: () => onView(item),
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final int count;

  const _TableHeader({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        17,
        20,
        17,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage stock levels and product inventory',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count records',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: AppColors.surfaceSecondary,
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: _HeaderText('PRODUCT'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('SKU'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('WAREHOUSE'),
          ),
          Expanded(
            child: _HeaderText('QUANTITY'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('MIN / MAX'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('RECORD LEVEL'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('STATUS'),
          ),
          SizedBox(
            width: 100,
            child: _HeaderText('ACTION'),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 9,
        letterSpacing: .5,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final InventoryModel item;
  final bool isLast;

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TableRow({
    required this.item,
    required this.isLast,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 82,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.borderLight,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ProductInfo(
              item: item,
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              item.sku ?? 'No SKU',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.warehouse_outlined,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item.warehouse,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              '${item.minStock} / ${item.maxStock}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: _Level(
              item: item,
            ),
          ),

          Expanded(
            flex: 2,
            child: InventoryStatusBadge(
              status: item.status,
            ),
          ),

          SizedBox(
            width: 100,
            child: Row(
              children: [
                _IconAction(
                  icon: Icons.visibility_outlined,
                  onTap: onView,
                ),
                _IconAction(
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                ),
                _IconAction(
                  icon: Icons.delete_outline,
                  danger: true,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final InventoryModel item;

  const _ProductInfo({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                item.product,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                item.sku ?? 'No SKU',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Level extends StatelessWidget {
  final InventoryModel item;

  const _Level({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final value = item.maxStock <= 0
        ? 0.0
        : (item.quantity / item.maxStock)
            .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _color,
          ),
        ),

        const SizedBox(height: 5),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor:
                AppColors.neutralLight,
            valueColor:
                AlwaysStoppedAnimation<Color>(
              _color,
            ),
          ),
        ),
      ],
    );
  }

  Color get _color {
    if (item.quantity <= 0) {
      return AppColors.danger;
    }

    if (item.quantity <= item.minStock) {
      return AppColors.warning;
    }

    return AppColors.success;
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: danger ? 'Delete' : null,
      child: Material(
        color: danger
            ? AppColors.dangerLight
            : AppColors.neutralLight,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(
              right: 3,
            ),
            child: Icon(
              icon,
              size: 14,
              color: danger
                  ? AppColors.danger
                  : AppColors.neutralDark,
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   TABLET
   ============================================================ */

class _TabletGrid extends StatelessWidget {
  final List<InventoryModel> items;

  final void Function(InventoryModel item) onView;
  final void Function(InventoryModel item) onEdit;
  final void Function(InventoryModel item) onDelete;

  const _TabletGrid({
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileTableHeader(
          count: items.length,
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.42,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return InventoryProductCard(
              item: item,
              onView: () => onView(item),
              onEdit: () => onEdit(item),
              onDelete: () => onDelete(item),
            );
          },
        ),
      ],
    );
  }
}

/* ============================================================
   MOBILE
   ============================================================ */

class _MobileList extends StatelessWidget {
  final List<InventoryModel> items;

  final void Function(InventoryModel item) onView;
  final void Function(InventoryModel item) onEdit;
  final void Function(InventoryModel item) onDelete;

  const _MobileList({
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileTableHeader(
          count: items.length,
        ),

        const SizedBox(height: 10),

        ...List.generate(
          items.length,
          (index) {
            final item = items[index];

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: InventoryProductCard(
                item: item,
                onView: () => onView(item),
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MobileTableHeader extends StatelessWidget {
  final int count;

  const _MobileTableHeader({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Inventory stock records',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.neutralText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   EMPTY
   ============================================================ */

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 14),
          Text(
            'No inventory records found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try changing your filters or add inventory.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
