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
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final rev = parseDouble(json['totalRevenue'] ?? json['totalSalesRevenue'] ?? json['total_revenue'] ?? json['revenue']);
    final salesCnt = parseInt(json['totalSalesCount'] ?? json['totalInvoices'] ?? json['totalInvoicesCount'] ?? json['total_sales_count'] ?? json['salesCount']);
    final disc = parseDouble(json['totalDiscount'] ?? json['total_discount']);
    final due = parseDouble(json['totalDue'] ?? json['totalDueAmount'] ?? json['total_due'] ?? json['dueRevenue'] ?? json['totalCustomerDue'] ?? json['outstandingDue'] ?? json['due']);
    final cash = parseDouble(json['cashRevenue'] ?? json['totalPaidCollected'] ?? json['cash_revenue']);
    final digital = parseDouble(json['digitalRevenue'] ?? json['digital_revenue']);
    final dueRev = parseDouble(json['dueRevenue'] ?? json['totalCustomerDue'] ?? json['due_revenue']);

    return ReportSummaryModel(
      totalRevenue: rev,
      totalSalesCount: salesCnt,
      totalDiscount: disc,
      totalDue: due,
      cashRevenue: cash,
      digitalRevenue: digital,
      dueRevenue: dueRev,
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
