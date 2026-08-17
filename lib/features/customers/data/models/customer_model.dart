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

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final parsedDue = (json['totalDue'] ?? json['total_due'] ?? json['due'] ?? json['openingBalance'] ?? json['opening_balance'] ?? 0.0).toDouble();
    final parsedOpeningBalance = (json['openingBalance'] ?? json['opening_balance'] ?? json['totalDue'] ?? json['total_due'] ?? 0.0).toDouble();

    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      totalDue: parsedDue,
      openingBalance: parsedOpeningBalance,
      notes: json['notes'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
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
