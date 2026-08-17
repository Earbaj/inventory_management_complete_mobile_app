import '../entities/shop_profile_entity.dart';
import '../entities/subscription_entity.dart';

/// Abstract Settings & Subscription Repository Contract
abstract class SettingsRepository {
  /// Fetches shop profile settings (GET /api/shop/profile).
  Future<ShopProfileEntity> getShopProfile();

  /// Updates shop profile settings (POST /api/shop/profile).
  Future<ShopProfileEntity> updateShopProfile(ShopProfileEntity profile);

  /// Fetches subscription status & limits (GET /api/subscription/status).
  Future<SubscriptionEntity> getSubscriptionStatus();

  /// Upgrades subscription tier (POST /api/subscription/upgrade).
  Future<SubscriptionEntity> upgradeSubscription(String targetTier);
}
