import '../entities/customer_entity.dart';

/// Abstract Customer Repository Interface Contract
abstract class CustomerRepository {
  /// Fetches customers list with optional search query (name/phone).
  Future<List<CustomerEntity>> getCustomers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// Fetches single customer profile by ID.
  Future<CustomerEntity> getCustomerDetails(String customerId);

  /// Adds a new customer.
  Future<CustomerEntity> addCustomer(CustomerEntity customer);

  /// Updates an existing customer's details.
  Future<CustomerEntity> updateCustomer(CustomerEntity customer);

  /// Soft-deletes a customer.
  Future<void> deleteCustomer(String customerId);

  /// Process payment against customer due balance.
  Future<void> collectCustomerPayment({
    required String customerId,
    required double amount,
    String paymentMethod = 'cash',
    String? note,
  });

  /// Fetches customer transaction statement ledger.
  Future<Map<String, dynamic>> getCustomerLedger({
    required String customerId,
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetches WhatsApp due payment reminder chat link.
  Future<Map<String, dynamic>> getDueReminderLink(String customerId);
}
