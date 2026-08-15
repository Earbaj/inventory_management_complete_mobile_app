import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ChartCard(
      title: 'Sales Overview',
      value: '৳ 24,580',
      color: theme.colorScheme.primary,

      child: SizedBox(
        height: 210,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 50,

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.dividerColor
                      .withValues(alpha: 0.4),
                  strokeWidth: 1,
                );
              },
            ),

            borderData: FlBorderData(
              show: false,
            ),

            titlesData: FlTitlesData(
              topTitles:
              const AxisTitles(
                sideTitles:
                SideTitles(
                  showTitles: false,
                ),
              ),

              rightTitles:
              const AxisTitles(
                sideTitles:
                SideTitles(
                  showTitles: false,
                ),
              ),

              leftTitles:
              AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  interval: 10,
                  getTitlesWidget:
                      (value, meta) {
                    return Text(
                      '${value.toInt()}K',
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        fontSize: 9,
                      ),
                    );
                  },
                ),
              ),

              bottomTitles:
              AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget:
                      (value, meta) {
                    const labels = [
                      '18 May',
                      '19 May',
                      '20 May',
                      '21 May',
                      '22 May',
                      '23 May',
                      '24 May',
                    ];

                    final index =
                    value.toInt();

                    if (index < 0 ||
                        index >=
                            labels.length) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 8,
                      ),
                      child: Text(
                        labels[index],
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          fontSize: 8,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            lineTouchData:
            LineTouchData(
              touchTooltipData:
              LineTouchTooltipData(
                getTooltipItems:
                    (spots) {
                  return spots.map(
                        (spot) {
                      return LineTooltipItem(
                        '৳ ${spot.y.toStringAsFixed(0)}K',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      );
                    },
                  ).toList();
                },
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 14),
                  FlSpot(1, 20),
                  FlSpot(2, 19),
                  FlSpot(3, 36),
                  FlSpot(4, 29),
                  FlSpot(5, 34),
                  FlSpot(6, 31),
                ],

                isCurved: true,

                color:
                const Color(0xFF2563EB),

                barWidth: 3,

                dotData: FlDotData(
                  show: true,
                ),

                belowBarData:
                BarAreaData(
                  show: true,
                  color: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: 0.10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.value,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: theme.dividerColor
              .withValues(alpha: 0.5),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Text(
                  'This Week',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}