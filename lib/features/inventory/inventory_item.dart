class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unit;

  final int lowStockQuantity;
  final int stockQuantity;

  final double retailSellPrice;
  final double purchasePrice;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.lowStockQuantity,
    required this.stockQuantity,
    required this.retailSellPrice,
    required this.purchasePrice,
  });

  bool get isOutOfStock => stockQuantity == 0;

  bool get isLowStock =>
      stockQuantity > 0 &&
          stockQuantity <= lowStockQuantity;

  InventoryItem copyWith({
    String? name,
    String? sku,
    String? category,
    String? unit,
    int? lowStockQuantity,
    int? stockQuantity,
    double? retailSellPrice,
    double? purchasePrice,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      lowStockQuantity:
      lowStockQuantity ?? this.lowStockQuantity,
      stockQuantity:
      stockQuantity ?? this.stockQuantity,
      retailSellPrice:
      retailSellPrice ?? this.retailSellPrice,
      purchasePrice:
      purchasePrice ?? this.purchasePrice,
    );
  }
}