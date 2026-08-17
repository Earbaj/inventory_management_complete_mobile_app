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
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/shop/profile',
    );
    return ShopProfileModel.fromJson(response is Map<String, dynamic> ? response : {});
  }

  @override
  Future<ShopProfileModel> updateShopProfile(ShopProfileModel profile) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/shop/profile',
      body: profile.toJson(),
    );
    return ShopProfileModel.fromJson(response is Map<String, dynamic> ? response : profile.toJson());
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus() async {
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/subscription/status',
    );
    return SubscriptionModel.fromJson(response is Map<String, dynamic> ? response : {});
  }

  @override
  Future<SubscriptionModel> upgradeSubscription(String targetTier) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/subscription/upgrade',
      body: {'tier': targetTier},
    );
    return SubscriptionModel.fromJson(response is Map<String, dynamic> ? response : {'tier': targetTier});
  }
}
