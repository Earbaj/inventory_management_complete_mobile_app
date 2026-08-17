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
import '../../features/inventory/data/datasources/inventory_local_data_source.dart';
import '../../features/inventory/data/datasources/inventory_remote_data_source.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/add_inventory_item_usecase.dart';
import '../../features/inventory/domain/usecases/delete_inventory_item_usecase.dart';
import '../../features/inventory/domain/usecases/get_inventory_items_usecase.dart';
import '../../features/inventory/domain/usecases/update_inventory_item_usecase.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

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

  // Repositories
  static late final AuthRepository authRepository;
  static late final InventoryRepository inventoryRepository;

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

  // BLoC State Management
  static late final AuthBloc authBloc;
  static late final InventoryBloc inventoryBloc;

  /// Initializes all dependencies at app startup in [main].
  static void init() {
    // 1. Network & Data Sources
    apiClient = ApiClient();
    authLocalDataSource = AuthLocalDataSourceImpl();
    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);

    inventoryLocalDataSource = InventoryLocalDataSourceImpl();
    inventoryRemoteDataSource = InventoryRemoteDataSourceImpl(apiClient);

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
  }
}
