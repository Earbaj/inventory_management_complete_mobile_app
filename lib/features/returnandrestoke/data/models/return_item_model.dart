/// Data Transfer Object (DTO) for Return Item JSON payload.
class ReturnItemModel {
  final String id;
  final String invoiceNo;
  final String itemId;
  final String itemName;
  final String? customerName;
  final int returnQuantity;
  final double unitPrice;
  final double totalRefundAmount;
  final String refundMethod;
  final bool isRestocked;
  final String? reason;
  final String? createdAt;

  const ReturnItemModel({
    required this.id,
    required this.invoiceNo,
    required this.itemId,
    required this.itemName,
    this.customerName,
    required this.returnQuantity,
    required this.unitPrice,
    required this.totalRefundAmount,
    required this.refundMethod,
    this.isRestocked = true,
    this.reason,
    this.createdAt,
  });

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? json['invoice_no']?.toString() ?? json['invoiceNumber']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? json['item_id']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? json['item_name']?.toString() ?? json['name']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['customer_name']?.toString(),
      returnQuantity: _parseInt(json['returnQuantity'] ?? json['quantity'] ?? json['qty'] ?? 1),
      unitPrice: _parseDouble(json['unitPrice'] ?? json['unit_price'] ?? json['price']),
      totalRefundAmount: _parseDouble(json['totalRefundAmount'] ?? json['refund_amount'] ?? json['totalPrice']),
      refundMethod: json['refundMethod']?.toString() ?? json['refund_method']?.toString() ?? 'cash',
      isRestocked: json['isRestocked'] == true || json['is_restocked'] == true,
      reason: json['reason']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'invoiceNo': invoiceNo,
      'itemId': itemId,
      'itemName': itemName,
      if (customerName != null && customerName!.isNotEmpty) 'customerName': customerName,
      'returnQuantity': returnQuantity,
      'unitPrice': unitPrice,
      'totalRefundAmount': totalRefundAmount,
      'refundMethod': refundMethod,
      'isRestocked': isRestocked,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
