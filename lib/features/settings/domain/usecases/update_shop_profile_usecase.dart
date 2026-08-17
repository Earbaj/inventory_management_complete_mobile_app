import '../entities/shop_profile_entity.dart';
import '../repositories/settings_repository.dart';

/// UseCase: Updates shop profile details & configuration.
class UpdateShopProfileUseCase {
  final SettingsRepository repository;

  const UpdateShopProfileUseCase(this.repository);

  Future<ShopProfileEntity> call(ShopProfileEntity profile) {
    return repository.updateShopProfile(profile);
  }
}
