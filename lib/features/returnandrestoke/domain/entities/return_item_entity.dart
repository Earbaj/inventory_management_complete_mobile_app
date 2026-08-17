/// Domain Entity representing a Return Transaction in the Business Logic Layer.
class ReturnItemEntity {
  final String id;
  final String invoiceNo;
  final String itemId;
  final String itemName;
  final String? customerName;
  final int returnQuantity;
  final double unitPrice;
  final double totalRefundAmount;
  final String refundMethod; // 'cash', 'due_adjust'
  final bool isRestocked;
  final String? reason;
  final DateTime createdAt;

  const ReturnItemEntity({
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
    required this.createdAt,
  });
}
