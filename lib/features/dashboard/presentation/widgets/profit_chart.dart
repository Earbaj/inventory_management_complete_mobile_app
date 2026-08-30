import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';

enum ProfitTimeframe { last7Days, last30Days }

class ProfitChart extends StatefulWidget {
  const ProfitChart({super.key});

  @override
  State<ProfitChart> createState() => _ProfitChartState();
}

class _ProfitChartState extends State<ProfitChart> {
  ProfitTimeframe _timeframe = ProfitTimeframe.last7Days;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const profitColor = Color(0xFF10B981);
    const profitGradientEnd = Color(0xFF059669);

    return StreamBuilder<ReportsState>(
      stream: InjectionContainer.reportsBloc.stream,
      initialData: InjectionContainer.reportsBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
        final List<SaleEntity> logs = state is ReportsLoadedState ? state.invoiceLogs : [];

        final now = DateTime.now();
        final List<_ProfitDataPoint> dataPoints = _aggregateProfitData(logs, _timeframe, now);

        final double totalPeriodRevenue = dataPoints.fold(0.0, (sum, p) => sum + p.totalRevenue);
        final double totalPeriodProfit = dataPoints.fold(0.0, (sum, p) => sum + p.estimatedProfit);
        final double avgDailyProfit = dataPoints.isNotEmpty ? totalPeriodProfit / dataPoints.length : 0.0;
        final double profitMargin = totalPeriodRevenue > 0 ? (totalPeriodProfit / totalPeriodRevenue) * 100 : 35.0;

        double maxProfit = dataPoints.isEmpty ? 100 : dataPoints.map((p) => p.estimatedProfit).reduce((a, b) => a > b ? a : b);
        if (maxProfit <= 0) maxProfit = 500;
        final double chartMaxY = maxProfit * 1.25;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title, Margin Pill & Timeframe Selector
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: profitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded, color: profitColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Profit & Margin',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: profitColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${profitMargin.toStringAsFixed(1)}% Margin',
                                style: const TextStyle(
                                  color: profitColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _timeframe == ProfitTimeframe.last7Days ? 'Net earnings past 7 days' : 'Monthly profit trend',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 16),

              // Total Profit & Quick Sub-metrics
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '৳ ${totalPeriodProfit.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: profitColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: profitColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Avg ৳${avgDailyProfit.toStringAsFixed(0)}/d',
                      style: const TextStyle(
                        color: profitColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Revenue: ৳${totalPeriodRevenue.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // Timeframe Segmented Control
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTimeframePill('7D', ProfitTimeframe.last7Days),
                        _buildTimeframePill('30D', ProfitTimeframe.last30Days),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Bar Chart
              SizedBox(
                height: 190,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => colorScheme.inverseSurface,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final point = dataPoints[group.x.toInt()];
                          return BarTooltipItem(
                            '${point.fullDateLabel}\n',
                            TextStyle(
                              color: colorScheme.onInverseSurface.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text: 'Profit: ৳${point.estimatedProfit.toStringAsFixed(0)}\n',
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: 'Rev: ৳${point.totalRevenue.toStringAsFixed(0)} (${point.orderCount} inv)',
                                style: TextStyle(
                                  color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      touchCallback: (event, response) {
                        if (response?.spot != null && event is! FlTapUpEvent && event is! FlPanEndEvent) {
                          setState(() {
                            _touchedIndex = response?.spot?.touchedBarGroupIndex;
                          });
                        } else {
                          setState(() {
                            _touchedIndex = null;
                          });
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          interval: (chartMaxY / 4).clamp(1.0, 100000.0),
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();
                            return Text(
                              _formatCompactCurrency(value),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= dataPoints.length) return const SizedBox();
                            final point = dataPoints[idx];
                            final isTouched = _touchedIndex == idx;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                point.shortLabel,
                                style: TextStyle(
                                  color: isTouched ? profitColor : colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (chartMaxY / 4).clamp(1.0, 100000.0),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withValues(alpha: 0.4),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: dataPoints.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final point = entry.value;
                      final isTouched = _touchedIndex == idx;

                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: point.estimatedProfit > 0 ? point.estimatedProfit : 0.0,
                            width: _timeframe == ProfitTimeframe.last7Days ? 18 : 10,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            gradient: LinearGradient(
                              colors: isTouched
                                  ? [const Color(0xFF6EE7B7), profitColor]
                                  : [profitColor.withValues(alpha: 0.8), profitGradientEnd],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: chartMaxY,
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeframePill(String title, ProfitTimeframe timeframe) {
    final isSelected = _timeframe == timeframe;
    final colorScheme = Theme.of(context).colorScheme;
    const profitColor = Color(0xFF10B981);

    return GestureDetector(
      onTap: () => setState(() => _timeframe = timeframe),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? profitColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<_ProfitDataPoint> _aggregateProfitData(List<SaleEntity> logs, ProfitTimeframe timeframe, DateTime now) {
    if (timeframe == ProfitTimeframe.last7Days) {
      final List<_ProfitDataPoint> points = [];
      final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final dayInvoices = logs.where((l) {
          final d = l.createdAt;
          return d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day;
        }).toList();

        final revenue = dayInvoices.fold(0.0, (sum, l) => sum + l.netTotal);
        // Compute estimated profit based on items cost vs sell or standard margin
        double profit = 0.0;
        for (final inv in dayInvoices) {
          double invoiceCost = 0.0;
          for (final item in inv.items) {
            final buyPrice = item.item.buyPrice > 0 ? item.item.buyPrice : item.item.sellPrice * 0.65;
            invoiceCost += (buyPrice * item.quantity);
          }
          final netProfit = inv.netTotal - invoiceCost;
          profit += (netProfit > 0 ? netProfit : inv.netTotal * 0.35);
        }

        final shortLabel = i == 0 ? 'Today' : daysOfWeek[targetDate.weekday - 1];
        final fullLabel = '${targetDate.day}/${targetDate.month} (${daysOfWeek[targetDate.weekday - 1]})';

        points.add(_ProfitDataPoint(
          shortLabel: shortLabel,
          fullDateLabel: fullLabel,
          totalRevenue: revenue,
          estimatedProfit: profit,
          orderCount: dayInvoices.length,
        ));
      }
      return points;
    } else {
      // 30 Days (4 weekly buckets)
      final List<_ProfitDataPoint> points = [];
      for (int w = 3; w >= 0; w--) {
        final startDay = now.subtract(Duration(days: (w + 1) * 7));
        final endDay = now.subtract(Duration(days: w * 7));

        final weekInvoices = logs.where((l) {
          return l.createdAt.isAfter(startDay) && l.createdAt.isBefore(endDay.add(const Duration(days: 1)));
        }).toList();

        final revenue = weekInvoices.fold(0.0, (sum, l) => sum + l.netTotal);
        double profit = 0.0;
        for (final inv in weekInvoices) {
          double invoiceCost = 0.0;
          for (final item in inv.items) {
            final buyPrice = item.item.buyPrice > 0 ? item.item.buyPrice : item.item.sellPrice * 0.65;
            invoiceCost += (buyPrice * item.quantity);
          }
          final netProfit = inv.netTotal - invoiceCost;
          profit += (netProfit > 0 ? netProfit : inv.netTotal * 0.35);
        }

        final label = w == 0 ? 'This Wk' : 'Wk -$w';
        final fullLabel = '${startDay.day}/${startDay.month} - ${endDay.day}/${endDay.month}';

        points.add(_ProfitDataPoint(
          shortLabel: label,
          fullDateLabel: fullLabel,
          totalRevenue: revenue,
          estimatedProfit: profit,
          orderCount: weekInvoices.length,
        ));
      }
      return points;
    }
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return '৳${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '৳${(value / 1000).toStringAsFixed(0)}k';
    }
    return '৳${value.toInt()}';
  }
}

class _ProfitDataPoint {
  final String shortLabel;
  final String fullDateLabel;
  final double totalRevenue;
  final double estimatedProfit;
  final int orderCount;

  _ProfitDataPoint({
    required this.shortLabel,
    required this.fullDateLabel,
    required this.totalRevenue,
    required this.estimatedProfit,
    required this.orderCount,
  });
}