/// Domain Entity representing Reports & Sales Analytics Summary Metrics.
class ReportSummaryEntity {
  final double totalRevenue;
  final int totalSalesCount;
  final double totalDiscount;
  final double totalDue;
  final double cashRevenue;
  final double digitalRevenue; // bKash / Card
  final double dueRevenue;

  const ReportSummaryEntity({
    required this.totalRevenue,
    required this.totalSalesCount,
    required this.totalDiscount,
    required this.totalDue,
    required this.cashRevenue,
    required this.digitalRevenue,
    required this.dueRevenue,
  });

  /// Computed property: average revenue per sale.
  double get averageOrderValue => totalSalesCount > 0 ? totalRevenue / totalSalesCount : 0.0;
}
