/// Data Transfer Object for SuperAdmin Platform Overview Metrics
class SuperAdminMetricsModel {
  final int totalRegisteredShops;
  final int totalManagersCount;
  final int freeTierShopsCount;
  final int premiumTierShopsCount;
  final int pendingPaymentRequestsCount;
  final double totalSubscriptionRevenue;
  final int platformTotalItems;
  final int platformTotalSales;

  const SuperAdminMetricsModel({
    required this.totalRegisteredShops,
    required this.totalManagersCount,
    required this.freeTierShopsCount,
    required this.premiumTierShopsCount,
    required this.pendingPaymentRequestsCount,
    required this.totalSubscriptionRevenue,
    required this.platformTotalItems,
    required this.platformTotalSales,
  });

  factory SuperAdminMetricsModel.fromJson(Map<String, dynamic> json) {
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

    return SuperAdminMetricsModel(
      totalRegisteredShops: parseInt(json['totalRegisteredShops'] ?? json['totalShops']),
      totalManagersCount: parseInt(json['totalManagersCount'] ?? json['totalManagers']),
      freeTierShopsCount: parseInt(json['freeTierShopsCount'] ?? json['freeShops']),
      premiumTierShopsCount: parseInt(json['premiumTierShopsCount'] ?? json['premiumShops']),
      pendingPaymentRequestsCount: parseInt(json['pendingPaymentRequestsCount'] ?? json['pendingPayments']),
      totalSubscriptionRevenue: parseDouble(json['totalSubscriptionRevenue'] ?? json['subscriptionRevenue']),
      platformTotalItems: parseInt(json['platformTotalItems'] ?? json['totalItems']),
      platformTotalSales: parseInt(json['platformTotalSales'] ?? json['totalSales']),
    );
  }
}
