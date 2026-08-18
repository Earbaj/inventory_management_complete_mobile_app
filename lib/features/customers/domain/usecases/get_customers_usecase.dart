import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// UseCase: Fetches customers list from repository.
class GetCustomersUseCase {
  final CustomerRepository repository;

  const GetCustomersUseCase(this.repository);

  Future<List<CustomerEntity>> call({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) {
    return repository.getCustomers(
      page: page,
      limit: limit,
      searchQuery: searchQuery,
    );
  }
}
