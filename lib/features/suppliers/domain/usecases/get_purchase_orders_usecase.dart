import '../entities/purchase_order_entity.dart';
import '../repositories/supplier_repository.dart';

class GetPurchaseOrdersUseCase {
  final SupplierRepository repository;

  const GetPurchaseOrdersUseCase(this.repository);

  Future<List<PurchaseOrderEntity>> call({String? supplierId}) {
    return repository.getPurchaseOrders(supplierId: supplierId);
  }
}
