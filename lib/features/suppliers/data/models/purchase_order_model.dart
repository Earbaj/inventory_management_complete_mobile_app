class PurchaseOrderItemModel {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitCost;
  final double totalPrice;

  const PurchaseOrderItemModel({
    this.id = '',
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitCost,
    required this.totalPrice,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, int def) {
      if (val == null) return def;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? def;
      return def;
    }

    double parseDouble(dynamic val, double def) {
      if (val == null) return def;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? def;
      return def;
    }

    final qty = parseInt(json['quantity'] ?? json['qty'], 1);
    final cost = parseDouble(json['buyPrice'] ?? json['unitCost'] ?? json['costPrice'] ?? json['price'], 0.0);
    final name = (json['name'] ?? json['itemName'] ?? (json['item'] != null && json['item'] is Map ? json['item']['name'] : '') ?? '').toString();
    final itemId = (json['itemId'] ?? json['id'] ?? (json['item'] != null && json['item'] is Map ? json['item']['id'] : '') ?? '').toString();
    final totPrice = parseDouble(json['totalPrice'], qty * cost);

    return PurchaseOrderItemModel(
      id: json['id']?.toString() ?? '',
      itemId: itemId,
      itemName: name,
      quantity: qty,
      unitCost: cost,
      totalPrice: totPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      if (itemName.isNotEmpty) 'itemName': itemName,
      'quantity': quantity,
      'buyPrice': unitCost,
      'unitCost': unitCost,
      'totalPrice': totalPrice,
    };
  }
}

class PurchaseOrderModel {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final String supplierCompany;
  final List<PurchaseOrderItemModel> items;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String note;
  final DateTime createdAt;

  const PurchaseOrderModel({
    required this.id,
    this.poNumber = '',
    required this.supplierId,
    this.supplierName = '',
    this.supplierCompany = '',
    required this.items,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    this.status = 'received',
    this.note = '',
    required this.createdAt,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, double def) {
      if (val == null) return def;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? def;
      return def;
    }

    final itemsList = (json['items'] as List?)
            ?.map((e) => PurchaseOrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final total = parseDouble(json['totalAmount'] ?? json['total'], 0.0);
    final paid = parseDouble(json['paidAmount'] ?? json['paid'], 0.0);
    final calculatedTotal = total > 0 ? total : itemsList.fold(0.0, (sum, i) => sum + i.totalPrice);
    final due = parseDouble(json['dueAmount'] ?? json['due'], calculatedTotal - paid);

    final supName = json['supplierName'] ?? (json['supplier'] != null && json['supplier'] is Map ? json['supplier']['name'] : '') ?? '';
    final supId = json['supplierId'] ?? (json['supplier'] != null && json['supplier'] is Map ? json['supplier']['id'] : '') ?? '';
    final supComp = json['supplierCompany'] ?? (json['supplier'] != null && json['supplier'] is Map ? json['supplier']['companyName'] : '') ?? '';

    final dateStr = json['date'] ?? json['createdAt'];
    final date = dateStr != null ? (DateTime.tryParse(dateStr.toString()) ?? DateTime.now()) : DateTime.now();

    return PurchaseOrderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      poNumber: json['poNumber']?.toString() ?? '',
      supplierId: supId.toString(),
      supplierName: supName.toString(),
      supplierCompany: supComp.toString(),
      items: itemsList,
      totalAmount: calculatedTotal,
      paidAmount: paid,
      dueAmount: due > 0 ? due : 0.0,
      status: json['status']?.toString() ?? 'received',
      note: json['note']?.toString() ?? '',
      createdAt: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'items': items.map((e) => {
        'itemId': e.itemId,
        'quantity': e.quantity,
        'buyPrice': e.unitCost,
      }).toList(),
      'paidAmount': paidAmount,
      'status': status,
      'note': note,
    };
  }
}
