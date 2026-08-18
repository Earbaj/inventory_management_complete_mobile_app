import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_state.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<ReportsState>(
      stream: InjectionContainer.reportsBloc.stream,
      initialData: InjectionContainer.reportsBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final summary = state is ReportsLoadedState ? state.summary : null;
        final logs = state is ReportsLoadedState ? state.invoiceLogs : [];

        final double totalRev = summary?.totalRevenue ?? 0.0;

        // Build dynamic spots from recent sales or default curve
        List<FlSpot> spots = [];
        if (logs.isNotEmpty) {
          final recentLogs = logs.take(7).toList();
          for (int i = 0; i < recentLogs.length; i++) {
            spots.add(FlSpot(i.toDouble(), recentLogs[i].netTotal / 1000));
          }
        }

        if (spots.length < 2) {
          spots = const [
            FlSpot(0, 5),
            FlSpot(1, 12),
            FlSpot(2, 18),
            FlSpot(3, 15),
            FlSpot(4, 25),
            FlSpot(5, 22),
            FlSpot(6, 30),
          ];
        }

        double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 10;
        if (maxY < 20) maxY = 50;

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
                      'Sales Overview 📊',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Active Store',
                      style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '৳ ${totalRev.toStringAsFixed(0)}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                              '৳ ${(spot.y * 1000).toStringAsFixed(0)}',
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
                        color: colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colorScheme.primary.withValues(alpha: 0.12),
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