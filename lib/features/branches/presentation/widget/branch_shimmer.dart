import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BranchShimmerView extends StatelessWidget {
  final int itemCount;

  const BranchShimmerView({super.key, this.itemCount = 6});

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

  Widget _buildBranchCardShimmer(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Store Icon Placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Address & Phone Placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 140, height: 16, radius: 4),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _box(width: 14, height: 14, radius: 3),
                        const SizedBox(width: 6),
                        _box(width: 130, height: 12, radius: 3),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _box(width: 14, height: 14, radius: 3),
                        const SizedBox(width: 6),
                        _box(width: 90, height: 12, radius: 3),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge Placeholder
              _box(width: 50, height: 22, radius: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, _) => _buildBranchCardShimmer(context),
    );
  }
}
