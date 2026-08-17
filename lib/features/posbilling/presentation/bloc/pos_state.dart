import '../../../customers/domain/entities/customer_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/sale_entity.dart';

abstract class PosState {
  const PosState();
}

class PosInitialState extends PosState {
  const PosInitialState();
}

/// Active Shopping Cart State holding cart items, customer, discount, and computed totals.
class PosCartState extends PosState {
  final List<CartItemEntity> cartItems;
  final CustomerEntity? selectedCustomer;
  final double discountAmount;

  const PosCartState({
    required this.cartItems,
    this.selectedCustomer,
    this.discountAmount = 0.0,
  });

  int get totalItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get vatAmount => 0.0; // Can be configured
  double get netTotal => (subtotal - discountAmount + vatAmount).clamp(0.0, double.infinity);

  PosCartState copyWith({
    List<CartItemEntity>? cartItems,
    CustomerEntity? selectedCustomer,
    bool clearCustomer = false,
    double? discountAmount,
  }) {
    return PosCartState(
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer: clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

class PosCheckoutLoadingState extends PosState {
  const PosCheckoutLoadingState();
}

class PosCheckoutSuccessState extends PosState {
  final SaleEntity completedSale;

  const PosCheckoutSuccessState(this.completedSale);
}

class PosCheckoutErrorState extends PosState {
  final String message;

  const PosCheckoutErrorState(this.message);
}
