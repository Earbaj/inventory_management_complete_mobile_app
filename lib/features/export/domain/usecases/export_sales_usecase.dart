import '../entities/export_file_entity.dart';
import '../repositories/export_repository.dart';

/// UseCase: Export sales invoices history to CSV file.
class ExportSalesUseCase {
  final ExportRepository repository;

  const ExportSalesUseCase(this.repository);

  Future<ExportFileEntity> call() {
    return repository.exportSales();
  }
}
