import '../../domain/entities/customer_entity.dart';

abstract class CustomerEvent {
  const CustomerEvent();
}

/// Event: Fetches customers list with optional search query.
class FetchCustomersEvent extends CustomerEvent {
  final String? searchQuery;

  const FetchCustomersEvent([this.searchQuery]);
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
