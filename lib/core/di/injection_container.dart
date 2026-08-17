import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/inventory/data/datasources/inventory_local_data_source.dart';
import '../../features/inventory/data/datasources/inventory_remote_data_source.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/add_inventory_item_usecase.dart';
import '../../features/inventory/domain/usecases/delete_inventory_item_usecase.dart';
import '../../features/inventory/domain/usecases/get_inventory_items_usecase.dart';
import '../../features/inventory/domain/usecases/update_inventory_item_usecase.dart';
import '../../features/customers/data/datasources/customer_local_data_source.dart';
import '../../features/customers/data/datasources/customer_remote_data_source.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/update_customer_usecase.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../features/posbilling/data/datasources/pos_local_data_source.dart';
import '../../features/posbilling/data/datasources/pos_remote_data_source.dart';
import '../../features/posbilling/data/repositories/pos_repository_impl.dart';
import '../../features/posbilling/domain/repositories/pos_repository.dart';
import '../../features/posbilling/domain/usecases/create_sale_usecase.dart';
import '../../features/posbilling/domain/usecases/get_sales_logs_usecase.dart';
import '../../features/posbilling/presentation/bloc/pos_bloc.dart';
import '../../features/reports/data/datasources/reports_local_data_source.dart';
import '../../features/reports/data/datasources/reports_remote_data_source.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_invoice_logs_usecase.dart';
import '../../features/reports/domain/usecases/get_reports_summary_usecase.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';

import '../../features/returnandrestoke/data/datasources/returns_local_data_source.dart';
import '../../features/returnandrestoke/data/datasources/returns_remote_data_source.dart';
import '../../features/returnandrestoke/data/repositories/returns_repository_impl.dart';
import '../../features/returnandrestoke/domain/repositories/returns_repository.dart';
import '../../features/returnandrestoke/domain/usecases/get_return_logs_usecase.dart';
import '../../features/returnandrestoke/domain/usecases/process_return_usecase.dart';
import '../../features/returnandrestoke/presentation/bloc/returns_bloc.dart';

/// Service Locator / Dependency Injection Container
///
/// Instantiates and wires together DataSources, Repositories, UseCases, Network Clients, and BLoC instances.
class InjectionContainer {
  // Core Infrastructure
  static late final ApiClient apiClient;

  // Data Sources
  static late final AuthLocalDataSource authLocalDataSource;
  static late final AuthRemoteDataSource authRemoteDataSource;
  static late final InventoryLocalDataSource inventoryLocalDataSource;
  static late final InventoryRemoteDataSource inventoryRemoteDataSource;
  static late final CustomerLocalDataSource customerLocalDataSource;
  static late final CustomerRemoteDataSource customerRemoteDataSource;
  static late final PosLocalDataSource posLocalDataSource;
  static late final PosRemoteDataSource posRemoteDataSource;
  static late final ReportsLocalDataSource reportsLocalDataSource;
  static late final ReportsRemoteDataSource reportsRemoteDataSource;
  static late final ReturnsLocalDataSource returnsLocalDataSource;
  static late final ReturnsRemoteDataSource returnsRemoteDataSource;

  // Repositories
  static late final AuthRepository authRepository;
  static late final InventoryRepository inventoryRepository;
  static late final CustomerRepository customerRepository;
  static late final PosRepository posRepository;
  static late final ReportsRepository reportsRepository;
  static late final ReturnsRepository returnsRepository;

  // UseCases - Auth
  static late final LoginUseCase loginUseCase;
  static late final RegisterUseCase registerUseCase;
  static late final ForgotPasswordUseCase forgotPasswordUseCase;
  static late final ResetPasswordUseCase resetPasswordUseCase;
  static late final GetMeUseCase getMeUseCase;
  static late final LogoutUseCase logoutUseCase;

  // UseCases - Inventory
  static late final GetInventoryItemsUseCase getInventoryItemsUseCase;
  static late final AddInventoryItemUseCase addInventoryItemUseCase;
  static late final UpdateInventoryItemUseCase updateInventoryItemUseCase;
  static late final DeleteInventoryItemUseCase deleteInventoryItemUseCase;

  // UseCases - Customer
  static late final GetCustomersUseCase getCustomersUseCase;
  static late final AddCustomerUseCase addCustomerUseCase;
  static late final UpdateCustomerUseCase updateCustomerUseCase;
  static late final DeleteCustomerUseCase deleteCustomerUseCase;

  // UseCases - POS
  static late final CreateSaleUseCase createSaleUseCase;
  static late final GetSalesLogsUseCase getSalesLogsUseCase;

  // UseCases - Reports
  static late final GetReportsSummaryUseCase getReportsSummaryUseCase;
  static late final GetInvoiceLogsUseCase getInvoiceLogsUseCase;

  // UseCases - Returns
  static late final ProcessReturnUseCase processReturnUseCase;
  static late final GetReturnLogsUseCase getReturnLogsUseCase;

