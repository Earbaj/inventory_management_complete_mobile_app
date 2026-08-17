import '../entities/return_item_entity.dart';
import '../repositories/returns_repository.dart';

/// UseCase: Fetches return transaction logs.
class GetReturnLogsUseCase {
  final ReturnsRepository repository;

  const GetReturnLogsUseCase(this.repository);

  Future<List<ReturnItemEntity>> call() {
    return repository.getReturnLogs();
  }
}
