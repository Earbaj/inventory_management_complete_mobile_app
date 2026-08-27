import '../entities/purchase_order_entity.dart';
import '../repositories/supplier_repository.dart';

class CreatePurchaseOrderUseCase {
  final SupplierRepository repository;

  const CreatePurchaseOrderUseCase(this.repository);

  Future<PurchaseOrderEntity> call(PurchaseOrderEntity order) {
    return repository.createPurchaseOrder(order);
  }
}
