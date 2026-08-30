import '../../../../core/utils/money_util.dart';

/// Data Transfer Object (DTO) for Shop Profile JSON payload.
class ShopProfileModel {
  final String id;
  final String shopName;
  final String phone;
  final String? email;
  final String? address;
  final String currencySymbol;
  final String currencyCode;
  final double defaultVatRate;
  final String? logoUrl;

  const ShopProfileModel({
    required this.id,
    required this.shopName,
    required this.phone,
    this.email,
    this.address,
    this.currencySymbol = '৳',
    this.currencyCode = 'BDT',
    this.defaultVatRate = 0.0,
    this.logoUrl,
  });

  factory ShopProfileModel.fromJson(Map<String, dynamic> json) {
    final rawCurrency = json['currency'] ?? json['currencySymbol'] ?? json['currency_symbol'] ?? 'BDT';
    final rawCurrencyStr = rawCurrency.toString();
    final mappedSymbol = MoneyUtil.mapCurrencyToSymbol(rawCurrencyStr);
    final cleanCode = rawCurrencyStr.trim().toUpperCase();

    return ShopProfileModel(
      id: json['shopId']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['uid']?.toString() ??
          '',
      shopName: json['shopName'] ?? json['shop_name'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      currencySymbol: mappedSymbol,
      currencyCode: cleanCode,
      defaultVatRate: (json['vatRate'] ?? json['defaultVatRate'] ?? json['vat_rate'] ?? 0.0).toDouble(),
      logoUrl: json['logoUrl'] ?? json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': id,
      'id': id,
      'shopName': shopName,
      'name': shopName,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      'currency': currencyCode.isNotEmpty ? currencyCode : currencySymbol,
      'currencySymbol': currencySymbol,
      'vatRate': defaultVatRate,
      'defaultVatRate': defaultVatRate,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }
}
