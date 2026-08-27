/// Data Transfer Object (DTO) for Inventory Item REST API JSON payload.
class InventoryItemModel {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unit;
  final int stockQuantity;
  final int lowStockQuantity;
  final double retailSellPrice;
  final double purchasePrice;
  final String? createdAt;
  final String? updatedAt;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.stockQuantity,
    required this.lowStockQuantity,
    required this.retailSellPrice,
    required this.purchasePrice,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, int defaultVal) {
      if (val == null) return defaultVal;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return InventoryItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      unit: json['unit']?.toString() ?? 'pcs',
      stockQuantity: parseInt(json['stockQuantity'] ?? json['stock_quantity'], 0),
      lowStockQuantity: parseInt(json['lowStockQuantity'] ?? json['lowStockThreshold'] ?? json['low_stock_quantity'], 5),
      retailSellPrice: parseDouble(json['retailSellPrice'] ?? json['sellPrice'] ?? json['retail_sell_price'] ?? json['price']),
      purchasePrice: parseDouble(json['purchasePrice'] ?? json['buyPrice'] ?? json['purchase_price']),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  int get quantity => stockQuantity;
  double get costPrice => purchasePrice;

  InventoryItemModel copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    String? unit,
    int? stockQuantity,
    int? quantity,
    int? lowStockQuantity,
    double? retailSellPrice,
    double? purchasePrice,
    double? costPrice,
    String? createdAt,
    String? updatedAt,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      stockQuantity: quantity ?? stockQuantity ?? this.stockQuantity,
      lowStockQuantity: lowStockQuantity ?? this.lowStockQuantity,
      retailSellPrice: retailSellPrice ?? this.retailSellPrice,
      purchasePrice: costPrice ?? purchasePrice ?? this.purchasePrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'lowStockQuantity': lowStockQuantity,
      'lowStockThreshold': lowStockQuantity,
      'retailSellPrice': retailSellPrice,
      'sellPrice': retailSellPrice,
      'purchasePrice': purchasePrice,
      'buyPrice': purchasePrice,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
