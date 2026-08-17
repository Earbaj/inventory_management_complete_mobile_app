/// Data Transfer Object (DTO) for Subscription JSON payload.
class SubscriptionModel {
  final String tier;
  final int customerCount;
  final int maxCustomers;
  final int salesCount;
  final int maxSales;
  final String? expiresAt;
  final bool isExpired;

  const SubscriptionModel({
    required this.tier,
    required this.customerCount,
    required this.maxCustomers,
    required this.salesCount,
    required this.maxSales,
    this.expiresAt,
    this.isExpired = false,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      tier: json['tier'] ?? json['subscriptionTier'] ?? json['plan'] ?? 'free',
      customerCount: (json['customerCount'] ?? json['customersCount'] ?? 0) as int,
      maxCustomers: (json['maxCustomers'] ?? (json['tier'] == 'free' ? 1 : -1)) as int,
      salesCount: (json['salesCount'] ?? json['totalSalesCount'] ?? 0) as int,
      maxSales: (json['maxSales'] ?? (json['tier'] == 'free' ? 5 : -1)) as int,
      expiresAt: json['expiresAt'] ?? json['expires_at'],
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'customerCount': customerCount,
      'maxCustomers': maxCustomers,
      'salesCount': salesCount,
      'maxSales': maxSales,
      if (expiresAt != null) 'expiresAt': expiresAt,
      'isExpired': isExpired,
    };
  }
}
