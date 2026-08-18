/// Data Transfer Object (DTO) for Customer REST API JSON payload.
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double totalDue;
  final double openingBalance;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.totalDue = 0.0,
    this.openingBalance = 0.0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final rawDue = json['totalDue'] ?? json['total_due'] ?? json['due'] ?? json['closingBalance'] ?? json['closing_balance'];
    final rawOpening = json['openingBalance'] ?? json['opening_balance'];

    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      totalDue: _parseDouble(rawDue),
      openingBalance: _parseDouble(rawOpening),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      'totalDue': totalDue,
      'openingBalance': openingBalance,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
