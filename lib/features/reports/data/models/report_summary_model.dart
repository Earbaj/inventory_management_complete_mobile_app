/// Data Transfer Object (DTO) for Reports Summary JSON payload.
class ReportSummaryModel {
  final double totalRevenue;
  final int totalSalesCount;
  final double totalDiscount;
  final double totalDue;
  final double cashRevenue;
  final double digitalRevenue;
  final double dueRevenue;

  const ReportSummaryModel({
    required this.totalRevenue,
    required this.totalSalesCount,
    required this.totalDiscount,
    required this.totalDue,
    required this.cashRevenue,
    required this.digitalRevenue,
    required this.dueRevenue,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalRevenue: (json['totalRevenue'] ?? json['total_revenue'] ?? json['revenue'] ?? 0.0).toDouble(),
      totalSalesCount: (json['totalSalesCount'] ?? json['total_sales_count'] ?? json['salesCount'] ?? 0) as int,
      totalDiscount: (json['totalDiscount'] ?? json['total_discount'] ?? 0.0).toDouble(),
      totalDue: (json['totalDue'] ?? json['total_due'] ?? 0.0).toDouble(),
      cashRevenue: (json['cashRevenue'] ?? json['cash_revenue'] ?? 0.0).toDouble(),
      digitalRevenue: (json['digitalRevenue'] ?? json['digital_revenue'] ?? 0.0).toDouble(),
      dueRevenue: (json['dueRevenue'] ?? json['due_revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalSalesCount': totalSalesCount,
      'totalDiscount': totalDiscount,
      'totalDue': totalDue,
      'cashRevenue': cashRevenue,
      'digitalRevenue': digitalRevenue,
      'dueRevenue': dueRevenue,
    };
  }
}
