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
  final String isReturned;
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
    this.isReturned = 'none',
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

    final String invNo = json['invoiceNumber']?.toString() ??
        json['invoiceNo']?.toString() ??
        json['invoice_no']?.toString() ??
        json['invoiceId']?.toString() ??
        '';

    final double calcNet = _parseDouble(json['grandTotal'] ?? json['netTotal'] ?? json['total']);
    final double calcPaid = _parseDouble(json['paidAmount'] ?? json['paid']);
    final double rawDue = _parseDouble(json['dueAmount'] ?? json['due']);
    final double calcDue = (rawDue > 0 || json['dueAmount'] != null)
        ? rawDue
        : (calcNet - calcPaid).clamp(0.0, double.infinity);

    return SaleModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNo: invNo.isNotEmpty
          ? invNo
          : ((json['id']?.toString().length ?? 0) > 6
              ? 'INV-${json['id'].toString().substring(0, 6).toUpperCase()}'
              : 'INV-SALE'),
      customer: parsedCustomer,
      items: parsedItems,
      subtotal: _parseDouble(json['subtotal'] ?? json['grandTotal'] ?? json['total']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount']),
      vatAmount: _parseDouble(json['vatAmount'] ?? json['vat']),
      netTotal: calcNet,
      paidAmount: calcPaid,
      dueAmount: calcDue,
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString() ?? (calcDue > 0 ? 'due' : 'cash'),
      isReturned: json['isReturned']?.toString() ?? json['is_returned']?.toString() ?? 'none',
      createdAt: json['date']?.toString() ?? json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'items': items.map((e) => e.toApiJson()).toList(),
      'discount': discountAmount,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'isReturned': isReturned,
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
