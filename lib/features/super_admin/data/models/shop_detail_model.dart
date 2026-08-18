/// Model representing detailed manager profile
class ManagerItemModel {
  final String uid;
  final String name;
  final String email;
  final Map<String, dynamic>? permissions;

  const ManagerItemModel({
    required this.uid,
    required this.name,
    required this.email,
    this.permissions,
  });

  factory ManagerItemModel.fromJson(Map<String, dynamic> json) {
    return ManagerItemModel(
      uid: json['uid']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Manager',
      email: json['email']?.toString() ?? 'N/A',
      permissions: json['permissions'] is Map<String, dynamic> ? json['permissions'] : null,
    );
  }
}

/// Model representing full shop details from GET /api/admin/shops/:id
class ShopDetailModel {
  final String id;
  final String shopId;
  final String name;
  final String email;
  final String role;
  final String subscriptionTier;
  final String? subscriptionExpiresAt;
  final List<ManagerItemModel> managers;
  final String createdAt;

  const ShopDetailModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.email,
    required this.role,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.managers,
    required this.createdAt,
  });

  factory ShopDetailModel.fromJson(Map<String, dynamic> json) {
    final List mgrsList = json['managers'] is List ? json['managers'] : [];
    return ShopDetailModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['shopName']?.toString() ?? 'Shop Profile',
      email: json['email']?.toString() ?? 'N/A',
      role: json['role']?.toString() ?? 'admin',
      subscriptionTier: json['subscriptionTier']?.toString() ?? 'free',
      subscriptionExpiresAt: json['subscriptionExpiresAt']?.toString(),
      managers: mgrsList.map((m) => ManagerItemModel.fromJson(m is Map<String, dynamic> ? m : {})).toList(),
      createdAt: json['createdAt']?.toString() ?? 'N/A',
    );
  }
}
