import 'package:flutter/material.dart';

import 'package:erp_software/core/models/inventory_model.dart';
import 'package:erp_software/frontend/widgets/inventory/inventory_status_badge.dart';
import 'package:erp_software/theme/app_colors.dart';

class InventoryProductCard extends StatelessWidget {
  final InventoryModel item;

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryProductCard({
    super.key,
    required this.item,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // PRODUCT HEADER
          // =====================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProductIcon(),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.isEmpty
                          ? 'Unknown Product'
                          : item.product,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutralLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (item.sku?.isEmpty ?? true)
                            ? 'No SKU'
                            : item.sku!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Don't use Flexible here.
              // The badge has a fixed natural width.
              InventoryStatusBadge(
                status: item.status,
              ),
            ],
          ),

          const SizedBox(height: 15),

          // =====================================================
          // STOCK METRICS
          // =====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                _Metric(
                  label: 'Quantity',
                  value: '${item.quantity}',
                  valueColor: _quantityColor,
                ),

                const _VerticalDivider(),

                _Metric(
                  label: 'Min Stock',
                  value: '${item.minStock}',
                ),

                const _VerticalDivider(),

                _Metric(
                  label: 'Max Stock',
                  value: '${item.maxStock}',
                ),

                const _VerticalDivider(),

                _Metric(
                  label: 'Reorder',
                  value: '${item.reorderLevel}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          // =====================================================
          // WAREHOUSE + REORDER LEVEL
          // =====================================================

          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warehouse_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warehouse',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.warehouse.isEmpty
                          ? 'Unknown Warehouse'
                          : item.warehouse,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              _StockLevelLabel(
                item: item,
              ),
            ],
          ),

          const SizedBox(height: 11),

          // =====================================================
          // STOCK PROGRESS
          // =====================================================

          _StockProgress(
            item: item,
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.quantity} units',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${item.maxStock} max',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =====================================================
          // ACTIONS
          // =====================================================

          Row(
            children: [
              Expanded(
                child: _CardAction(
                  icon: Icons.visibility_outlined,
                  label: 'View',
                  onTap: onView,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _CardAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: onEdit,
                ),
              ),

              const SizedBox(width: 7),

              _DeleteButton(
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // QUANTITY COLOR
  // ===========================================================

  Color get _quantityColor {
    if (item.quantity <= 0) {
      return AppColors.danger;
    }

    if (item.quantity <= item.minStock) {
      return AppColors.warningDark;
    }

    return AppColors.success;
  }
}


// =============================================================
// PRODUCT ICON
// =============================================================

class _ProductIcon extends StatelessWidget {
  const _ProductIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}


// =============================================================
// METRIC
// =============================================================

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Metric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color:
                  valueColor ??
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// VERTICAL DIVIDER
// =============================================================

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
    );
  }
}


// =============================================================
// STOCK LEVEL LABEL
// =============================================================

class _StockLevelLabel extends StatelessWidget {
  final InventoryModel item;

  const _StockLevelLabel({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;

    if (item.quantity <= 0) {
      color = AppColors.danger;
      text = 'Urgent';
    } else if (item.quantity <= item.minStock) {
      color = AppColors.warningDark;
      text = 'Reorder';
    } else if (item.quantity >= item.maxStock) {
      color = AppColors.infoDark;
      text = 'Full';
    } else {
      color = AppColors.success;
      text = 'Optimal';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}


// =============================================================
// STOCK PROGRESS
// =============================================================

class _StockProgress extends StatelessWidget {
  final InventoryModel item;

  const _StockProgress({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final double value;

    if (item.maxStock <= 0) {
      value = 0;
    } else {
      value = (item.quantity / item.maxStock)
          .clamp(0.0, 1.0);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor:
            AppColors.neutralLight,
        valueColor:
            AlwaysStoppedAnimation<Color>(
          _color,
        ),
      ),
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


// =============================================================
// CARD ACTION
// =============================================================

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutralLight,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.neutralDark,
              ),

              const SizedBox(width: 5),

              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================
// DELETE BUTTON
// =============================================================

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerLight,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: const SizedBox(
          width: 42,
          height: 36,
          child: Icon(
            Icons.delete_outline,
            size: 17,
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }
}
