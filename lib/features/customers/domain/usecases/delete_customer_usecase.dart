import '../repositories/customer_repository.dart';

/// UseCase: Soft-deletes a customer.
class DeleteCustomerUseCase {
  final CustomerRepository repository;

  const DeleteCustomerUseCase(this.repository);

  Future<void> call(String customerId) {
    return repository.deleteCustomer(customerId);
  }
}
