import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_state.dart';

class ProfitChart extends StatelessWidget {
  const ProfitChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const profitColor = Color(0xFF10B981);

    return StreamBuilder<ReportsState>(
      stream: InjectionContainer.reportsBloc.stream,
      initialData: InjectionContainer.reportsBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
        final summary = state is ReportsLoadedState ? state.summary : null;
        final logs = state is ReportsLoadedState ? state.invoiceLogs : [];

        final double totalRev = summary?.totalRevenue ?? 0.0;
        final double totalDisc = summary?.totalDiscount ?? 0.0;
        // Estimated Net Profit = Revenue minus discounts & estimated item cost (~65% margin)
        final double estProfit = totalRev > 0 ? (totalRev - totalDisc) * 0.35 : 0.0;

        List<FlSpot> spots = [];
        if (logs.isNotEmpty) {
          final recentLogs = logs.take(7).toList();
          for (int i = 0; i < recentLogs.length; i++) {
            spots.add(FlSpot(i.toDouble(), (recentLogs[i].netTotal * 0.35) / 1000));
          }
        }

        if (spots.length < 2) {
          spots = const [
            FlSpot(0, 2),
            FlSpot(1, 4),
            FlSpot(2, 6),
            FlSpot(3, 5),
            FlSpot(4, 9),
            FlSpot(5, 8),
            FlSpot(6, 12),
          ];
        }

        double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
        if (maxY < 10) maxY = 25;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profit Overview 💰',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: profitColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Net Margin',
                      style: TextStyle(color: profitColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '৳ ${estProfit.toStringAsFixed(0)}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: profitColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY / 4).clamp(1.0, 100.0),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: theme.dividerColor.withValues(alpha: 0.4), strokeWidth: 1);
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: (maxY / 4).clamp(1.0, 100.0),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}K',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= spots.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Day ${idx + 1}',
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem(
                              '৳ ${(spot.y * 1000).toStringAsFixed(0)} Profit',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: profitColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: profitColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}