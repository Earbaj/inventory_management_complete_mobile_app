/// Data Transfer Object (DTO) for Shop Profile JSON payload.
class ShopProfileModel {
  final String id;
  final String shopName;
  final String phone;
  final String? email;
  final String? address;
  final String currencySymbol;
  final double defaultVatRate;
  final String? logoUrl;

  const ShopProfileModel({
    required this.id,
    required this.shopName,
    required this.phone,
    this.email,
    this.address,
    this.currencySymbol = '৳',
    this.defaultVatRate = 0.0,
    this.logoUrl,
  });

  factory ShopProfileModel.fromJson(Map<String, dynamic> json) {
    return ShopProfileModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      shopName: json['shopName'] ?? json['shop_name'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      currencySymbol: json['currencySymbol'] ?? json['currency_symbol'] ?? json['currency'] ?? '৳',
      defaultVatRate: (json['defaultVatRate'] ?? json['vatRate'] ?? json['vat_rate'] ?? 0.0).toDouble(),
      logoUrl: json['logoUrl'] ?? json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      'currencySymbol': currencySymbol,
      'defaultVatRate': defaultVatRate,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }
}
