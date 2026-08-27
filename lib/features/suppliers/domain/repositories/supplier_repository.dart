import '../entities/supplier_entity.dart';
import '../entities/purchase_order_entity.dart';

abstract class SupplierRepository {
  Future<List<SupplierEntity>> getSuppliers({String? search});
  Future<SupplierEntity> getSupplierById(String id);
  Future<SupplierEntity> createSupplier(SupplierEntity supplier);
  Future<SupplierEntity> updateSupplier(SupplierEntity supplier);
  Future<void> deleteSupplier(String id);
  Future<PurchaseOrderEntity> createPurchaseOrder(PurchaseOrderEntity order);
  Future<List<PurchaseOrderEntity>> getPurchaseOrders({String? supplierId});
}
