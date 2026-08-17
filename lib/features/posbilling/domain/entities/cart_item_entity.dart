import '../../../inventory/domain/entities/inventory_item_entity.dart';

/// Domain Entity representing an item in the POS Shopping Cart.
class CartItemEntity {
  final InventoryItemEntity item;
  final int quantity;

  const CartItemEntity({
    required this.item,
    required this.quantity,
  });

  /// Total price for this cart line item (quantity * retailSellPrice).
  double get totalPrice => quantity * item.retailSellPrice;

  CartItemEntity copyWith({
    InventoryItemEntity? item,
    int? quantity,
  }) {
    return CartItemEntity(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
