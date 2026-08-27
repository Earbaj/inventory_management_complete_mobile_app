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
  final bool isSaving;

  const SupplierLoadedState({
    required this.suppliers,
    required this.purchaseOrders,
    this.successMessage,
    this.isSaving = false,
  });

  SupplierLoadedState copyWith({
    List<SupplierEntity>? suppliers,
    List<PurchaseOrderEntity>? purchaseOrders,
    String? successMessage,
    bool? isSaving,
  }) {
    return SupplierLoadedState(
      suppliers: suppliers ?? this.suppliers,
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      successMessage: successMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SupplierErrorState extends SupplierState {
  final String message;
  const SupplierErrorState(this.message);
}
