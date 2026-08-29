import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReportsShimmerView extends StatelessWidget {
  final int itemCount;
  final bool showMetricCards;

  const ReportsShimmerView({
    super.key,
    this.itemCount = 5,
    this.showMetricCards = true,
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

  Widget _buildMetricCardsShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Card(
              margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              elevation: 1,
              child: Shimmer.fromColors(
                baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 24, height: 24, radius: 6),
                      const SizedBox(height: 6),
                      _box(width: 60, height: 10, radius: 3),
                      const SizedBox(height: 4),
                      _box(width: 45, height: 14, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInvoiceCardShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(width: 38, height: 38, radius: 10),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 110, height: 14, radius: 4),
                        const SizedBox(height: 6),
                        _box(width: 140, height: 11, radius: 3),
                      ],
                    ),
                  ),
                  _box(width: 50, height: 22, radius: 8),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _box(width: 16, height: 16, radius: 4),
                  const SizedBox(width: 6),
                  _box(width: 100, height: 12, radius: 3),
                  const Spacer(),
                  _box(width: 60, height: 12, radius: 3),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(width: 70, height: 12, radius: 3),
                  _box(width: 70, height: 12, radius: 3),
                  _box(width: 70, height: 12, radius: 3),
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
    final listView = ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, _) => _buildInvoiceCardShimmer(context),
    );

    return showMetricCards
        ? Column(
            children: [
              _buildMetricCardsShimmer(context),
              const SizedBox(height: 8),
              Expanded(child: listView),
            ],
          )
        : listView;
  }
}
