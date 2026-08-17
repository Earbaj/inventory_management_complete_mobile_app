/// Domain Entity representing Subscription Tier Status & Usage Limits.
class SubscriptionEntity {
  final String tier; // 'free', 'premium', 'enterprise'
  final int customerCount;
  final int maxCustomers; // 1 for Free, -1 for Unlimited
  final int salesCount;
  final int maxSales; // 5 for Free, -1 for Unlimited
  final DateTime? expiresAt;
  final bool isExpired;

  const SubscriptionEntity({
    required this.tier,
    required this.customerCount,
    required this.maxCustomers,
    required this.salesCount,
    required this.maxSales,
    this.expiresAt,
    this.isExpired = false,
  });

  bool get isFreeTier => tier.toLowerCase() == 'free';
  bool get isPremium => tier.toLowerCase() == 'premium' || tier.toLowerCase() == 'enterprise';

  bool get canAddCustomer => !isFreeTier || maxCustomers == -1 || customerCount < maxCustomers;
  bool get canCreateSale => !isFreeTier || maxSales == -1 || salesCount < maxSales;
}
