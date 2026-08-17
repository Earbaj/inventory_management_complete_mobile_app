import '../entities/sale_entity.dart';
import '../repositories/pos_repository.dart';

/// UseCase: Creates a new POS sale transaction.
class CreateSaleUseCase {
  final PosRepository repository;

  const CreateSaleUseCase(this.repository);

  Future<SaleEntity> call(SaleEntity sale) {
    return repository.createSale(sale);
  }
}
