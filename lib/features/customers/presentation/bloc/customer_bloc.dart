import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/add_customer_usecase.dart';
import '../../domain/usecases/collect_customer_payment_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/get_customer_details_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/get_due_reminder_link_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final GetCustomerDetailsUseCase getCustomerDetailsUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final CollectCustomerPaymentUseCase collectCustomerPaymentUseCase;
  final GetDueReminderLinkUseCase getDueReminderLinkUseCase;

  List<CustomerEntity> _allCustomers = [];
  String _currentSearchQuery = '';

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.getCustomerDetailsUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.collectCustomerPaymentUseCase,
    required this.getDueReminderLinkUseCase,
  }) : super(const CustomerInitialState()) {
    // Event Handlers
    on<FetchCustomersEvent>(_onFetchCustomers);
    on<FetchCustomerDetailsEvent>(_onFetchCustomerDetails);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<CollectCustomerPaymentEvent>(_onCollectPayment);
    on<FetchDueReminderLinkEvent>(_onFetchDueReminderLink);
  }

  Future<void> _onFetchCustomers(
      FetchCustomersEvent event,
      Emitter<CustomerState> emit,
      ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_allCustomers.isEmpty) {
      emit(const CustomerLoadingState());
    }

    try {
      _allCustomers = await getCustomersUseCase(
        page: event.page,
        limit: event.limit,
      );
      _emitLoadedState(emit);
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onFetchCustomerDetails(
      FetchCustomerDetailsEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      final customer = await getCustomerDetailsUseCase(event.customerId);
      final index = _allCustomers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _allCustomers[index] = customer;
      } else {
        _allCustomers.insert(0, customer);
      }
      _emitLoadedState(emit);
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomerEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      final savedCustomer = await addCustomerUseCase(event.customer);
      _allCustomers.insert(0, savedCustomer);
      emit(const CustomerOperationSuccessState('Customer added successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomerEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      final updatedCustomer = await updateCustomerUseCase(event.customer);
      final index = _allCustomers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index != -1) {
        _allCustomers[index] = updatedCustomer;
      }
      emit(const CustomerOperationSuccessState('Customer updated successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomerEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      await deleteCustomerUseCase(event.customerId);
      _allCustomers.removeWhere((c) => c.id == event.customerId);
      emit(const CustomerOperationSuccessState('Customer deleted successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onCollectPayment(
      CollectCustomerPaymentEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      await collectCustomerPaymentUseCase(
        customerId: event.customerId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        note: event.note,
      );
      emit(const CustomerOperationSuccessState('Payment collected successfully!'));

      await _onFetchCustomers(
        FetchCustomersEvent(searchQuery: _currentSearchQuery),
        emit,
      );

      try {
        InjectionContainer.reportsBloc.add(const FetchReportsEvent());
      } catch (_) {}
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onFetchDueReminderLink(
      FetchDueReminderLinkEvent event,
      Emitter<CustomerState> emit,
      ) async {
    try {
      final res = await getDueReminderLinkUseCase(event.customerId);
      final customerId = res['customerId']?.toString() ?? res['id']?.toString() ?? event.customerId;
      final customerName = res['customerName']?.toString() ?? res['name']?.toString() ?? 'Customer';
      final dueAmount = res['dueAmount']?.toString() ?? '0.00';
      final whatsappUrl = res['whatsappUrl']?.toString() ?? res['url']?.toString() ?? '';

      emit(DueReminderLinkLoadedState(
        customerId: customerId,
        customerName: customerName,
        dueAmount: dueAmount,
        whatsappUrl: whatsappUrl,
      ));

      _emitLoadedState(emit);
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  void _emitLoadedState(Emitter<CustomerState> emit) {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allCustomers.where((customer) {
      final matchesSearch = query.isEmpty ||
          customer.name.toLowerCase().contains(query) ||
          customer.phone.contains(query);

      return matchesSearch;
    }).toList();

    emit(CustomerLoadedState(
      customers: _allCustomers,
      filteredCustomers: filtered,
      searchQuery: _currentSearchQuery,
    ));
  }
}