import '../entities/sale_entity.dart';
import '../repositories/pos_repository.dart';

/// UseCase: Fetches sales logs history.
class GetSalesLogsUseCase {
  final PosRepository repository;

  const GetSalesLogsUseCase(this.repository);

  Future<List<SaleEntity>> call() {
    return repository.getSalesLogs();
  }
}
