import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSuppliersUseCase {
  final SupplierRepository repository;

  const GetSuppliersUseCase(this.repository);

  Future<List<SupplierEntity>> call({String? search, bool forceRefresh = false}) {
    return repository.getSuppliers(search: search, forceRefresh: forceRefresh);
  }
}
