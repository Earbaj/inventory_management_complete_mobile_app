/// Domain Entity representing a Return Transaction in the Business Logic Layer.
class ReturnItemEntity {
  final String id;
  final String saleId;
  final String invoiceNo;
  final String itemId;
  final String itemName;
  final String? customerId;
  final String? customerName;
  final int returnQuantity;
  final double unitPrice;
  final double totalRefundAmount;
  final String refundMethod; // 'cash', 'due_adjust', 'bkash'
  final bool isRestocked;
  final String? reason;
  final DateTime createdAt;

  const ReturnItemEntity({
    required this.id,
    this.saleId = '',
    required this.invoiceNo,
    required this.itemId,
    required this.itemName,
    this.customerId,
    this.customerName,
    required this.returnQuantity,
    required this.unitPrice,
    required this.totalRefundAmount,
    required this.refundMethod,
    this.isRestocked = true,
    this.reason,
    required this.createdAt,
  });

  ReturnItemEntity copyWith({
    String? id,
    String? saleId,
    String? invoiceNo,
    String? itemId,
    String? itemName,
    String? customerId,
    String? customerName,
    int? returnQuantity,
    double? unitPrice,
    double? totalRefundAmount,
    String? refundMethod,
    bool? isRestocked,
    String? reason,
    DateTime? createdAt,
  }) {
    return ReturnItemEntity(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      returnQuantity: returnQuantity ?? this.returnQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalRefundAmount: totalRefundAmount ?? this.totalRefundAmount,
      refundMethod: refundMethod ?? this.refundMethod,
      isRestocked: isRestocked ?? this.isRestocked,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
