import '../../../../core/utils/money_util.dart';
import '../../../inventory/domain/entities/inventory_item_entity.dart';

/// Domain Entity representing an item in the POS Shopping Cart.
class CartItemEntity {
  final InventoryItemEntity item;
  final int quantity;
  final double discount; // Product-level discount value (can be % or flat amount)
  final String discountType; // 'percent' or 'amount'

  const CartItemEntity({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
    this.discountType = 'amount',
  });

  /// Raw subtotal before discount (quantity * retailSellPrice)
  double get rawSubtotal => MoneyUtil.roundMoney(quantity * item.retailSellPrice);

  /// Computed flat discount amount in Tk
  double get discountAmount {
    if (discountType == 'percent') {
      return MoneyUtil.roundMoney((rawSubtotal * (discount / 100.0)).clamp(0.0, rawSubtotal));
    }
    return MoneyUtil.roundMoney(discount.clamp(0.0, rawSubtotal));
  }

  /// Total price for this cart line item after product discount.
  double get totalPrice => MoneyUtil.roundMoney((rawSubtotal - discountAmount).clamp(0.0, double.infinity));

  CartItemEntity copyWith({
    InventoryItemEntity? item,
    int? quantity,
    double? discount,
    String? discountType,
  }) {
    return CartItemEntity(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
    );
  }
}
