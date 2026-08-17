import '../../posbilling/domain/entities/sale_entity.dart';
import '../repositories/reports_repository.dart';

/// UseCase: Fetches sales invoice transaction logs.
class GetInvoiceLogsUseCase {
  final ReportsRepository repository;

  const GetInvoiceLogsUseCase(this.repository);

  Future<List<SaleEntity>> call({String? invoiceNoQuery, DateTime? startDate, DateTime? endDate}) {
    return repository.getInvoiceLogs(
      invoiceNoQuery: invoiceNoQuery,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
