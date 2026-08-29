import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomerShimmerView extends StatelessWidget {
  final int itemCount;

  const CustomerShimmerView({super.key, this.itemCount = 6});

  // ছোট শিমার বক্স তৈরির সহজ হেল্পার
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

  // কাস্টমার কার্ড অনুযায়ী সিম্পল শিমার কার্ড
  Widget _buildCustomerCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
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
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name, Phone & Address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 130, height: 16, radius: 4),
                        const SizedBox(height: 8),
                        _box(width: 100, height: 12, radius: 4),
                        const SizedBox(height: 6),
                        _box(width: 140, height: 12, radius: 4),
                      ],
                    ),
                  ),

                  // Menu action placeholder
                  _box(width: 20, height: 20, radius: 10),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 11),

              // Opening Balance & Due
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 80, height: 11, radius: 3),
                        const SizedBox(height: 5),
                        _box(width: 50, height: 14, radius: 4),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 70, height: 11, radius: 3),
                        const SizedBox(height: 5),
                        _box(width: 50, height: 14, radius: 4),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, _) => _buildCustomerCardShimmer(context),
    );
  }
}
