import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class CreateSupplierUseCase {
  final SupplierRepository repository;

  const CreateSupplierUseCase(this.repository);

  Future<SupplierEntity> call(SupplierEntity supplier) {
    return repository.createSupplier(supplier);
  }
}
