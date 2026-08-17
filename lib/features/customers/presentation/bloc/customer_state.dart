import '../../domain/entities/customer_entity.dart';

abstract class CustomerState {
  const CustomerState();
}

class CustomerInitialState extends CustomerState {
  const CustomerInitialState();
}

class CustomerLoadingState extends CustomerState {
  const CustomerLoadingState();
}

class CustomerLoadedState extends CustomerState {
  final List<CustomerEntity> customers;
  final List<CustomerEntity> filteredCustomers;
  final String searchQuery;

  const CustomerLoadedState({
    required this.customers,
    required this.filteredCustomers,
    required this.searchQuery,
  });

  double get totalDues => customers.fold(0.0, (sum, customer) => sum + customer.totalDue);
  int get dueCustomersCount => customers.where((customer) => customer.hasDue).length;
}

class CustomerOperationSuccessState extends CustomerState {
  final String message;
  const CustomerOperationSuccessState(this.message);
}

class CustomerErrorState extends CustomerState {
  final String message;
  const CustomerErrorState(this.message);
}
