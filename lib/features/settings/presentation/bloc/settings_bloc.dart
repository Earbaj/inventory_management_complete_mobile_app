import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_shop_profile_usecase.dart';
import '../../domain/usecases/get_subscription_status_usecase.dart';
import '../../domain/usecases/update_shop_profile_usecase.dart';
import '../../domain/usecases/upgrade_subscription_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetShopProfileUseCase getShopProfileUseCase;
  final GetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  final UpdateShopProfileUseCase updateShopProfileUseCase;
  final UpgradeSubscriptionUseCase upgradeSubscriptionUseCase;

  ShopProfileEntity? _currentProfile;
  SubscriptionEntity? _currentSubscription;

  SettingsBloc({
    required this.getShopProfileUseCase,
    required this.getSubscriptionStatusUseCase,
    required this.updateShopProfileUseCase,
    required this.upgradeSubscriptionUseCase,
  }) : super(const SettingsInitialState()) {
    on<FetchSettingsEvent>(_onFetchSettings);
    on<UpdateShopProfileEvent>(_onUpdateShopProfile);
    on<UpgradeSubscriptionEvent>(_onUpgradeSubscription);
  }

  Future<void> _onFetchSettings(
    FetchSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    developer.log('⚙️ [SettingsBloc] _onFetchSettings called', name: 'SettingsBloc');
    if (_currentProfile == null) {
      emit(const SettingsLoadingState());
    }

    try {
      developer.log('⚙️ [SettingsBloc] Fetching shop profile...', name: 'SettingsBloc');
      final profile = await getShopProfileUseCase();
      _currentProfile = profile;
      developer.log('✅ [SettingsBloc] Shop profile fetched successfully: ${profile.shopName}', name: 'SettingsBloc');

      developer.log('⚙️ [SettingsBloc] Fetching subscription status...', name: 'SettingsBloc');
      _currentSubscription = await getSubscriptionStatusUseCase();
      developer.log('✅ [SettingsBloc] Subscription status fetched successfully: tier=${_currentSubscription?.tier}, expiresAt=${_currentSubscription?.expiresAt}', name: 'SettingsBloc');

      emit(SettingsLoadedState(
        profile: _currentProfile!,
        subscription: _currentSubscription!,
      ));
    } catch (e) {
      developer.log('❌ [SettingsBloc] Error in _onFetchSettings: $e', name: 'SettingsBloc');
      emit(SettingsErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateShopProfile(
    UpdateShopProfileEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final updatedProfile = await updateShopProfileUseCase(event.profile);
      _currentProfile = updatedProfile;
      emit(const SettingsOperationSuccessState('Shop settings updated successfully!'));
      if (_currentProfile != null && _currentSubscription != null) {
        emit(SettingsLoadedState(profile: _currentProfile!, subscription: _currentSubscription!));
      }
    } catch (e) {
      emit(SettingsErrorState(e.toString()));
    }
  }

  Future<void> _onUpgradeSubscription(
    UpgradeSubscriptionEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final upgradedSub = await upgradeSubscriptionUseCase(event.targetTier);
      _currentSubscription = upgradedSub;
      emit(const SettingsOperationSuccessState('Subscription upgraded successfully!'));
      if (_currentProfile != null && _currentSubscription != null) {
        emit(SettingsLoadedState(profile: _currentProfile!, subscription: _currentSubscription!));
      }
    } catch (e) {
      emit(SettingsErrorState(e.toString()));
    }
  }
}
