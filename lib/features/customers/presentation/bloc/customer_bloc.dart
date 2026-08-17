import 'dart:async';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/add_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerState _state = const CustomerInitialState();
  final _stateController = StreamController<CustomerState>.broadcast();

  List<CustomerEntity> _allCustomers = [];
  String _currentSearchQuery = '';

  CustomerState get state => _state;
  Stream<CustomerState> get stream => _stateController.stream;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
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
    } else if (event is AddCustomerEvent) {
      await _onAddCustomer(event);
    } else if (event is UpdateCustomerEvent) {
      await _onUpdateCustomer(event);
    } else if (event is DeleteCustomerEvent) {
      await _onDeleteCustomer(event);
    }
  }

  Future<void> _onFetchCustomers(FetchCustomersEvent event) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_allCustomers.isEmpty) {
      _emit(const CustomerLoadingState());
    }

    try {
      _allCustomers = await getCustomersUseCase(null);
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
