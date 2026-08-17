import '../entities/subscription_entity.dart';
import '../repositories/settings_repository.dart';

/// UseCase: Upgrades subscription tier.
class UpgradeSubscriptionUseCase {
  final SettingsRepository repository;

  const UpgradeSubscriptionUseCase(this.repository);

  Future<SubscriptionEntity> call(String targetTier) {
    return repository.upgradeSubscription(targetTier);
  }
}
