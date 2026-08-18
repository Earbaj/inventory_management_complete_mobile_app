import '../entities/customer_entity.dart';

/// Abstract Customer Repository Interface Contract
abstract class CustomerRepository {
  /// Fetches customers list with optional search query (name/phone).
  Future<List<CustomerEntity>> getCustomers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// Adds a new customer.
  Future<CustomerEntity> addCustomer(CustomerEntity customer);

  /// Updates an existing customer's details.
  Future<CustomerEntity> updateCustomer(CustomerEntity customer);

  /// Soft-deletes a customer.
  Future<void> deleteCustomer(String customerId);
}
