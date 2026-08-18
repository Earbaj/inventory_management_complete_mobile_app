import 'dart:async';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/usecases/create_sale_usecase.dart';
import '../../domain/usecases/get_sales_logs_usecase.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc {
  final CreateSaleUseCase createSaleUseCase;
  final GetSalesLogsUseCase getSalesLogsUseCase;

  PosState _state = const PosCartState(cartItems: []);
  final _stateController = StreamController<PosState>.broadcast();

  PosState get state => _state;
  Stream<PosState> get stream => _stateController.stream;

  PosBloc({
    required this.createSaleUseCase,
    required this.getSalesLogsUseCase,
  });

  void add(PosEvent event) {
    _handleEvent(event);
  }

  void _emit(PosState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(PosEvent event) async {
    if (event is AddToCartEvent) {
      _onAddToCart(event);
    } else if (event is RemoveFromCartEvent) {
      _onRemoveFromCart(event);
    } else if (event is UpdateCartQuantityEvent) {
      _onUpdateCartQuantity(event);
    } else if (event is UpdateCartItemDiscountEvent) {
      _onUpdateCartItemDiscount(event);
    } else if (event is SelectPosCustomerEvent) {
      _onSelectCustomer(event);
    } else if (event is ApplyDiscountEvent) {
      _onApplyDiscount(event);
    } else if (event is ClearCartEvent) {
      _onClearCart();
    } else if (event is SubmitCheckoutEvent) {
      await _onSubmitCheckout(event);
    }
  }

  void _onAddToCart(AddToCartEvent event) {
    final currentState = _state is PosCartState ? _state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);

    final index = items.indexWhere((element) => element.item.id == event.item.id);
    if (index != -1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItemEntity(item: event.item, quantity: 1));
    }

    _emit(currentState.copyWith(cartItems: items));
  }

  void _onRemoveFromCart(RemoveFromCartEvent event) {
    final currentState = _state is PosCartState ? _state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);
    items.removeWhere((element) => element.item.id == event.itemId);
    _emit(currentState.copyWith(cartItems: items));
  }

  void _onUpdateCartQuantity(UpdateCartQuantityEvent event) {
    final currentState = _state is PosCartState ? _state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);

    final index = items.indexWhere((element) => element.item.id == event.itemId);
    if (index != -1) {
      if (event.quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: event.quantity);
      }
    }

    _emit(currentState.copyWith(cartItems: items));
  }

  void _onUpdateCartItemDiscount(UpdateCartItemDiscountEvent event) {
    final currentState = _state is PosCartState ? _state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);

    final index = items.indexWhere((element) => element.item.id == event.itemId);
    if (index != -1) {
      items[index] = items[index].copyWith(discount: event.discount);
    }

    _emit(currentState.copyWith(cartItems: items));
  }

  void _onSelectCustomer(SelectPosCustomerEvent event) {
    final currentState = _state is PosCartState ? _state as PosCartState : const PosCartState(cartItems: []);
    if (event.customer == null) {
      _emit(currentState.copyWith(clearCustomer: true));
    } else {
      _emit(currentState.copyWith(selectedCustomer: event.customer));
    }
  }

  void _onApplyDiscount(ApplyDiscountEvent event) {
    final currentState = _state is PosCartState ? _state as PosCartState : const PosCartState(cartItems: []);
    _emit(currentState.copyWith(discountAmount: event.discountAmount));
  }

  void _onClearCart() {
    _emit(const PosCartState(cartItems: []));
  }

  Future<void> _onSubmitCheckout(SubmitCheckoutEvent event) async {
    final currentState = _state is PosCartState ? _state as PosCartState : null;
    if (currentState == null || currentState.cartItems.isEmpty) {
      _emit(const PosCheckoutErrorState('Cart is empty! Please add items before checkout.'));
      return;
    }

    _emit(const PosCheckoutLoadingState());

    try {
      final generatedInvoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final netTotal = currentState.netTotal;
      final paidAmount = event.paidAmount.clamp(0.0, netTotal);
      final dueAmount = (netTotal - paidAmount).clamp(0.0, double.infinity);

      final saleToSubmit = SaleEntity(
        id: '',
        invoiceNo: generatedInvoiceNo,
        customer: currentState.selectedCustomer,
        items: currentState.cartItems,
        subtotal: currentState.rawSubtotal,
        discountAmount: currentState.totalDiscount,
        vatAmount: currentState.vatAmount,
        netTotal: netTotal,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        paymentMethod: event.paymentMethod,
        createdAt: DateTime.now(),
      );

      final completedSale = await createSaleUseCase(saleToSubmit);
      _emit(PosCheckoutSuccessState(completedSale));
      _emit(const PosCartState(cartItems: []));
    } catch (e) {
      _emit(PosCheckoutErrorState(e.toString()));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
