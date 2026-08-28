import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_entity.dart';

abstract class CustomerState extends Equatable{
  const CustomerState();
  @override
  List<Object?> get props => [];
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
  @override
  List<Object?> get props => [customers,filteredCustomers,searchQuery];
}

class CustomerOperationSuccessState extends CustomerState {
  final String message;
  const CustomerOperationSuccessState(this.message);
  @override
  List<Object?> get props => [message];
}

class DueReminderLinkLoadedState extends CustomerState {
  final String customerId;
  final String customerName;
  final String dueAmount;
  final String whatsappUrl;

  const DueReminderLinkLoadedState({
    required this.customerId,
    required this.customerName,
    required this.dueAmount,
    required this.whatsappUrl,
  });
  @override
  List<Object?> get props => [customerId, customerName, dueAmount, whatsappUrl];
}

class CustomerErrorState extends CustomerState {
  final String message;
  final List<CustomerEntity> previousCustomers; // 🔥 to keep previous customer
  const CustomerErrorState(this.message, {this.previousCustomers = const []});
  @override
  List<Object?> get props => [message, previousCustomers];
}
