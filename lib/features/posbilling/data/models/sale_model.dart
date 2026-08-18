import '../../../customers/data/models/customer_model.dart';
import 'cart_item_model.dart';

/// Data Transfer Object (DTO) for Sale Transactions in JSON payloads.
class SaleModel {
  final String id;
  final String invoiceNo;
  final CustomerModel? customer;
  final List<CartItemModel> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double netTotal;
  final double paidAmount;
  final double dueAmount;
  final String paymentMethod;
  final String? createdAt;

  const SaleModel({
    required this.id,
    required this.invoiceNo,
    this.customer,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.netTotal,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentMethod,
    this.createdAt,
  });

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final List rawItems = json['items'] ?? [];
    final List<CartItemModel> parsedItems = rawItems
        .map((itemJson) => CartItemModel.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    CustomerModel? parsedCustomer;
    if (json['customer'] is Map<String, dynamic>) {
      parsedCustomer = CustomerModel.fromJson(json['customer']);
    } else if (json['customerName'] != null) {
      parsedCustomer = CustomerModel(
        id: json['customerId']?.toString() ?? '',
        name: json['customerName']?.toString() ?? '',
        phone: json['customerPhone']?.toString() ?? '',
        openingBalance: 0.0,
      );
    }

    return SaleModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? json['invoice_no']?.toString() ?? json['invoiceId']?.toString() ?? '',
      customer: parsedCustomer,
      items: parsedItems,
      subtotal: _parseDouble(json['subtotal']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount']),
      vatAmount: _parseDouble(json['vatAmount'] ?? json['vat']),
      netTotal: _parseDouble(json['netTotal'] ?? json['total']),
      paidAmount: _parseDouble(json['paidAmount'] ?? json['paid']),
      dueAmount: _parseDouble(json['dueAmount'] ?? json['due']),
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString() ?? 'cash',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'items': items.map((e) => e.toApiJson()).toList(),
      'discount': discountAmount,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
    };

    if (customer != null && customer!.id.isNotEmpty) {
      map['customerId'] = customer!.id;
      map['customerName'] = customer!.name;
      map['customerPhone'] = customer!.phone;
    }

    if (invoiceNo.isNotEmpty) {
      map['invoiceNo'] = invoiceNo;
    }

    return map;
  }
}
