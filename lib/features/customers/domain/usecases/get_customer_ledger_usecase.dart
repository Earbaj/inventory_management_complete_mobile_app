import '../repositories/customer_repository.dart';

class GetCustomerLedgerUseCase {
  final CustomerRepository repository;

  GetCustomerLedgerUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String customerId,
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getCustomerLedger(
      customerId: customerId,
      page: page,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
