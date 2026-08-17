import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// UseCase: Adds a new customer.
class AddCustomerUseCase {
  final CustomerRepository repository;

  const AddCustomerUseCase(this.repository);

  Future<CustomerEntity> call(CustomerEntity customer) {
    return repository.addCustomer(customer);
  }
}
