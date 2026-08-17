/// Data Transfer Object (DTO) for Staff Member JSON payload.
class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final String? createdAt;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'cashier',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
