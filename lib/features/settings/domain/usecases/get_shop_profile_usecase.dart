import '../entities/shop_profile_entity.dart';
import '../repositories/settings_repository.dart';

/// UseCase: Fetches shop profile settings.
class GetShopProfileUseCase {
  final SettingsRepository repository;

  const GetShopProfileUseCase(this.repository);

  Future<ShopProfileEntity> call() {
    return repository.getShopProfile();
  }
}
