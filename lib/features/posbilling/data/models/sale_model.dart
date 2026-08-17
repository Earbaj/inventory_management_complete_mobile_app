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
        name: json['customerName'] ?? '',
        phone: json['customerPhone'] ?? '',
      );
    }

    return SaleModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNo: json['invoiceNo'] ?? json['invoice_no'] ?? json['invoiceId'] ?? '',
      customer: parsedCustomer,
      items: parsedItems,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount'] ?? 0.0).toDouble(),
      vatAmount: (json['vatAmount'] ?? json['vat'] ?? 0.0).toDouble(),
      netTotal: (json['netTotal'] ?? json['total'] ?? 0.0).toDouble(),
      paidAmount: (json['paidAmount'] ?? json['paid'] ?? 0.0).toDouble(),
      dueAmount: (json['dueAmount'] ?? json['due'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'cash',
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      if (customer != null) 'customerId': customer!.id,
      if (customer != null) 'customerName': customer!.name,
      if (customer != null) 'customer': customer!.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'vatAmount': vatAmount,
      'netTotal': netTotal,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paymentMethod': paymentMethod,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
