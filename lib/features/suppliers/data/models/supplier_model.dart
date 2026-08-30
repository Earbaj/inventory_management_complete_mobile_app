import 'purchase_order_model.dart';

class SupplierModel {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final double totalPurchases;
  final double dueAmount;
  final List<PurchaseOrderModel> purchaseOrders;
  final DateTime createdAt;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.address,
    this.totalPurchases = 0.0,
    this.dueAmount = 0.0,
    this.purchaseOrders = const [],
    required this.createdAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, double def) {
      if (val == null) return def;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? def;
      return def;
    }

    double total = parseDouble(json['totalPurchases'] ?? json['totalAmount'], 0.0);
    double due = parseDouble(json['dueAmount'] ?? json['due'], 0.0);

    final List<PurchaseOrderModel> orders = [];
    if (json['purchaseOrders'] is List && (json['purchaseOrders'] as List).isNotEmpty) {
      final poList = json['purchaseOrders'] as List;
      double calcTotal = 0.0;
      double calcDue = 0.0;
      for (final po in poList) {
        if (po is Map) {
          final order = PurchaseOrderModel.fromJson(Map<String, dynamic>.from(po));
          orders.add(order);
          calcTotal += order.totalAmount;
          calcDue += order.dueAmount;
        }
      }
      if (total == 0 && calcTotal > 0) total = calcTotal;
      if (due == 0 && calcDue > 0) due = calcDue;
    }

    return SupplierModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      totalPurchases: total,
      dueAmount: due,
      purchaseOrders: orders,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'phone': phone,
      'email': email,
      'address': address,
      'totalPurchases': totalPurchases,
      'dueAmount': dueAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? companyName,
    String? phone,
    String? email,
    String? address,
    double? totalPurchases,
    double? dueAmount,
    List<PurchaseOrderModel>? purchaseOrders,
    DateTime? createdAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      dueAmount: dueAmount ?? this.dueAmount,
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
