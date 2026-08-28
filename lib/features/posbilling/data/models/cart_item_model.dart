import '../../../inventory/data/models/inventory_item_model.dart';

/// Data Transfer Object (DTO) for Cart Items in JSON payloads.
class CartItemModel {
  final InventoryItemModel item;
  final int quantity;
  final double discount;
  final String discountType;

  const CartItemModel({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
    this.discountType = 'amount',
  });

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

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
            'retailSellPrice': _parseDouble(json['unitPrice'] ?? json['retailSellPrice']),
            'purchasePrice': _parseDouble(json['purchasePrice']),
          };

    return CartItemModel(
      item: InventoryItemModel.fromJson(itemData),
      quantity: (json['quantity'] ?? 1) as int,
      discount: _parseDouble(json['discount']),
      discountType: json['discountType']?.toString() ?? 'amount',
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'itemId': item.id,
      'quantity': quantity,
      'unitPrice': item.retailSellPrice,
      'discount': discount,
      'discountType': discountType,
    };
  }

  Map<String, dynamic> toJson() {
    final double discountTk = discountType == 'percent'
        ? (quantity * item.retailSellPrice * (discount / 100.0))
        : discount;
    return {
      'itemId': item.id,
      'name': item.name,
      'sku': item.sku,
      'quantity': quantity,
      'unitPrice': item.retailSellPrice,
      'discount': discount,
      'discountType': discountType,
      'totalPrice': (quantity * item.retailSellPrice - discountTk).clamp(0.0, double.infinity),
      'item': item.toJson(),
    };
  }
}
