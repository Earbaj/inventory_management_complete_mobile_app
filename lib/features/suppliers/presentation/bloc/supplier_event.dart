import '../../data/models/supplier_model.dart';
import '../../data/models/purchase_order_model.dart';

abstract class SupplierEvent {
  const SupplierEvent();
}

class LoadSuppliersEvent extends SupplierEvent {
  final String? search;
  const LoadSuppliersEvent({this.search});
}

class CreateSupplierEvent extends SupplierEvent {
  final SupplierModel supplier;
  const CreateSupplierEvent(this.supplier);
}

class UpdateSupplierEvent extends SupplierEvent {
  final SupplierModel supplier;
  const UpdateSupplierEvent(this.supplier);
}

class DeleteSupplierEvent extends SupplierEvent {
  final String id;
  const DeleteSupplierEvent(this.id);
}

class CreatePurchaseOrderEvent extends SupplierEvent {
  final PurchaseOrderModel order;
  const CreatePurchaseOrderEvent(this.order);
}

class LoadPurchaseOrdersEvent extends SupplierEvent {
  final String? supplierId;
  const LoadPurchaseOrdersEvent({this.supplierId});
}
