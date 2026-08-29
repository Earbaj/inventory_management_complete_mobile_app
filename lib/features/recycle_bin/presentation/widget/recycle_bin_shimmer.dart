import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecycleBinShimmerView extends StatelessWidget {
  final int itemCount;

  const RecycleBinShimmerView({
    super.key,
    this.itemCount = 6,
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

  Widget _buildCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Title, Badge & Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 140, height: 16, radius: 4),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _box(width: 80, height: 16, radius: 6),
                            const SizedBox(width: 8),
                            _box(width: 60, height: 14, radius: 4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subtitle
              _box(width: double.infinity, height: 12, radius: 3),
              const SizedBox(height: 6),
              _box(width: 180, height: 12, radius: 3),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer: Date & Action buttons
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 120, height: 12, radius: 3),
                        const SizedBox(height: 4),
                        _box(width: 80, height: 10, radius: 3),
                      ],
                    ),
                  ),
                  _box(width: 85, height: 32, radius: 10),
                  const SizedBox(width: 8),
                  _box(width: 32, height: 32, radius: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: itemCount,
      itemBuilder: (context, _) => _buildCardShimmer(context),
    );
  }
}
