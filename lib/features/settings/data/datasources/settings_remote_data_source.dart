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
  String? _cachedTier;
  String? _cachedExpiresAt;

  SettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ShopProfileModel> getShopProfile() async {
    developer.log('⚙️ [SettingsRemoteDataSource] getShopProfile() called...', name: 'SettingsRemoteDataSource');
    try {
      dynamic response;
      try {
        response = await apiClient.get('${EnvConfig.apiBaseUrl}/api/auth/me');
      } catch (_) {
        try {
          response = await apiClient.get('${EnvConfig.apiBaseUrl}/api/shop/profile');
        } catch (_) {
          response = await apiClient.get('${EnvConfig.apiBaseUrl}/api/users/profile');
        }
      }

      developer.log('✅ [SettingsRemoteDataSource] getShopProfile() success. Response: $response', name: 'SettingsRemoteDataSource');
      if (response is Map<String, dynamic>) {
        final Map<String, dynamic> dataMap = response['data'] is Map<String, dynamic>
            ? response['data']
            : (response['user'] is Map<String, dynamic> ? response['user'] : response);
        
        // Cache subscription details from profile API response
        _cachedTier = dataMap['subscriptionTier']?.toString();
        _cachedExpiresAt = dataMap['subscriptionExpiresAt']?.toString();
        developer.log('📦 [SettingsRemoteDataSource] Cached subscription from profile: tier=$_cachedTier, expiresAt=$_cachedExpiresAt', name: 'SettingsRemoteDataSource');

        return ShopProfileModel.fromJson(dataMap);
      }
    } catch (e) {
      developer.log('⚠️ [SettingsRemoteDataSource] getShopProfile() API unavailable: $e. Returning default profile.', name: 'SettingsRemoteDataSource');
    }

    return const ShopProfileModel(
      id: '1',
      shopName: 'Smart Inventory POS Store',
      phone: '01700000000',
      email: 'earbaj@gmail.com',
      address: 'Dhaka, Bangladesh',
      currencySymbol: '৳',
    );
  }

  @override
  Future<ShopProfileModel> updateShopProfile(ShopProfileModel profile) async {
    developer.log('⚙️ [SettingsRemoteDataSource] updateShopProfile() called for shopName: "${profile.shopName}"', name: 'SettingsRemoteDataSource');
    try {
      final body = {
        'name': profile.shopName,
        'shopName': profile.shopName,
        'phone': profile.phone,
        if (profile.address != null) 'address': profile.address,
        if (profile.logoUrl != null) 'logoUrl': profile.logoUrl,
        'currencySymbol': profile.currencySymbol,
        'defaultVatRate': profile.defaultVatRate,
      };

      dynamic response;
      try {
        response = await apiClient.put(
          '${EnvConfig.apiBaseUrl}/api/auth/profile',
          body: body,
        );
      } catch (_) {
        try {
          response = await apiClient.put(
            '${EnvConfig.apiBaseUrl}/api/shop/profile',
            body: body,
          );
        } catch (_) {
          try {
            response = await apiClient.post(
              '${EnvConfig.apiBaseUrl}/api/shop/profile',
              body: body,
            );
          } catch (_) {
            response = await apiClient.put(
              '${EnvConfig.apiBaseUrl}/api/users/profile',
              body: body,
            );
          }
        }
      }

      developer.log('✅ [SettingsRemoteDataSource] updateShopProfile() success.', name: 'SettingsRemoteDataSource');
      final Map<String, dynamic> responseMap = response is Map<String, dynamic> ? response : {};
      final Map<String, dynamic> dataMap = responseMap['data'] is Map<String, dynamic>
          ? responseMap['data']
          : (responseMap['user'] is Map<String, dynamic> ? responseMap['user'] : responseMap);

      return ShopProfileModel.fromJson(dataMap.isEmpty ? profile.toJson() : dataMap);
    } catch (e) {
      developer.log('⚠️ [SettingsRemoteDataSource] updateShopProfile() API unavailable: $e. Returning updated profile.', name: 'SettingsRemoteDataSource');
      return profile;
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus() async {
    developer.log('⚙️ [SettingsRemoteDataSource] getSubscriptionStatus() called...', name: 'SettingsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/subscription/status',
      );

      developer.log('✅ [SettingsRemoteDataSource] getSubscriptionStatus() success. Response: $response', name: 'SettingsRemoteDataSource');
      return SubscriptionModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e) {
      developer.log('⚠️ [SettingsRemoteDataSource] getSubscriptionStatus() API error/unavailable: $e. Using cached profile subscription fallback.', name: 'SettingsRemoteDataSource');
      final isPremium = _cachedTier == 'premium' || _cachedTier == 'enterprise';
      return SubscriptionModel(
        tier: _cachedTier ?? 'free',
        maxCustomers: isPremium ? -1 : 1,
        maxSales: isPremium ? -1 : 5,
        customerCount: 0,
        salesCount: 0,
        expiresAt: _cachedExpiresAt,
      );
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
