import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';

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
  final List<SupplierEntity> suppliers;
  final List<PurchaseOrderEntity> purchaseOrders;
  final String? successMessage;

  const SupplierLoadedState({
    required this.suppliers,
    required this.purchaseOrders,
    this.successMessage,
  });

  SupplierLoadedState copyWith({
    List<SupplierEntity>? suppliers,
    List<PurchaseOrderEntity>? purchaseOrders,
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
