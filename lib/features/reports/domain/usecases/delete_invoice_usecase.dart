import '../repositories/reports_repository.dart';

/// UseCase: Deletes a sales invoice record from backend and local cache.
class DeleteInvoiceUseCase {
  final ReportsRepository repository;

  const DeleteInvoiceUseCase(this.repository);

  Future<void> call(String invoiceId) {
    return repository.deleteInvoice(invoiceId);
  }
}
