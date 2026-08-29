import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ExpensesShimmerView extends StatelessWidget {
  final int itemCount;

  const ExpensesShimmerView({super.key, this.itemCount = 6});

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

  Widget _buildSummaryCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _box(width: 140, height: 14, radius: 4),
                    _box(width: 20, height: 20, radius: 6),
                  ],
                ),
                const SizedBox(height: 10),
                _box(width: 160, height: 28, radius: 6),
                const SizedBox(height: 8),
                _box(width: 90, height: 12, radius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChipsShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _box(width: 80 + (index % 3) * 20.0, height: 34, radius: 18),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildExpenseCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      elevation: 1,
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),

              // Expense Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _box(width: 60, height: 16, radius: 4),
                        const SizedBox(width: 8),
                        _box(width: 70, height: 12, radius: 3),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _box(width: 140, height: 15, radius: 4),
                    const SizedBox(height: 4),
                    _box(width: 100, height: 12, radius: 3),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Amount & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _box(width: 70, height: 16, radius: 4),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _box(width: 18, height: 18, radius: 4),
                      const SizedBox(width: 8),
                      _box(width: 18, height: 18, radius: 4),
                    ],
                  ),
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
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildSummaryCardShimmer(context),
        ),
        SliverToBoxAdapter(
          child: _buildCategoryChipsShimmer(context),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 8),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, _) => _buildExpenseCardShimmer(context),
              childCount: itemCount,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
}
