class UserSubscriptionEntity {
  final String planName;
  final String status;
  final DateTime? expiresAt;

  const UserSubscriptionEntity({
    required this.planName,
    required this.status,
    this.expiresAt,
  });
}

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? shopName;
  final String? phone;
  final UserSubscriptionEntity? subscription;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shopName,
    this.phone,
    this.subscription,
  });
}
