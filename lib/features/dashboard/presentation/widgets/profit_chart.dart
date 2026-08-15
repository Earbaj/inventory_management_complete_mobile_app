import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProfitChart extends StatelessWidget {
  const ProfitChart({super.key});

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
                  'Profit Overview',
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
                  color: const Color(
                    0xFF10B981,
                  ).withValues(alpha: 0.08),
                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: const Text(
                  'This Week',
                  style: TextStyle(
                    color: Color(0xFF10B981),
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
              '৳ 8,450',
              style: theme
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 210,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 20,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine:
                      (value) {
                    return FlLine(
                      color: theme.dividerColor
                          .withValues(
                        alpha: 0.4,
                      ),
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                titlesData:
                FlTitlesData(
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
                    sideTitles:
                    SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 5,
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
                    sideTitles:
                    SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget:
                          (value, meta) {
                        const labels = [
                          '18',
                          '19',
                          '20',
                          '21',
                          '22',
                          '23',
                          '24',
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
                          const EdgeInsets
                              .only(
                            top: 8,
                          ),
                          child: Text(
                            labels[index],
                            style: theme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 5),
                      FlSpot(1, 7),
                      FlSpot(2, 6),
                      FlSpot(3, 13),
                      FlSpot(4, 9),
                      FlSpot(5, 12),
                      FlSpot(6, 15),
                    ],

                    isCurved: true,

                    color:
                    const Color(0xFF10B981),

                    barWidth: 3,

                    dotData: FlDotData(
                      show: true,
                    ),

                    belowBarData:
                    BarAreaData(
                      show: true,
                      color: const Color(
                        0xFF10B981,
                      ).withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}