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
import '../../features/customers/domain/usecases/collect_customer_payment_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_details_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/get_due_reminder_link_usecase.dart';
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
import '../../features/recycle_bin/data/datasources/recycle_bin_remote_data_source.dart';
import '../../features/recycle_bin/data/repositories/recycle_bin_repository_impl.dart';
import '../../features/recycle_bin/domain/repositories/recycle_bin_repository.dart';
import '../../features/recycle_bin/domain/usecases/get_trash_items_usecase.dart';
import '../../features/recycle_bin/domain/usecases/permanent_delete_trash_item_usecase.dart';
import '../../features/recycle_bin/domain/usecases/restore_trash_item_usecase.dart';
import '../../features/recycle_bin/presentation/bloc/recycle_bin_bloc.dart';
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

import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/datasources/settings_remote_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_shop_profile_usecase.dart';
import '../../features/settings/domain/usecases/get_subscription_status_usecase.dart';
import '../../features/settings/domain/usecases/update_shop_profile_usecase.dart';
import '../../features/settings/domain/usecases/upgrade_subscription_usecase.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/staff_managers/data/datasources/staff_local_data_source.dart';
import '../../features/staff_managers/data/datasources/staff_remote_data_source.dart';
import '../../features/staff_managers/data/repositories/staff_repository_impl.dart';
import '../../features/staff_managers/domain/repositories/staff_repository.dart';
import '../../features/staff_managers/domain/usecases/add_staff_member_usecase.dart';
import '../../features/staff_managers/domain/usecases/delete_staff_member_usecase.dart';
import '../../features/staff_managers/domain/usecases/get_staff_members_usecase.dart';
import '../../features/staff_managers/domain/usecases/update_staff_member_usecase.dart';
import '../../features/staff_managers/presentation/bloc/staff_bloc.dart';

import '../../features/subscription/data/datasources/subscription_remote_data_source.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/domain/usecases/submit_payment_usecase.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';

