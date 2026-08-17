import '../models/shop_profile_model.dart';
import '../models/subscription_model.dart';

abstract class SettingsLocalDataSource {
  Future<void> cacheShopProfile(ShopProfileModel profile);
  Future<ShopProfileModel?> getCachedShopProfile();
  Future<void> cacheSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel?> getCachedSubscription();
  Future<bool> isCacheValid();
  Future<void> clearCache();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static ShopProfileModel? _cachedProfile;
  static SubscriptionModel? _cachedSubscription;
  static DateTime? _lastCacheTime;

  /// 5 Minutes Time-To-Live (TTL) Cache Expiry Duration
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    if (_lastCacheTime == null) return false;
    final difference = DateTime.now().difference(_lastCacheTime!);
    return difference < _cacheTtl;
  }

  @override
  Future<void> cacheShopProfile(ShopProfileModel profile) async {
    _cachedProfile = profile;
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<ShopProfileModel?> getCachedShopProfile() async {
    final valid = await isCacheValid();
    if (!valid) {
      _cachedProfile = null;
      return null;
    }
    return _cachedProfile;
  }

  @override
  Future<void> cacheSubscription(SubscriptionModel subscription) async {
    _cachedSubscription = subscription;
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<SubscriptionModel?> getCachedSubscription() async {
    final valid = await isCacheValid();
    if (!valid) {
      _cachedSubscription = null;
      return null;
    }
    return _cachedSubscription;
  }

  @override
  Future<void> clearCache() async {
    _cachedProfile = null;
    _cachedSubscription = null;
    _lastCacheTime = null;
  }
}
