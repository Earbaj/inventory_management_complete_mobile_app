import '../../../../core/error/failures.dart';
import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../datasources/settings_remote_data_source.dart';
import '../mappers/settings_mapper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ShopProfileEntity> getShopProfile() async {
    try {
      final remoteModel = await remoteDataSource.getShopProfile();
      await localDataSource.cacheShopProfile(remoteModel);
      return SettingsMapper.shopProfileModelToEntity(remoteModel);
    } catch (_) {
      final cached = await localDataSource.getCachedShopProfile();
      if (cached == null) {
        throw const ServerFailure('Something went wrong. Could not load shop profile.');
      }
      return SettingsMapper.shopProfileModelToEntity(cached);
    }
  }

  @override
  Future<ShopProfileEntity> updateShopProfile(ShopProfileEntity profile) async {
    final modelToSave = SettingsMapper.shopProfileEntityToModel(profile);
    try {
      final updatedModel = await remoteDataSource.updateShopProfile(modelToSave);
      await localDataSource.cacheShopProfile(updatedModel);
      return SettingsMapper.shopProfileModelToEntity(updatedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to update shop profile. Please try again.');
    }
  }

  @override
  Future<SubscriptionEntity> getSubscriptionStatus() async {
    try {
      final remoteModel = await remoteDataSource.getSubscriptionStatus();
      await localDataSource.cacheSubscription(remoteModel);
      return SettingsMapper.subscriptionModelToEntity(remoteModel);
    } catch (_) {
      final cached = await localDataSource.getCachedSubscription();
      if (cached == null) {
        throw const ServerFailure('Something went wrong. Could not load subscription status.');
      }
      return SettingsMapper.subscriptionModelToEntity(cached);
    }
  }

  @override
  Future<SubscriptionEntity> upgradeSubscription(String targetTier) async {
    try {
      final upgradedModel = await remoteDataSource.upgradeSubscription(targetTier);
      await localDataSource.cacheSubscription(upgradedModel);
      return SettingsMapper.subscriptionModelToEntity(upgradedModel);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to upgrade subscription tier. Please try again.');
    }
  }
}
