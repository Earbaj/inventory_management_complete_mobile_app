import 'dart:async';
import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_shop_profile_usecase.dart';
import '../../domain/usecases/update_shop_profile_usecase.dart';
import '../../domain/usecases/upgrade_subscription_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc {
  final GetShopProfileUseCase getShopProfileUseCase;
  final UpdateShopProfileUseCase updateShopProfileUseCase;
  final UpgradeSubscriptionUseCase upgradeSubscriptionUseCase;

  SettingsState _state = const SettingsInitialState();
  final _stateController = StreamController<SettingsState>.broadcast();

  ShopProfileEntity? _currentProfile;
  SubscriptionEntity? _currentSubscription;

  SettingsState get state => _state;
  Stream<SettingsState> get stream => _stateController.stream;

  SettingsBloc({
    required this.getShopProfileUseCase,
    required this.updateShopProfileUseCase,
    required this.upgradeSubscriptionUseCase,
  });

  void add(SettingsEvent event) {
    _handleEvent(event);
  }

  void _emit(SettingsState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(SettingsEvent event) async {
    if (event is FetchSettingsEvent) {
      await _onFetchSettings(event);
    } else if (event is UpdateShopProfileEvent) {
      await _onUpdateShopProfile(event);
    } else if (event is UpgradeSubscriptionEvent) {
      await _onUpgradeSubscription(event);
    }
  }

  Future<void> _onFetchSettings(FetchSettingsEvent event) async {
    if (_currentProfile == null) {
      _emit(const SettingsLoadingState());
    }

    try {
      final profile = await getShopProfileUseCase();
      _currentProfile = profile;
      _currentSubscription = const SubscriptionEntity(
        tier: 'free',
        customerCount: 1,
        maxCustomers: 1,
        salesCount: 3,
        maxSales: 5,
      );

      _emit(SettingsLoadedState(
        profile: _currentProfile!,
        subscription: _currentSubscription!,
      ));
    } catch (e) {
      _emit(SettingsErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateShopProfile(UpdateShopProfileEvent event) async {
    try {
      final updatedProfile = await updateShopProfileUseCase(event.profile);
      _currentProfile = updatedProfile;
      _emit(const SettingsOperationSuccessState('Shop settings updated successfully!'));
      if (_currentProfile != null && _currentSubscription != null) {
        _emit(SettingsLoadedState(profile: _currentProfile!, subscription: _currentSubscription!));
      }
    } catch (e) {
      _emit(SettingsErrorState(e.toString()));
    }
  }

  Future<void> _onUpgradeSubscription(UpgradeSubscriptionEvent event) async {
    try {
      final upgradedSub = await upgradeSubscriptionUseCase(event.targetTier);
      _currentSubscription = upgradedSub;
      _emit(const SettingsOperationSuccessState('Subscription upgraded successfully!'));
      if (_currentProfile != null && _currentSubscription != null) {
        _emit(SettingsLoadedState(profile: _currentProfile!, subscription: _currentSubscription!));
      }
    } catch (e) {
      _emit(SettingsErrorState(e.toString()));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
