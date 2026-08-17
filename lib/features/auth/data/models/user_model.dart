class UserSubscriptionModel {
  final String planName;
  final String status;
  final String? expiresAt;

  const UserSubscriptionModel({
    required this.planName,
    required this.status,
    this.expiresAt,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      planName: json['planName'] ?? json['plan_name'] ?? 'Free',
      status: json['status'] ?? 'active',
      expiresAt: json['expiresAt'] ?? json['expires_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'status': status,
      'expiresAt': expiresAt,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? shopName;
  final String? phone;
  final UserSubscriptionModel? subscription;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shopName,
    this.phone,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'shop_owner',
      shopName: json['shopName'] ?? json['shop_name'],
      phone: json['phone'],
      subscription: json['subscription'] != null
          ? UserSubscriptionModel.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'shopName': shopName,
      'phone': phone,
      'subscription': subscription?.toJson(),
    };
  }
}
