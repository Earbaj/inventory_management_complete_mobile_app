import '../entities/export_file_entity.dart';
import '../repositories/export_repository.dart';

/// UseCase: Export single customer transaction ledger to CSV file.
class ExportCustomerLedgerUseCase {
  final ExportRepository repository;

  const ExportCustomerLedgerUseCase(this.repository);

  Future<ExportFileEntity> call(String customerId) {
    return repository.exportCustomerLedger(customerId);
  }
}
