import 'dart:async';
import 'dart:developer' as developer;
import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_shop_profile_usecase.dart';
import '../../domain/usecases/get_subscription_status_usecase.dart';
import '../../domain/usecases/update_shop_profile_usecase.dart';
import '../../domain/usecases/upgrade_subscription_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc {
  final GetShopProfileUseCase getShopProfileUseCase;
  final GetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
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
    required this.getSubscriptionStatusUseCase,
    required this.updateShopProfileUseCase,
    required this.upgradeSubscriptionUseCase,
  });

  void add(SettingsEvent event) {
    _handleEvent(event);
  }

  void _emit(SettingsState newState) {
    developer.log('📣 [SettingsBloc] Emitting state: $newState', name: 'SettingsBloc');
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(SettingsEvent event) async {
    developer.log('📥 [SettingsBloc] Handling event: $event', name: 'SettingsBloc');
    if (event is FetchSettingsEvent) {
      await _onFetchSettings(event);
    } else if (event is UpdateShopProfileEvent) {
      await _onUpdateShopProfile(event);
    } else if (event is UpgradeSubscriptionEvent) {
      await _onUpgradeSubscription(event);
    }
  }

  Future<void> _onFetchSettings(FetchSettingsEvent event) async {
    developer.log('⚙️ [SettingsBloc] _onFetchSettings called', name: 'SettingsBloc');
    if (_currentProfile == null) {
      _emit(const SettingsLoadingState());
    }

    try {
      developer.log('⚙️ [SettingsBloc] Fetching shop profile...', name: 'SettingsBloc');
      final profile = await getShopProfileUseCase();
      _currentProfile = profile;
      developer.log('✅ [SettingsBloc] Shop profile fetched successfully: ${profile.shopName}', name: 'SettingsBloc');

      developer.log('⚙️ [SettingsBloc] Fetching subscription status...', name: 'SettingsBloc');
      _currentSubscription = await getSubscriptionStatusUseCase();
      developer.log('✅ [SettingsBloc] Subscription status fetched successfully: tier=${_currentSubscription?.tier}, expiresAt=${_currentSubscription?.expiresAt}', name: 'SettingsBloc');

      _emit(SettingsLoadedState(
        profile: _currentProfile!,
        subscription: _currentSubscription!,
      ));
    } catch (e) {
      developer.log('❌ [SettingsBloc] Error in _onFetchSettings: $e', name: 'SettingsBloc');
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
