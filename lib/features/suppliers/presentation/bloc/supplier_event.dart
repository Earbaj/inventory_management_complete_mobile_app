import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';

abstract class SupplierEvent {
  const SupplierEvent();
}

class LoadSuppliersEvent extends SupplierEvent {
  final String? search;
  const LoadSuppliersEvent({this.search});
}

class CreateSupplierEvent extends SupplierEvent {
  final SupplierEntity supplier;
  const CreateSupplierEvent(this.supplier);
}

class UpdateSupplierEvent extends SupplierEvent {
  final SupplierEntity supplier;
  const UpdateSupplierEvent(this.supplier);
}

class DeleteSupplierEvent extends SupplierEvent {
  final String id;
  const DeleteSupplierEvent(this.id);
}

class CreatePurchaseOrderEvent extends SupplierEvent {
  final PurchaseOrderEntity order;
  const CreatePurchaseOrderEvent(this.order);
}

class LoadPurchaseOrdersEvent extends SupplierEvent {
  final String? supplierId;
  const LoadPurchaseOrdersEvent({this.supplierId});
}
