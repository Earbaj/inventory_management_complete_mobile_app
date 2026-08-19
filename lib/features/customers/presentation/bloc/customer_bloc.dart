import 'dart:async';
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

class CustomerBloc {
  final GetCustomersUseCase getCustomersUseCase;
  final GetCustomerDetailsUseCase getCustomerDetailsUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final CollectCustomerPaymentUseCase collectCustomerPaymentUseCase;
  final GetDueReminderLinkUseCase getDueReminderLinkUseCase;

  CustomerState _state = const CustomerInitialState();
  final _stateController = StreamController<CustomerState>.broadcast();

  List<CustomerEntity> _allCustomers = [];
  String _currentSearchQuery = '';

  CustomerState get state => _state;
  Stream<CustomerState> get stream => _stateController.stream;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.getCustomerDetailsUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.collectCustomerPaymentUseCase,
    required this.getDueReminderLinkUseCase,
  });

  void add(CustomerEvent event) {
    _handleEvent(event);
  }

  void _emit(CustomerState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(CustomerEvent event) async {
    if (event is FetchCustomersEvent) {
      await _onFetchCustomers(event);
    } else if (event is FetchCustomerDetailsEvent) {
      await _onFetchCustomerDetails(event);
    } else if (event is AddCustomerEvent) {
      await _onAddCustomer(event);
    } else if (event is UpdateCustomerEvent) {
      await _onUpdateCustomer(event);
    } else if (event is DeleteCustomerEvent) {
      await _onDeleteCustomer(event);
    } else if (event is CollectCustomerPaymentEvent) {
      await _onCollectPayment(event);
    } else if (event is FetchDueReminderLinkEvent) {
      await _onFetchDueReminderLink(event);
    }
  }

  Future<void> _onFetchCustomers(FetchCustomersEvent event) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_allCustomers.isEmpty) {
      _emit(const CustomerLoadingState());
    }

    try {
      _allCustomers = await getCustomersUseCase(
        page: event.page,
        limit: event.limit,
      );
      _emitLoadedState();
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onFetchCustomerDetails(FetchCustomerDetailsEvent event) async {
    try {
      final customer = await getCustomerDetailsUseCase(event.customerId);
      final index = _allCustomers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _allCustomers[index] = customer;
      } else {
        _allCustomers.insert(0, customer);
      }
      _emitLoadedState();
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onAddCustomer(AddCustomerEvent event) async {
    try {
      final savedCustomer = await addCustomerUseCase(event.customer);
      _allCustomers.insert(0, savedCustomer);
      _emit(const CustomerOperationSuccessState('Customer added successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(UpdateCustomerEvent event) async {
    try {
      final updatedCustomer = await updateCustomerUseCase(event.customer);
      final index = _allCustomers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index != -1) {
        _allCustomers[index] = updatedCustomer;
      }
      _emit(const CustomerOperationSuccessState('Customer updated successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event) async {
    try {
      await deleteCustomerUseCase(event.customerId);
      _allCustomers.removeWhere((c) => c.id == event.customerId);
      _emit(const CustomerOperationSuccessState('Customer deleted successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onCollectPayment(CollectCustomerPaymentEvent event) async {
    try {
      await collectCustomerPaymentUseCase(
        customerId: event.customerId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        note: event.note,
      );
      _emit(const CustomerOperationSuccessState('Payment collected successfully!'));

      await _onFetchCustomers(FetchCustomersEvent(searchQuery: _currentSearchQuery));
      try {
        InjectionContainer.reportsBloc.add(const FetchReportsEvent());
      } catch (_) {}
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onFetchDueReminderLink(FetchDueReminderLinkEvent event) async {
    try {
      final res = await getDueReminderLinkUseCase(event.customerId);
      final customerId = res['customerId']?.toString() ?? res['id']?.toString() ?? event.customerId;
      final customerName = res['customerName']?.toString() ?? res['name']?.toString() ?? 'Customer';
      final dueAmount = res['dueAmount']?.toString() ?? '0.00';
      final whatsappUrl = res['whatsappUrl']?.toString() ?? res['url']?.toString() ?? '';

      _emit(DueReminderLinkLoadedState(
        customerId: customerId,
        customerName: customerName,
        dueAmount: dueAmount,
        whatsappUrl: whatsappUrl,
      ));

      _emitLoadedState();
    } catch (e) {
      _emit(CustomerErrorState(e.toString()));
    }
  }

  void _emitLoadedState() {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allCustomers.where((customer) {
      final matchesSearch = query.isEmpty ||
          customer.name.toLowerCase().contains(query) ||
          customer.phone.contains(query);

      return matchesSearch;
    }).toList();

    _emit(CustomerLoadedState(
      customers: _allCustomers,
      filteredCustomers: filtered,
      searchQuery: _currentSearchQuery,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
