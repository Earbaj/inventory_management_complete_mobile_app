import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// UseCase: Fetches customers list from repository.
class GetCustomersUseCase {
  final CustomerRepository repository;

  const GetCustomersUseCase(this.repository);

  Future<List<CustomerEntity>> call([String? searchQuery]) {
    return repository.getCustomers(searchQuery: searchQuery);
  }
}
