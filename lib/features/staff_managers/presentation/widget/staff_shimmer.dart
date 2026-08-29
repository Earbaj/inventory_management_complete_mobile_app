import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StaffShimmerView extends StatelessWidget {
  final int itemCount;

  const StaffShimmerView({super.key, this.itemCount = 6});

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

  Widget _buildStaffCardShimmer(BuildContext context) {
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
              // Top Row: Avatar, Name, Role Badge, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 130, height: 16, radius: 4),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _box(width: 70, height: 20, radius: 6),
                            const SizedBox(width: 6),
                            _box(width: 60, height: 20, radius: 6),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons placeholders
                  _box(width: 24, height: 24, radius: 12),
                  const SizedBox(width: 8),
                  _box(width: 24, height: 24, radius: 12),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Contact Details & Branch
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 120, height: 12, radius: 3),
                        const SizedBox(height: 6),
                        _box(width: 90, height: 12, radius: 3),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 100, height: 12, radius: 3),
                        const SizedBox(height: 6),
                        _box(width: 80, height: 12, radius: 3),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Joined date placeholder
              _box(width: 110, height: 10, radius: 3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, _) => _buildStaffCardShimmer(context),
    );
  }
}
