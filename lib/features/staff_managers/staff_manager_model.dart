import 'package:flutter/material.dart';

enum StaffRole {
  manager('Manager', Icons.manage_accounts_rounded, Color(0xFF1565C0), Color(0xFFE3F2FD)),
  seniorManager('Senior Manager', Icons.supervisor_account_rounded, Color(0xFF6A1B9A), Color(0xFFF3E5F5)),
  cashier('Cashier', Icons.point_of_sale_rounded, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  inventoryStaff('Inventory Staff', Icons.inventory_2_rounded, Color(0xFFE65100), Color(0xFFFFE0B2));

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const StaffRole(this.label, this.icon, this.color, this.backgroundColor);
}

enum StaffStatus {
  active('Active', Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  inactive('Inactive', Color(0xFFC62828), Color(0xFFFFEBEE));

  final String label;
  final Color color;
  final Color backgroundColor;

  const StaffStatus(this.label, this.color, this.backgroundColor);
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final StaffRole role;
  final StaffStatus status;
  final DateTime joinedDate;
  final String assignedBranch;
  final int salesServedCount;

  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.joinedDate,
    required this.assignedBranch,
    required this.salesServedCount,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    StaffRole? role,
    StaffStatus? status,
    DateTime? joinedDate,
    String? assignedBranch,
    int? salesServedCount,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      assignedBranch: assignedBranch ?? this.assignedBranch,
      salesServedCount: salesServedCount ?? this.salesServedCount,
    );
  }
}
