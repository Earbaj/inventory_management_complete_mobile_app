import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../models/shop_profile_model.dart';
import '../models/subscription_model.dart';

/// Translator mapping between Settings DTO Models and Domain Entities.
class SettingsMapper {
  static ShopProfileEntity shopProfileModelToEntity(ShopProfileModel model) {
    return ShopProfileEntity(
      id: model.id,
      shopName: model.shopName,
      phone: model.phone,
      email: model.email,
      address: model.address,
      currencySymbol: model.currencySymbol,
      currencyCode: model.currencyCode,
      defaultVatRate: model.defaultVatRate,
      logoUrl: model.logoUrl,
    );
  }

  static ShopProfileModel shopProfileEntityToModel(ShopProfileEntity entity) {
    return ShopProfileModel(
      id: entity.id,
      shopName: entity.shopName,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      currencySymbol: entity.currencySymbol,
      currencyCode: entity.currencyCode,
      defaultVatRate: entity.defaultVatRate,
      logoUrl: entity.logoUrl,
    );
  }

  static SubscriptionEntity subscriptionModelToEntity(SubscriptionModel model) {
    return SubscriptionEntity(
      tier: model.tier,
      customerCount: model.customerCount,
      maxCustomers: model.maxCustomers,
      salesCount: model.salesCount,
      maxSales: model.maxSales,
      expiresAt: model.expiresAt != null ? DateTime.tryParse(model.expiresAt!) : null,
      isExpired: model.isExpired,
    );
  }

  static SubscriptionModel subscriptionEntityToModel(SubscriptionEntity entity) {
    return SubscriptionModel(
      tier: entity.tier,
      customerCount: entity.customerCount,
      maxCustomers: entity.maxCustomers,
      salesCount: entity.salesCount,
      maxSales: entity.maxSales,
      expiresAt: entity.expiresAt?.toIso8601String(),
      isExpired: entity.isExpired,
    );
  }
}
