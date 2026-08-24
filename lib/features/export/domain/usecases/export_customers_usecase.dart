import '../entities/export_file_entity.dart';
import '../repositories/export_repository.dart';

/// UseCase: Export customer list and due balances to CSV file.
class ExportCustomersUseCase {
  final ExportRepository repository;

  const ExportCustomersUseCase(this.repository);

  Future<ExportFileEntity> call() {
    return repository.exportCustomers();
  }
}
