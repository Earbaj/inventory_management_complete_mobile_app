class PurchaseOrderItemModel {
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitCost;
  final double totalPrice;

  const PurchaseOrderItemModel({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitCost,
    required this.totalPrice,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] ?? json['qty'] ?? 1) as int;
    final cost = (json['unitCost'] ?? json['costPrice'] ?? json['price'] ?? 0.0).toDouble();
    return PurchaseOrderItemModel(
      itemId: json['itemId']?.toString() ?? json['id']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? json['name']?.toString() ?? '',
      quantity: qty,
      unitCost: cost,
      totalPrice: (json['totalPrice'] ?? (qty * cost)).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalPrice': totalPrice,
    };
  }
}

class PurchaseOrderModel {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseOrderItemModel> items;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String note;
  final DateTime createdAt;

  const PurchaseOrderModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    this.note = '',
    required this.createdAt,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((e) => PurchaseOrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final total = (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble();
    final paid = (json['paidAmount'] ?? json['paid'] ?? total).toDouble();
    final due = (json['dueAmount'] ?? json['due'] ?? (total - paid)).toDouble();

    return PurchaseOrderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      supplierId: json['supplierId']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      items: itemsList,
      totalAmount: total,
      paidAmount: paid,
      dueAmount: due,
      note: json['note']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
