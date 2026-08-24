import '../../../../core/utils/money_util.dart';

/// Data Transfer Object (DTO) for Customer REST API JSON payload.
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double openingBalance;
  final double closingBalance;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.openingBalance = 0.0,
    this.closingBalance = 0.0,
  });

  static double _parseDouble(dynamic val) => MoneyUtil.parseMoney(val);

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      openingBalance: _parseDouble(json['openingBalance'] ?? json['opening_balance']),
      closingBalance: _parseDouble(json['closingBalance'] ?? json['closing_balance'] ?? json['totalDue'] ?? json['total_due'] ?? json['due']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (address != null) 'address': address,
      'openingBalance': openingBalance,
      'closingBalance': closingBalance,
    };
  }
}
