import '../../domain/entities/customer_entity.dart';

abstract class CustomerEvent {
  const CustomerEvent();
}

/// Event: Fetches customers list with optional search query.
class FetchCustomersEvent extends CustomerEvent {
  final int page;
  final int limit;
  final String? searchQuery;

  const FetchCustomersEvent({
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
  });
}

/// Event: Adds a new customer.
class AddCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;

  const AddCustomerEvent(this.customer);
}

/// Event: Updates an existing customer.
class UpdateCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;

  const UpdateCustomerEvent(this.customer);
}

/// Event: Deletes a customer.
class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;

  const DeleteCustomerEvent(this.customerId);
}

/// Event: Collects payment against customer due balance (POST /api/payments).
class CollectCustomerPaymentEvent extends CustomerEvent {
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String? note;

  const CollectCustomerPaymentEvent({
    required this.customerId,
    required this.amount,
    this.paymentMethod = 'cash',
    this.note,
  });
}
