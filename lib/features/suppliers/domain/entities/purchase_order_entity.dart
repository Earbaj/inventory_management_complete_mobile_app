class PurchaseOrderItemEntity {
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitCost;
  final double totalPrice;

  const PurchaseOrderItemEntity({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitCost,
    required this.totalPrice,
  });
}

class PurchaseOrderEntity {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final List<PurchaseOrderItemEntity> items;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String note;
  final DateTime createdAt;

  const PurchaseOrderEntity({
    required this.id,
    this.poNumber = '',
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    this.note = '',
    required this.createdAt,
  });
}
