/// Domain Entity representing a Staff Member in the Business Logic Layer.
class StaffEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'cashier', 'manager', 'admin'
  final bool isActive;
  final DateTime createdAt;

  const StaffEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  StaffEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StaffEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
