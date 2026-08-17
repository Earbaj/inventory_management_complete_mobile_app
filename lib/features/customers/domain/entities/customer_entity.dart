/// Domain Entity representing a Customer in the Business Logic Layer.
class CustomerEntity {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double totalDue;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double openingBalance;


  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.totalDue = 0.0,
    this.notes,
    this.createdAt,
    this.updatedAt,
    required this.openingBalance,
  });

  /// Computed property: true if customer has an outstanding due balance.
  bool get hasDue => totalDue > 0;

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? totalDue,
    double? openingBalance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      totalDue: totalDue ?? this.totalDue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt, openingBalance: openingBalance ?? this.openingBalance,
    );
  }
}
