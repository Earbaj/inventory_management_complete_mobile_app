import '../entities/export_file_entity.dart';
import '../repositories/export_repository.dart';

/// UseCase: Export inventory product list to CSV file.
class ExportInventoryUseCase {
  final ExportRepository repository;

  const ExportInventoryUseCase(this.repository);

  Future<ExportFileEntity> call() {
    return repository.exportInventory();
  }
}
