/// Data Transfer Object representing a Shop in SuperAdmin Management
class ShopItemModel {
  final String id;
  final String shopId;
  final String name;
  final String ownerEmail;
  final String? phone;
  final String subscriptionTier;
  final String? subscriptionExpiresAt;
  final int managerCount;
  final String createdAt;

  const ShopItemModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.ownerEmail,
    this.phone,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.managerCount,
    required this.createdAt,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return ShopItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['shopName']?.toString() ?? 'Shop',
      ownerEmail: json['ownerEmail']?.toString() ?? json['email']?.toString() ?? 'N/A',
      phone: json['phone']?.toString(),
      subscriptionTier: json['subscriptionTier']?.toString() ?? json['tier']?.toString() ?? 'free',
      subscriptionExpiresAt: json['subscriptionExpiresAt']?.toString(),
      managerCount: parseInt(json['managerCount'] ?? json['managersCount']),
      createdAt: json['createdAt']?.toString() ?? json['date']?.toString() ?? 'N/A',
    );
  }
}
