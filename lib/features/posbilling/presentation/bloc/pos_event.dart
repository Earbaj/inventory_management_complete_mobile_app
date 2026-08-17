import '../../customers/domain/entities/customer_entity.dart';
import '../../inventory/domain/entities/inventory_item_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class PosEvent {
  const PosEvent();
}

/// Event: Adds an inventory item to the shopping cart.
class AddToCartEvent extends PosEvent {
  final InventoryItemEntity item;

  const AddToCartEvent(this.item);
}

/// Event: Removes a line item from the cart.
class RemoveFromCartEvent extends PosEvent {
  final String itemId;

  const RemoveFromCartEvent(this.itemId);
}

/// Event: Updates quantity for a specific cart line item.
class UpdateCartQuantityEvent extends PosEvent {
  final String itemId;
  final int quantity;

  const UpdateCartQuantityEvent({
    required this.itemId,
    required this.quantity,
  });
}

/// Event: Selects or attaches a customer for the sale.
class SelectPosCustomerEvent extends PosEvent {
  final CustomerEntity? customer;

  const SelectPosCustomerEvent(this.customer);
}

/// Event: Applies a custom discount amount.
class ApplyDiscountEvent extends PosEvent {
  final double discountAmount;

  const ApplyDiscountEvent(this.discountAmount);
}

/// Event: Submits checkout sale transaction to backend.
class SubmitCheckoutEvent extends PosEvent {
  final String paymentMethod; // 'cash', 'bkash', 'card', 'due'
  final double paidAmount;

  const SubmitCheckoutEvent({
    required this.paymentMethod,
    required this.paidAmount,
  });
}

/// Event: Clears current shopping cart.
class ClearCartEvent extends PosEvent {
  const ClearCartEvent();
}
