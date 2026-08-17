import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/entities/subscription_entity.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitialState extends SettingsState {
  const SettingsInitialState();
}

class SettingsLoadingState extends SettingsState {
  const SettingsLoadingState();
}

class SettingsLoadedState extends SettingsState {
  final ShopProfileEntity profile;
  final SubscriptionEntity subscription;

  const SettingsLoadedState({
    required this.profile,
    required this.subscription,
  });
}

class SettingsOperationSuccessState extends SettingsState {
  final String message;

  const SettingsOperationSuccessState(this.message);
}

class SettingsErrorState extends SettingsState {
  final String message;

  const SettingsErrorState(this.message);
}
