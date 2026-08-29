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
  final bool isListLoading;

  const SupplierLoadedState({
    required this.suppliers,
    required this.purchaseOrders,
    this.successMessage,
    this.isSaving = false,
    this.isListLoading = false,
  });

  SupplierLoadedState copyWith({
    List<SupplierEntity>? suppliers,
    List<PurchaseOrderEntity>? purchaseOrders,
    String? successMessage,
    bool? isSaving,
    bool? isListLoading,
  }) {
    return SupplierLoadedState(
      suppliers: suppliers ?? this.suppliers,
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      successMessage: successMessage,
      isSaving: isSaving ?? this.isSaving,
      isListLoading: isListLoading ?? this.isListLoading,
    );
  }
}

class SupplierErrorState extends SupplierState {
  final String message;
  final List<SupplierEntity> previousSuppliers;
  final List<PurchaseOrderEntity> previousPurchaseOrders;

  const SupplierErrorState(
    this.message, {
    this.previousSuppliers = const [],
    this.previousPurchaseOrders = const [],
  });
}
