class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double openingBalance;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.openingBalance,
  });

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    double? openingBalance,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      openingBalance:
      openingBalance ?? this.openingBalance,
    );
  }
}