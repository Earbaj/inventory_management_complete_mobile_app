import '../../domain/entities/shop_profile_entity.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

/// Event: Fetches shop profile settings and subscription status.
class FetchSettingsEvent extends SettingsEvent {
  const FetchSettingsEvent();
}

/// Event: Updates shop profile details.
class UpdateShopProfileEvent extends SettingsEvent {
  final ShopProfileEntity profile;

  const UpdateShopProfileEvent(this.profile);
}

/// Event: Upgrades subscription tier.
class UpgradeSubscriptionEvent extends SettingsEvent {
  final String targetTier;

  const UpgradeSubscriptionEvent(this.targetTier);
}
