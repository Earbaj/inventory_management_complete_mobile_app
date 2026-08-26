class SupplierModel {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final double totalPurchases;
  final double dueAmount;
  final DateTime createdAt;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.address,
    this.totalPurchases = 0.0,
    this.dueAmount = 0.0,
    required this.createdAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      totalPurchases: (json['totalPurchases'] ?? json['totalAmount'] ?? 0).toDouble(),
      dueAmount: (json['dueAmount'] ?? json['due'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'dueAmount': dueAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? companyName,
    String? phone,
    String? email,
    String? address,
    double? totalPurchases,
    double? dueAmount,
    DateTime? createdAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      dueAmount: dueAmount ?? this.dueAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
