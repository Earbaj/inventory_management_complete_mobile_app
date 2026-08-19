/// Data Transfer Object (DTO) for Customer REST API JSON payload.
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double rawBalance; // signed balance from API: negative = Due, positive = Credit
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
    this.rawBalance = 0.0,
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
    final rawDue = json['closingBalance'] ?? json['closing_balance'] ?? json['totalDue'] ?? json['total_due'] ?? json['due'];
    final rawOpening = json['openingBalance'] ?? json['opening_balance'];

    final parsedBalance = _parseDouble(rawDue);
    final parsedOpening = _parseDouble(rawOpening);

    final double dueAmount = parsedBalance < 0 ? parsedBalance.abs() : 0.0;

    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      rawBalance: parsedBalance,
      totalDue: dueAmount,
      openingBalance: parsedOpening,
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
      'closingBalance': rawBalance,
      'totalDue': totalDue,
      'openingBalance': openingBalance,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