  // BLoC State Management
  static late final AuthBloc authBloc;
  static late final InventoryBloc inventoryBloc;
  static late final CustomerBloc customerBloc;
  static late final PosBloc posBloc;
  static late final ReportsBloc reportsBloc;
  static late final ReturnsBloc returnsBloc;

  /// Initializes all dependencies at app startup in [main].
  static void init() {
    // 1. Network & Data Sources
    apiClient = ApiClient();
    authLocalDataSource = AuthLocalDataSourceImpl();
    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);

    inventoryLocalDataSource = InventoryLocalDataSourceImpl();
    inventoryRemoteDataSource = InventoryRemoteDataSourceImpl(apiClient);

    customerLocalDataSource = CustomerLocalDataSourceImpl();
    customerRemoteDataSource = CustomerRemoteDataSourceImpl(apiClient);

    posLocalDataSource = PosLocalDataSourceImpl();
    posRemoteDataSource = PosRemoteDataSourceImpl(apiClient);

    reportsLocalDataSource = ReportsLocalDataSourceImpl();
    reportsRemoteDataSource = ReportsRemoteDataSourceImpl(apiClient);

    returnsLocalDataSource = ReturnsLocalDataSourceImpl();
    returnsRemoteDataSource = ReturnsRemoteDataSourceImpl(apiClient);

    // 2. Repository Contract Implementation
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      apiClient: apiClient,
    );

    inventoryRepository = InventoryRepositoryImpl(
      remoteDataSource: inventoryRemoteDataSource,
      localDataSource: inventoryLocalDataSource,
    );

    customerRepository = CustomerRepositoryImpl(
      remoteDataSource: customerRemoteDataSource,
      localDataSource: customerLocalDataSource,
    );

    posRepository = PosRepositoryImpl(
      remoteDataSource: posRemoteDataSource,
      localDataSource: posLocalDataSource,
    );

    reportsRepository = ReportsRepositoryImpl(
      remoteDataSource: reportsRemoteDataSource,
      localDataSource: reportsLocalDataSource,
      posLocalDataSource: posLocalDataSource,
    );

    returnsRepository = ReturnsRepositoryImpl(
      remoteDataSource: returnsRemoteDataSource,
      localDataSource: returnsLocalDataSource,
    );

    // 3. Domain UseCases
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    resetPasswordUseCase = ResetPasswordUseCase(authRepository);
    getMeUseCase = GetMeUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);

    getInventoryItemsUseCase = GetInventoryItemsUseCase(inventoryRepository);
    addInventoryItemUseCase = AddInventoryItemUseCase(inventoryRepository);
    updateInventoryItemUseCase = UpdateInventoryItemUseCase(inventoryRepository);
    deleteInventoryItemUseCase = DeleteInventoryItemUseCase(inventoryRepository);

    getCustomersUseCase = GetCustomersUseCase(customerRepository);
    addCustomerUseCase = AddCustomerUseCase(customerRepository);
    updateCustomerUseCase = UpdateCustomerUseCase(customerRepository);
    deleteCustomerUseCase = DeleteCustomerUseCase(customerRepository);

    createSaleUseCase = CreateSaleUseCase(posRepository);
    getSalesLogsUseCase = GetSalesLogsUseCase(posRepository);

    getReportsSummaryUseCase = GetReportsSummaryUseCase(reportsRepository);
    getInvoiceLogsUseCase = GetInvoiceLogsUseCase(reportsRepository);

    processReturnUseCase = ProcessReturnUseCase(returnsRepository);
    getReturnLogsUseCase = GetReturnLogsUseCase(returnsRepository);

    // 4. BLoC State Management Instances
    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      forgotPasswordUseCase: forgotPasswordUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
      getMeUseCase: getMeUseCase,
      logoutUseCase: logoutUseCase,
      apiClient: apiClient,
    );

    inventoryBloc = InventoryBloc(
      getItemsUseCase: getInventoryItemsUseCase,
      addItemUseCase: addInventoryItemUseCase,
      updateItemUseCase: updateInventoryItemUseCase,
      deleteItemUseCase: deleteInventoryItemUseCase,
    );

    customerBloc = CustomerBloc(
      getCustomersUseCase: getCustomersUseCase,
      addCustomerUseCase: addCustomerUseCase,
      updateCustomerUseCase: updateCustomerUseCase,
      deleteCustomerUseCase: deleteCustomerUseCase,
    );

    posBloc = PosBloc(
      createSaleUseCase: createSaleUseCase,
      getSalesLogsUseCase: getSalesLogsUseCase,
    );

    reportsBloc = ReportsBloc(
      getReportsSummaryUseCase: getReportsSummaryUseCase,
      getInvoiceLogsUseCase: getInvoiceLogsUseCase,
    );

    returnsBloc = ReturnsBloc(
      processReturnUseCase: processReturnUseCase,
      getReturnLogsUseCase: getReturnLogsUseCase,
    );
  }
}
