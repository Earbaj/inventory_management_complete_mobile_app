import '../../data/models/supplier_model.dart';
import '../../data/models/purchase_order_model.dart';

abstract class SupplierState {
  const SupplierState();
}

class SupplierInitialState extends SupplierState {
  const SupplierInitialState();
}

class SupplierLoadingState extends SupplierState {
  const SupplierLoadingState();
}

class SupplierLoadedState extends SupplierState {
  final List<SupplierModel> suppliers;
  final List<PurchaseOrderModel> purchaseOrders;
  final String? successMessage;

  const SupplierLoadedState({
    required this.suppliers,
    required this.purchaseOrders,
    this.successMessage,
  });

  SupplierLoadedState copyWith({
    List<SupplierModel>? suppliers,
    List<PurchaseOrderModel>? purchaseOrders,
    String? successMessage,
  }) {
    return SupplierLoadedState(
      suppliers: suppliers ?? this.suppliers,
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      successMessage: successMessage,
    );
  }
}

class SupplierErrorState extends SupplierState {
  final String message;
  const SupplierErrorState(this.message);
}
