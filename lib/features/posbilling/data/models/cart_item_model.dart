import '../../../inventory/data/models/inventory_item_model.dart';

/// Data Transfer Object (DTO) for Cart Items in JSON payloads.
class CartItemModel {
  final InventoryItemModel item;
  final int quantity;

  const CartItemModel({
    required this.item,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final itemData = json['item'] is Map<String, dynamic>
        ? json['item']
        : {
            'id': json['itemId']?.toString() ?? '',
            'name': json['name'] ?? '',
            'sku': json['sku'] ?? '',
            'category': json['category'] ?? 'General',
            'unit': json['unit'] ?? 'Piece',
            'stockQuantity': json['stockQuantity'] ?? 100,
            'lowStockQuantity': json['lowStockQuantity'] ?? 5,
            'retailSellPrice': (json['unitPrice'] ?? json['retailSellPrice'] ?? 0.0).toDouble(),
            'purchasePrice': (json['purchasePrice'] ?? 0.0).toDouble(),
          };

    return CartItemModel(
      item: InventoryItemModel.fromJson(itemData),
      quantity: (json['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': item.id,
      'name': item.name,
      'sku': item.sku,
      'quantity': quantity,
      'unitPrice': item.retailSellPrice,
      'totalPrice': quantity * item.retailSellPrice,
      'item': item.toJson(),
    };
  }
}
