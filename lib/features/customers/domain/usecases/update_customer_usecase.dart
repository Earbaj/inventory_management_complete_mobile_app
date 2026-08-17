import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// UseCase: Updates an existing customer's details.
class UpdateCustomerUseCase {
  final CustomerRepository repository;

  const UpdateCustomerUseCase(this.repository);

  Future<CustomerEntity> call(CustomerEntity customer) {
    return repository.updateCustomer(customer);
  }
}
