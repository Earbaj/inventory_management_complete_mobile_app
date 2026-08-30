import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';

enum SalesTimeframe { last7Days, last30Days }

class SalesChart extends StatefulWidget {
  const SalesChart({super.key});

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  SalesTimeframe _timeframe = SalesTimeframe.last7Days;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<ReportsState>(
      stream: InjectionContainer.reportsBloc.stream,
      initialData: InjectionContainer.reportsBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
        final List<SaleEntity> logs = state is ReportsLoadedState ? state.invoiceLogs : [];

        // Compute aggregated buckets based on timeframe
        final now = DateTime.now();
        final List<_SalesDataPoint> dataPoints = _aggregateSalesData(logs, _timeframe, now);

        final double totalPeriodRevenue = dataPoints.fold(0.0, (sum, p) => sum + p.totalRevenue);
        final int totalPeriodOrders = dataPoints.fold(0, (sum, p) => sum + p.orderCount);
        final double avgDailyRevenue = dataPoints.isNotEmpty ? totalPeriodRevenue / dataPoints.length : 0.0;

        double maxRevenue = dataPoints.isEmpty ? 100 : dataPoints.map((p) => p.totalRevenue).reduce((a, b) => a > b ? a : b);
        if (maxRevenue <= 0) maxRevenue = 1000;
        final double chartMaxY = maxRevenue * 1.2;

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
              // Header Row: Title & Timeframe Selector
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.bar_chart_rounded, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _timeframe == SalesTimeframe.last7Days ? 'Past 7 Days performance' : 'Past 30 Days trend',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timeframe Segmented Control
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTimeframePill('7D', SalesTimeframe.last7Days),
                        _buildTimeframePill('30D', SalesTimeframe.last30Days),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Total Revenue & Quick Metrics
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${MoneyUtil.currencySymbol} ${totalPeriodRevenue.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Avg ${MoneyUtil.currencySymbol}${avgDailyRevenue.toStringAsFixed(0)}/d',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$totalPeriodOrders Invoices',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                                text: '${MoneyUtil.currencySymbol}${point.totalRevenue.toStringAsFixed(0)} ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: '(${point.orderCount} inv)',
                                style: TextStyle(
                                  color: colorScheme.primaryContainer,
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
                                  color: isTouched ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
                            toY: point.totalRevenue > 0 ? point.totalRevenue : 0.0,
                            width: _timeframe == SalesTimeframe.last7Days ? 18 : 10,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            gradient: LinearGradient(
                              colors: isTouched
                                  ? [Colors.blue.shade300, colorScheme.primary]
                                  : [colorScheme.primary.withValues(alpha: 0.75), colorScheme.primary],
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

  Widget _buildTimeframePill(String title, SalesTimeframe timeframe) {
    final isSelected = _timeframe == timeframe;
    final colorScheme = Theme.of(context).colorScheme;

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
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<_SalesDataPoint> _aggregateSalesData(List<SaleEntity> logs, SalesTimeframe timeframe, DateTime now) {
    if (timeframe == SalesTimeframe.last7Days) {
      final List<_SalesDataPoint> points = [];
      final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final dayInvoices = logs.where((l) {
          final d = l.createdAt;
          return d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day;
        }).toList();

        final revenue = dayInvoices.fold(0.0, (sum, l) => sum + l.netTotal);
        final shortLabel = i == 0 ? 'Today' : daysOfWeek[targetDate.weekday - 1];
        final fullLabel = '${targetDate.day}/${targetDate.month} (${daysOfWeek[targetDate.weekday - 1]})';

        points.add(_SalesDataPoint(
          shortLabel: shortLabel,
          fullDateLabel: fullLabel,
          totalRevenue: revenue,
          orderCount: dayInvoices.length,
        ));
      }
      return points;
    } else {
      // 30 Days (4 weekly buckets)
      final List<_SalesDataPoint> points = [];
      for (int w = 3; w >= 0; w--) {
        final startDay = now.subtract(Duration(days: (w + 1) * 7));
        final endDay = now.subtract(Duration(days: w * 7));

        final weekInvoices = logs.where((l) {
          return l.createdAt.isAfter(startDay) && l.createdAt.isBefore(endDay.add(const Duration(days: 1)));
        }).toList();

        final revenue = weekInvoices.fold(0.0, (sum, l) => sum + l.netTotal);
        final label = w == 0 ? 'This Wk' : 'Wk -$w';
        final fullLabel = '${startDay.day}/${startDay.month} - ${endDay.day}/${endDay.month}';

        points.add(_SalesDataPoint(
          shortLabel: label,
          fullDateLabel: fullLabel,
          totalRevenue: revenue,
          orderCount: weekInvoices.length,
        ));
      }
      return points;
    }
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return '${MoneyUtil.currencySymbol}${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${MoneyUtil.currencySymbol}${(value / 1000).toStringAsFixed(0)}k';
    }
    return '${MoneyUtil.currencySymbol}${value.toInt()}';
  }
}

class _SalesDataPoint {
  final String shortLabel;
  final String fullDateLabel;
  final double totalRevenue;
  final int orderCount;

  _SalesDataPoint({
    required this.shortLabel,
    required this.fullDateLabel,
    required this.totalRevenue,
    required this.orderCount,
  });
}