import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class UpdateSupplierUseCase {
  final SupplierRepository repository;

  const UpdateSupplierUseCase(this.repository);

  Future<SupplierEntity> call(SupplierEntity supplier) {
    return repository.updateSupplier(supplier);
  }
}
