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

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNo: json['invoiceNo'] ?? json['invoice_no'] ?? '',
      itemId: json['itemId'] ?? json['item_id'] ?? '',
      itemName: json['itemName'] ?? json['item_name'] ?? '',
      customerName: json['customerName'] ?? json['customer_name'],
      returnQuantity: (json['returnQuantity'] ?? json['quantity'] ?? 1) as int,
      unitPrice: (json['unitPrice'] ?? json['unit_price'] ?? 0.0).toDouble(),
      totalRefundAmount: (json['totalRefundAmount'] ?? json['refund_amount'] ?? 0.0).toDouble(),
      refundMethod: json['refundMethod'] ?? json['refund_method'] ?? 'cash',
      isRestocked: json['isRestocked'] ?? json['is_restocked'] ?? true,
      reason: json['reason'],
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'itemId': itemId,
      'itemName': itemName,
      if (customerName != null) 'customerName': customerName,
      'returnQuantity': returnQuantity,
      'unitPrice': unitPrice,
      'totalRefundAmount': totalRefundAmount,
      'refundMethod': refundMethod,
      'isRestocked': isRestocked,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
