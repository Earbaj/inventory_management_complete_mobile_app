import '../entities/subscription_entity.dart';
import '../repositories/settings_repository.dart';

/// UseCase: Fetches shop subscription status & limits.
class GetSubscriptionStatusUseCase {
  final SettingsRepository repository;

  const GetSubscriptionStatusUseCase(this.repository);

  Future<SubscriptionEntity> call() {
    return repository.getSubscriptionStatus();
  }
}
