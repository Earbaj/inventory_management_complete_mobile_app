/// Permissions model for Staff / Manager.
class StaffPermissions {
  final bool canViewBuyPrice;
  final bool canEditCustomers;
  final bool canProcessReturn;
  final bool canExportExcel;

  const StaffPermissions({
    this.canViewBuyPrice = false,
    this.canEditCustomers = false,
    this.canProcessReturn = false,
    this.canExportExcel = false,
  });

  factory StaffPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StaffPermissions();
    return StaffPermissions(
      canViewBuyPrice: json['canViewBuyPrice'] == true,
      canEditCustomers: json['canEditCustomers'] == true,
      canProcessReturn: json['canProcessReturn'] == true,
      canExportExcel: json['canExportExcel'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canViewBuyPrice': canViewBuyPrice,
      'canEditCustomers': canEditCustomers,
      'canProcessReturn': canProcessReturn,
      'canExportExcel': canExportExcel,
    };
  }

  StaffPermissions copyWith({
    bool? canViewBuyPrice,
    bool? canEditCustomers,
    bool? canProcessReturn,
    bool? canExportExcel,
  }) {
    return StaffPermissions(
      canViewBuyPrice: canViewBuyPrice ?? this.canViewBuyPrice,
      canEditCustomers: canEditCustomers ?? this.canEditCustomers,
      canProcessReturn: canProcessReturn ?? this.canProcessReturn,
      canExportExcel: canExportExcel ?? this.canExportExcel,
    );
  }
}

/// Data Transfer Object (DTO) for Staff Member JSON payload.
class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final String? createdAt;
  final String? password;
  final StaffPermissions permissions;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.password,
    this.permissions = const StaffPermissions(),
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      role: json['role']?.toString() ?? 'manager',
      isActive: json['isActive'] ?? json['is_active'] ?? json['active'] ?? true,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      permissions: json['permissions'] is Map<String, dynamic>
          ? StaffPermissions.fromJson(json['permissions'])
          : const StaffPermissions(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      if (password != null && password!.isNotEmpty) 'password': password,
      if (createdAt != null) 'createdAt': createdAt,
      'permissions': permissions.toJson(),
    };
  }
}
