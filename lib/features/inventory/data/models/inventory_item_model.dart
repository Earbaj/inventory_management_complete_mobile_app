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
    return InventoryItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? 'General',
      unit: json['unit'] ?? 'Piece',
      stockQuantity: (json['stockQuantity'] ?? json['stock_quantity'] ?? 0) as int,
      lowStockQuantity: (json['lowStockQuantity'] ?? json['low_stock_quantity'] ?? 5) as int,
      retailSellPrice: (json['retailSellPrice'] ?? json['retail_sell_price'] ?? json['price'] ?? 0.0).toDouble(),
      purchasePrice: (json['purchasePrice'] ?? json['purchase_price'] ?? json['buyPrice'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'lowStockQuantity': lowStockQuantity,
      'retailSellPrice': retailSellPrice,
      'purchasePrice': purchasePrice,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
