/// Data Transfer Object (DTO) for Return Item JSON payload.
class ReturnItemModel {
  final String id;
  final String saleId;
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
    this.saleId = '',
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
    Map<String, dynamic> itemMap = json;
    if (json['returnedItems'] is List && (json['returnedItems'] as List).isNotEmpty) {
      final firstItem = (json['returnedItems'] as List).first;
      if (firstItem is Map<String, dynamic>) {
        itemMap = Map<String, dynamic>.from(json)..addAll(firstItem);
      }
    }

    return ReturnItemModel(
      id: itemMap['id']?.toString() ?? itemMap['_id']?.toString() ?? '',
      saleId: itemMap['saleId']?.toString() ?? itemMap['sale_id']?.toString() ?? '',
      invoiceNo: itemMap['invoiceNo']?.toString() ?? itemMap['invoice_no']?.toString() ?? itemMap['invoiceNumber']?.toString() ?? '',
      itemId: itemMap['itemId']?.toString() ?? itemMap['item_id']?.toString() ?? '',
      itemName: itemMap['itemName']?.toString() ?? itemMap['item_name']?.toString() ?? itemMap['name']?.toString() ?? '',
      customerName: itemMap['customerName']?.toString() ?? itemMap['customer_name']?.toString(),
      returnQuantity: _parseInt(itemMap['returnQuantity'] ?? itemMap['quantity'] ?? itemMap['qty'] ?? 1),
      unitPrice: _parseDouble(itemMap['unitPrice'] ?? itemMap['unit_price'] ?? itemMap['price']),
      totalRefundAmount: _parseDouble(itemMap['totalRefundAmount'] ?? itemMap['refundAmount'] ?? itemMap['refund_amount'] ?? itemMap['totalPrice']),
      refundMethod: itemMap['refundMethod']?.toString() ?? itemMap['refund_method']?.toString() ?? 'cash',
      isRestocked: itemMap['isRestocked'] == true || itemMap['is_restocked'] == true,
      reason: itemMap['reason']?.toString(),
      createdAt: itemMap['createdAt']?.toString() ?? itemMap['created_at']?.toString() ?? itemMap['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final String targetSaleId = saleId.isNotEmpty ? saleId : (id.isNotEmpty ? id : invoiceNo);

    return {
      'saleId': targetSaleId,
      'invoiceNo': invoiceNo,
      'returnedItems': [
        {
          'itemId': itemId,
          'quantity': returnQuantity,
          'returnQuantity': returnQuantity,
          'unitPrice': unitPrice,
          'refundAmount': totalRefundAmount,
          'totalRefundAmount': totalRefundAmount,
        }
      ],
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
