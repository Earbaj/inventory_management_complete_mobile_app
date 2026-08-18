/// Domain Entity representing an Inventory Item in the Business Logic Layer.
///
/// Fully decoupled from backend DTOs and database schemas.
class InventoryItemEntity {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unit;
  final int stockQuantity;
  final int lowStockQuantity;
  final double retailSellPrice;
  final double purchasePrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryItemEntity({
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

  /// Computed property: true if current stock is <= low stock threshold and > 0.
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= lowStockQuantity;

  /// Computed property: true if stock quantity is 0 or less.
  bool get isOutOfStock => stockQuantity <= 0;

  /// Alias getter for selling price.
  double get sellPrice => retailSellPrice;

  /// Alias getter for purchase/buying price.
  double get buyPrice => purchasePrice;

  /// Creates a modified copy of [InventoryItemEntity].
  InventoryItemEntity copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    String? unit,
    int? stockQuantity,
    int? lowStockQuantity,
    double? retailSellPrice,
    double? purchasePrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockQuantity: lowStockQuantity ?? this.lowStockQuantity,
      retailSellPrice: retailSellPrice ?? this.retailSellPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
