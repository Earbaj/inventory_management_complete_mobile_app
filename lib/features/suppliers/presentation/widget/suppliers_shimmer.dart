import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SuppliersShimmerView extends StatelessWidget {
  final int itemCount;
  final bool isPurchaseOrder;

  const SuppliersShimmerView({
    super.key,
    this.itemCount = 6,
    this.isPurchaseOrder = false,
  });

  Widget _box({double? width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildSupplierCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Name, Company, Action
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 130, height: 16, radius: 4),
                        const SizedBox(height: 6),
                        _box(width: 90, height: 12, radius: 3),
                      ],
                    ),
                  ),
                  _box(width: 16, height: 20, radius: 4),
                ],
              ),
              const SizedBox(height: 12),

              // Contact Info
              Row(
                children: [
                  _box(width: 80, height: 12, radius: 3),
                  const SizedBox(width: 8),
                  _box(width: 120, height: 12, radius: 3),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Total Purchases & Due Boxes
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseOrderCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(width: 100, height: 14, radius: 4),
                  _box(width: 70, height: 12, radius: 3),
                ],
              ),
              const SizedBox(height: 8),
              _box(width: 150, height: 16, radius: 4),
              const SizedBox(height: 8),
              _box(width: double.infinity, height: 32, radius: 6),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(width: 80, height: 14, radius: 3),
                  _box(width: 80, height: 14, radius: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, _) => isPurchaseOrder
          ? _buildPurchaseOrderCardShimmer(context)
          : _buildSupplierCardShimmer(context),
    );
  }
}
