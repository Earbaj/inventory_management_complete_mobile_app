import '../repositories/supplier_repository.dart';

class DeleteSupplierUseCase {
  final SupplierRepository repository;

  const DeleteSupplierUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteSupplier(id);
  }
}
