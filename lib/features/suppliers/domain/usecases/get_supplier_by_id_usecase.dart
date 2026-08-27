import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSupplierByIdUseCase {
  final SupplierRepository repository;

  const GetSupplierByIdUseCase(this.repository);

  Future<SupplierEntity> call(String id) {
    return repository.getSupplierById(id);
  }
}
