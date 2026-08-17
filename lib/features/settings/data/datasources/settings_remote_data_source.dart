import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/shop_profile_model.dart';
import '../models/subscription_model.dart';

abstract class SettingsRemoteDataSource {
  Future<ShopProfileModel> getShopProfile();
  Future<ShopProfileModel> updateShopProfile(ShopProfileModel profile);
  Future<SubscriptionModel> getSubscriptionStatus();
  Future<SubscriptionModel> upgradeSubscription(String targetTier);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ShopProfileModel> getShopProfile() async {
    developer.log('⚙️ [SettingsRemoteDataSource] getShopProfile() called...', name: 'SettingsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/shop/profile',
      );

      developer.log('✅ [SettingsRemoteDataSource] getShopProfile() success.', name: 'SettingsRemoteDataSource');
      return ShopProfileModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('❌ [SettingsRemoteDataSource] getShopProfile() API Error: $e', name: 'SettingsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ShopProfileModel> updateShopProfile(ShopProfileModel profile) async {
    developer.log('⚙️ [SettingsRemoteDataSource] updateShopProfile() called for shopName: "${profile.shopName}"', name: 'SettingsRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/shop/profile',
        body: profile.toJson(),
      );

      developer.log('✅ [SettingsRemoteDataSource] updateShopProfile() success.', name: 'SettingsRemoteDataSource');
      return ShopProfileModel.fromJson(response is Map<String, dynamic> ? response : profile.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [SettingsRemoteDataSource] updateShopProfile() API Error: $e', name: 'SettingsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus() async {
    developer.log('⚙️ [SettingsRemoteDataSource] getSubscriptionStatus() called...', name: 'SettingsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/subscription/status',
      );

      developer.log('✅ [SettingsRemoteDataSource] getSubscriptionStatus() success.', name: 'SettingsRemoteDataSource');
      return SubscriptionModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('❌ [SettingsRemoteDataSource] getSubscriptionStatus() API Error: $e', name: 'SettingsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<SubscriptionModel> upgradeSubscription(String targetTier) async {
    developer.log('⚙️ [SettingsRemoteDataSource] upgradeSubscription() called for tier: "$targetTier"', name: 'SettingsRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/subscription/upgrade',
        body: {'tier': targetTier},
      );

      developer.log('✅ [SettingsRemoteDataSource] upgradeSubscription() success.', name: 'SettingsRemoteDataSource');
      return SubscriptionModel.fromJson(response is Map<String, dynamic> ? response : {'tier': targetTier});
    } catch (e, stackTrace) {
      developer.log('❌ [SettingsRemoteDataSource] upgradeSubscription() API Error: $e', name: 'SettingsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
