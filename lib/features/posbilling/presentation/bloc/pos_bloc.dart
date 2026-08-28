import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/usecases/create_sale_usecase.dart';
import '../../domain/usecases/get_sales_logs_usecase.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final CreateSaleUseCase createSaleUseCase;
  final GetSalesLogsUseCase getSalesLogsUseCase;

  PosBloc({
    required this.createSaleUseCase,
    required this.getSalesLogsUseCase,
  }) : super(const PosCartState(cartItems: [])) {
    // 🎯 ইভেন্ট হ্যান্ডলার রেজিস্টার
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartQuantityEvent>(_onUpdateCartQuantity);
    on<UpdateCartItemDiscountEvent>(_onUpdateCartItemDiscount);
    on<SelectPosCustomerEvent>(_onSelectCustomer);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<ClearCartEvent>(_onClearCart);
    on<SubmitCheckoutEvent>(_onSubmitCheckout);
  }

  void _onAddToCart(AddToCartEvent event, Emitter<PosState> emit) {
    final currentState = state is PosCartState ? state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);

    final index = items.indexWhere((element) => element.item.id == event.item.id);
    if (index != -1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItemEntity(item: event.item, quantity: 1));
    }

    emit(currentState.copyWith(cartItems: items));
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<PosState> emit) {
    final currentState = state is PosCartState ? state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);
    items.removeWhere((element) => element.item.id == event.itemId);

    emit(currentState.copyWith(cartItems: items));
  }

  void _onUpdateCartQuantity(UpdateCartQuantityEvent event, Emitter<PosState> emit) {
    final currentState = state is PosCartState ? state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);

    final index = items.indexWhere((element) => element.item.id == event.itemId);
    if (index != -1) {
      if (event.quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: event.quantity);
      }
    }

    emit(currentState.copyWith(cartItems: items));
  }

  void _onUpdateCartItemDiscount(UpdateCartItemDiscountEvent event, Emitter<PosState> emit) {
    final currentState = state is PosCartState ? state as PosCartState : const PosCartState(cartItems: []);
    final items = List<CartItemEntity>.from(currentState.cartItems);

    final index = items.indexWhere((element) => element.item.id == event.itemId);
    if (index != -1) {
      items[index] = items[index].copyWith(discount: event.discount);
    }

    emit(currentState.copyWith(cartItems: items));
  }

  void _onSelectCustomer(SelectPosCustomerEvent event, Emitter<PosState> emit) {
    final currentState = state is PosCartState ? state as PosCartState : const PosCartState(cartItems: []);
    if (event.customer == null) {
      emit(currentState.copyWith(clearCustomer: true));
    } else {
      emit(currentState.copyWith(selectedCustomer: event.customer));
    }
  }

  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<PosState> emit) {
    final currentState = state is PosCartState ? state as PosCartState : const PosCartState(cartItems: []);
    emit(currentState.copyWith(discountAmount: event.discountAmount));
  }

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    emit(const PosCartState(cartItems: []));
  }

  Future<void> _onSubmitCheckout(SubmitCheckoutEvent event, Emitter<PosState> emit) async {
    final currentState = state is PosCartState ? state as PosCartState : null;
    if (currentState == null || currentState.cartItems.isEmpty) {
      emit(const PosCheckoutErrorState('Cart is empty! Please add items before checkout.'));
      return;
    }

    emit(const PosCheckoutLoadingState());

    try {
      final generatedInvoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final netTotal = currentState.netTotal;
      final paidAmount = event.paymentMethod.toLowerCase() == 'due'
          ? 0.0
          : event.paidAmount.clamp(0.0, netTotal);
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
      emit(PosCheckoutSuccessState(completedSale));
      emit(const PosCartState(cartItems: []));

      // Refresh other blocs immediately
      try {
        InjectionContainer.reportsBloc.add(const FetchReportsEvent());
        InjectionContainer.customerBloc.add(const FetchCustomersEvent());
        InjectionContainer.inventoryBloc.add(const FetchInventoryItemsEvent());
      } catch (_) {}
    } catch (e) {
      emit(PosCheckoutErrorState(e.toString()));
    }
  }
}