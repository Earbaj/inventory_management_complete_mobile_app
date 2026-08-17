/// Domain Entity representing Shop Profile & Configuration Settings.
class ShopProfileEntity {
  final String id;
  final String shopName;
  final String phone;
  final String? email;
  final String? address;
  final String currencySymbol;
  final double defaultVatRate;
  final String? logoUrl;

  const ShopProfileEntity({
    required this.id,
    required this.shopName,
    required this.phone,
    this.email,
    this.address,
    this.currencySymbol = '৳',
    this.defaultVatRate = 0.0,
    this.logoUrl,
  });

  ShopProfileEntity copyWith({
    String? id,
    String? shopName,
    String? phone,
    String? email,
    String? address,
    String? currencySymbol,
    double? defaultVatRate,
    String? logoUrl,
  }) {
    return ShopProfileEntity(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultVatRate: defaultVatRate ?? this.defaultVatRate,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
