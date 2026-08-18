import '../../../inventory/domain/entities/inventory_item_entity.dart';

/// Domain Entity representing an item in the POS Shopping Cart.
class CartItemEntity {
  final InventoryItemEntity item;
  final int quantity;
  final double discount; // Product-level discount amount (Tk)

  const CartItemEntity({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
  });

  /// Raw subtotal before discount (quantity * retailSellPrice)
  double get rawSubtotal => quantity * item.retailSellPrice;

  /// Total price for this cart line item after product discount.
  double get totalPrice => (rawSubtotal - discount).clamp(0.0, double.infinity);

  CartItemEntity copyWith({
    InventoryItemEntity? item,
    int? quantity,
    double? discount,
  }) {
    return CartItemEntity(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
