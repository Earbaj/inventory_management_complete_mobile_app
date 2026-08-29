import '../entities/purchase_order_entity.dart';
import '../repositories/supplier_repository.dart';

class GetPurchaseOrdersUseCase {
  final SupplierRepository repository;

  const GetPurchaseOrdersUseCase(this.repository);

  Future<List<PurchaseOrderEntity>> call({String? supplierId, bool forceRefresh = false}) {
    return repository.getPurchaseOrders(supplierId: supplierId, forceRefresh: forceRefresh);
  }
}