import '../../features/super_admin/data/datasources/super_admin_remote_data_source.dart';
import '../../features/super_admin/presentation/bloc/super_admin_bloc.dart';
import '../network/api_client.dart';

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
  static late final SettingsLocalDataSource settingsLocalDataSource;
  static late final SettingsRemoteDataSource settingsRemoteDataSource;
  static late final StaffLocalDataSource staffLocalDataSource;
  static late final StaffRemoteDataSource staffRemoteDataSource;
  static late final SubscriptionRemoteDataSource subscriptionRemoteDataSource;
  static late final SuperAdminRemoteDataSource superAdminRemoteDataSource;
  static late final RecycleBinRemoteDataSource recycleBinRemoteDataSource;

  // Repositories
  static late final AuthRepository authRepository;
  static late final InventoryRepository inventoryRepository;
  static late final CustomerRepository customerRepository;
  static late final PosRepository posRepository;
  static late final ReportsRepository reportsRepository;
  static late final ReturnsRepository returnsRepository;
  static late final SettingsRepository settingsRepository;
  static late final StaffRepository staffRepository;
  static late final SubscriptionRepository subscriptionRepository;
  static late final RecycleBinRepository recycleBinRepository;

  // Use Cases
  static late final LoginUseCase loginUseCase;
  static late final RegisterUseCase registerUseCase;
  static late final ForgotPasswordUseCase forgotPasswordUseCase;
  static late final ResetPasswordUseCase resetPasswordUseCase;
  static late final GetMeUseCase getMeUseCase;
  static late final LogoutUseCase logoutUseCase;

  static late final GetInventoryItemsUseCase getInventoryItemsUseCase;
  static late final AddInventoryItemUseCase addInventoryItemUseCase;
  static late final UpdateInventoryItemUseCase updateInventoryItemUseCase;
  static late final DeleteInventoryItemUseCase deleteInventoryItemUseCase;

  static late final GetCustomersUseCase getCustomersUseCase;
  static late final GetCustomerDetailsUseCase getCustomerDetailsUseCase;
  static late final AddCustomerUseCase addCustomerUseCase;
  static late final UpdateCustomerUseCase updateCustomerUseCase;
  static late final DeleteCustomerUseCase deleteCustomerUseCase;
  static late final CollectCustomerPaymentUseCase collectCustomerPaymentUseCase;
  static late final GetDueReminderLinkUseCase getDueReminderLinkUseCase;

  static late final CreateSaleUseCase createSaleUseCase;
  static late final GetSalesLogsUseCase getSalesLogsUseCase;

  static late final GetReportsSummaryUseCase getReportsSummaryUseCase;
  static late final GetInvoiceLogsUseCase getInvoiceLogsUseCase;

  static late final ProcessReturnUseCase processReturnUseCase;
  static late final GetReturnLogsUseCase getReturnLogsUseCase;

  static late final GetShopProfileUseCase getShopProfileUseCase;
  static late final GetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  static late final UpdateShopProfileUseCase updateShopProfileUseCase;
  static late final UpgradeSubscriptionUseCase upgradeSubscriptionUseCase;

  static late final GetStaffMembersUseCase getStaffMembersUseCase;
  static late final AddStaffMemberUseCase addStaffMemberUseCase;
  static late final UpdateStaffMemberUseCase updateStaffMemberUseCase;
  static late final DeleteStaffMemberUseCase deleteStaffMemberUseCase;

  static late final SubmitPaymentUseCase submitPaymentUseCase;

  static late final GetTrashItemsUseCase getTrashItemsUseCase;
  static late final RestoreTrashItemUseCase restoreTrashItemUseCase;
  static late final PermanentDeleteTrashItemUseCase permanentDeleteTrashItemUseCase;

  // BLoC State Controllers
  static late final AuthBloc authBloc;
  static late final InventoryBloc inventoryBloc;
  static late final CustomerBloc customerBloc;
  static late final PosBloc posBloc;
  static late final ReportsBloc reportsBloc;
  static late final ReturnsBloc returnsBloc;
  static late final SettingsBloc settingsBloc;
  static late final StaffBloc staffBloc;
  static late final SubscriptionBloc subscriptionBloc;
  static late final SuperAdminBloc superAdminBloc;
  static late final RecycleBinBloc recycleBinBloc;

  /// Initializes all singletons and dependencies.
  static Future<void> init() async {
    // 1. Core Network Infrastructure
    apiClient = ApiClient();

    // 2. Data Sources
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

    settingsLocalDataSource = SettingsLocalDataSourceImpl();
    settingsRemoteDataSource = SettingsRemoteDataSourceImpl(apiClient);

    staffLocalDataSource = StaffLocalDataSourceImpl();
    staffRemoteDataSource = StaffRemoteDataSourceImpl(apiClient);

    subscriptionRemoteDataSource = SubscriptionRemoteDataSourceImpl(apiClient);
    superAdminRemoteDataSource = SuperAdminRemoteDataSourceImpl(apiClient);
    recycleBinRemoteDataSource = RecycleBinRemoteDataSourceImpl(apiClient);

    // 3. Repositories
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

    settingsRepository = SettingsRepositoryImpl(
      remoteDataSource: settingsRemoteDataSource,
      localDataSource: settingsLocalDataSource,
    );

    staffRepository = StaffRepositoryImpl(
      remoteDataSource: staffRemoteDataSource,
      localDataSource: staffLocalDataSource,
    );

    subscriptionRepository = SubscriptionRepositoryImpl(
      remoteDataSource: subscriptionRemoteDataSource,
    );

    recycleBinRepository = RecycleBinRepositoryImpl(
      remoteDataSource: recycleBinRemoteDataSource,
    );

    // UseCases
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
    getCustomerDetailsUseCase = GetCustomerDetailsUseCase(customerRepository);
    addCustomerUseCase = AddCustomerUseCase(customerRepository);
    updateCustomerUseCase = UpdateCustomerUseCase(customerRepository);
    deleteCustomerUseCase = DeleteCustomerUseCase(customerRepository);
    collectCustomerPaymentUseCase = CollectCustomerPaymentUseCase(customerRepository);
    getDueReminderLinkUseCase = GetDueReminderLinkUseCase(customerRepository);

    createSaleUseCase = CreateSaleUseCase(posRepository);
    getSalesLogsUseCase = GetSalesLogsUseCase(posRepository);

    getReportsSummaryUseCase = GetReportsSummaryUseCase(reportsRepository);
    getInvoiceLogsUseCase = GetInvoiceLogsUseCase(reportsRepository);

    processReturnUseCase = ProcessReturnUseCase(returnsRepository);
    getReturnLogsUseCase = GetReturnLogsUseCase(returnsRepository);

    getShopProfileUseCase = GetShopProfileUseCase(settingsRepository);
    getSubscriptionStatusUseCase = GetSubscriptionStatusUseCase(settingsRepository);
    updateShopProfileUseCase = UpdateShopProfileUseCase(settingsRepository);
    upgradeSubscriptionUseCase = UpgradeSubscriptionUseCase(settingsRepository);

    getStaffMembersUseCase = GetStaffMembersUseCase(staffRepository);
    addStaffMemberUseCase = AddStaffMemberUseCase(staffRepository);
    updateStaffMemberUseCase = UpdateStaffMemberUseCase(staffRepository);
    deleteStaffMemberUseCase = DeleteStaffMemberUseCase(staffRepository);

    submitPaymentUseCase = SubmitPaymentUseCase(subscriptionRepository);

    getTrashItemsUseCase = GetTrashItemsUseCase(recycleBinRepository);
    restoreTrashItemUseCase = RestoreTrashItemUseCase(recycleBinRepository);
    permanentDeleteTrashItemUseCase = PermanentDeleteTrashItemUseCase(recycleBinRepository);

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
      remoteDataSource: inventoryRemoteDataSource,
    );

    customerBloc = CustomerBloc(
      getCustomersUseCase: getCustomersUseCase,
      getCustomerDetailsUseCase: getCustomerDetailsUseCase,
      addCustomerUseCase: addCustomerUseCase,
      updateCustomerUseCase: updateCustomerUseCase,
      deleteCustomerUseCase: deleteCustomerUseCase,
      collectCustomerPaymentUseCase: collectCustomerPaymentUseCase,
      getDueReminderLinkUseCase: getDueReminderLinkUseCase,
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

    settingsBloc = SettingsBloc(
      getShopProfileUseCase: getShopProfileUseCase,
      getSubscriptionStatusUseCase: getSubscriptionStatusUseCase,
      updateShopProfileUseCase: updateShopProfileUseCase,
      upgradeSubscriptionUseCase: upgradeSubscriptionUseCase,
    );

    staffBloc = StaffBloc(
      getStaffMembersUseCase: getStaffMembersUseCase,
      addStaffMemberUseCase: addStaffMemberUseCase,
      updateStaffMemberUseCase: updateStaffMemberUseCase,
      deleteStaffMemberUseCase: deleteStaffMemberUseCase,
    );

    subscriptionBloc = SubscriptionBloc(
      submitPaymentUseCase: submitPaymentUseCase,
    );

    superAdminBloc = SuperAdminBloc(
      remoteDataSource: superAdminRemoteDataSource,
    );

    recycleBinBloc = RecycleBinBloc(
      getTrashItemsUseCase: getTrashItemsUseCase,
      restoreTrashItemUseCase: restoreTrashItemUseCase,
      permanentDeleteTrashItemUseCase: permanentDeleteTrashItemUseCase,
    );
  }
}
