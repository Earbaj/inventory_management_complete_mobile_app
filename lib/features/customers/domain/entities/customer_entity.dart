/// Domain Entity representing a Customer in the Business Logic Layer.
class CustomerEntity {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double rawBalance; // signed balance from API: negative = Due, positive = Credit
  final double openingBalance;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.rawBalance = 0.0,
    double totalDue = 0.0,
    this.notes,
    this.createdAt,
    this.updatedAt,
    required this.openingBalance,
  });

  /// Computed property: true if customer has an outstanding due balance (rawBalance < 0).
  bool get hasDue => rawBalance < 0;

  /// Computed property: true if customer has an advance store credit (rawBalance > 0).
  bool get isAdvanceCredit => rawBalance > 0;

  /// Active due amount (always positive, 0 if no due).
  double get totalDue => rawBalance < 0 ? rawBalance.abs() : 0.0;

  /// Active advance store credit amount (always positive, 0 if no credit).
  double get advanceCredit => rawBalance > 0 ? rawBalance : 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? rawBalance,
    double? totalDue,
    double? openingBalance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      rawBalance: rawBalance ?? (totalDue != null ? (totalDue > 0 ? -totalDue : 0.0) : this.rawBalance),
      totalDue: totalDue ?? this.totalDue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      openingBalance: openingBalance ?? this.openingBalance,
    );
  }
}
