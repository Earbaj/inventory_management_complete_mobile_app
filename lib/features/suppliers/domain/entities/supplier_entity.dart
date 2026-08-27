class SupplierEntity {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final double totalPurchases;
  final double dueAmount;
  final DateTime createdAt;

  const SupplierEntity({
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

  SupplierEntity copyWith({
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
    return SupplierEntity(
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
