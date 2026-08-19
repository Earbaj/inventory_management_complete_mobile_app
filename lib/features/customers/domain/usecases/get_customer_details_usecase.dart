import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// UseCase to fetch full profile details for a single customer by ID.
class GetCustomerDetailsUseCase {
  final CustomerRepository repository;

  GetCustomerDetailsUseCase(this.repository);

  Future<CustomerEntity> call(String customerId) async {
    return await repository.getCustomerDetails(customerId);
  }
}
