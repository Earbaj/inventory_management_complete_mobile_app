import 'dart:developer' as developer;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../subscription/data/models/payment_model.dart';
import '../models/super_admin_metrics_model.dart';
import '../models/shop_item_model.dart';
import '../models/shop_detail_model.dart';

abstract class SuperAdminRemoteDataSource {
  Future<SuperAdminMetricsModel> getSuperAdminMetrics();
  Future<List<PaymentModel>> getPendingPayments({int page = 1, int limit = 20});
  Future<void> approvePayment(String paymentId);
  Future<void> rejectPayment(String paymentId, {String? reason});
  Future<List<ShopItemModel>> getShopsList({int page = 1, int limit = 20, String? search});
  Future<ShopDetailModel> getShopDetails(String id);
  Future<void> deleteShop(String shopId);
}

class SuperAdminRemoteDataSourceImpl implements SuperAdminRemoteDataSource {
  final ApiClient apiClient;

  SuperAdminRemoteDataSourceImpl(this.apiClient);

  @override
  Future<SuperAdminMetricsModel> getSuperAdminMetrics() async {
    developer.log('👑 [SuperAdminRemoteDataSource] Fetching platform metrics from ${ApiEndpoints.superAdminDashboard}...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.get(ApiEndpoints.superAdminDashboard);
      developer.log('✅ [SuperAdminRemoteDataSource] Metrics Response: $response', name: 'SuperAdminRemoteDataSource');
      return SuperAdminMetricsModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('⚠️ [SuperAdminRemoteDataSource] getSuperAdminMetrics() Error: $e. Returning default metrics.', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      return const SuperAdminMetricsModel(
        totalRegisteredShops: 1,
        totalManagersCount: 1,
        freeTierShopsCount: 0,
        premiumTierShopsCount: 1,
        pendingPaymentRequestsCount: 0,
        totalSubscriptionRevenue: 0.0,
        platformTotalItems: 0,
        platformTotalSales: 0,
      );
    }
  }

  @override
  Future<List<PaymentModel>> getPendingPayments({int page = 1, int limit = 20}) async {
    developer.log('👑 [SuperAdminRemoteDataSource] Calling GET ${ApiEndpoints.pendingPayments}...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.pendingPayments,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      developer.log('✅ [SuperAdminRemoteDataSource] Pending Payments Response: $response', name: 'SuperAdminRemoteDataSource');
      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] getPendingPayments() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> approvePayment(String paymentId) async {
    final url = ApiEndpoints.approvePayment(paymentId);
    developer.log('👑 [SuperAdminRemoteDataSource] Calling PATCH $url...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.patch(url);
      developer.log('✅ [SuperAdminRemoteDataSource] Payment $paymentId approved! Response: $response', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] approvePayment() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> rejectPayment(String paymentId, {String? reason}) async {
    final url = ApiEndpoints.rejectPayment(paymentId);
    developer.log('👑 [SuperAdminRemoteDataSource] Calling PATCH $url with reason="$reason"...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.patch(
        url,
        body: {
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      );
      developer.log('✅ [SuperAdminRemoteDataSource] Payment $paymentId rejected! Response: $response', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] rejectPayment() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ShopItemModel>> getShopsList({int page = 1, int limit = 20, String? search}) async {
    developer.log('👑 [SuperAdminRemoteDataSource] Calling GET ${ApiEndpoints.adminShops}...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.adminShops,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      developer.log('✅ [SuperAdminRemoteDataSource] Shops Response: $response', name: 'SuperAdminRemoteDataSource');
      final List list = response is List ? response : (response['data'] ?? response['shops'] ?? []);
      return list.map((json) => ShopItemModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('⚠️ [SuperAdminRemoteDataSource] getShopsList() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<ShopDetailModel> getShopDetails(String id) async {
    final url = ApiEndpoints.adminShopById(id);
    developer.log('👑 [SuperAdminRemoteDataSource] Calling GET $url...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.get(url);
      developer.log('✅ [SuperAdminRemoteDataSource] Shop Details Response: $response', name: 'SuperAdminRemoteDataSource');
      return ShopDetailModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] getShopDetails() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteShop(String shopId) async {
    final url = ApiEndpoints.adminShopById(shopId);
    developer.log('👑 [SuperAdminRemoteDataSource] Calling DELETE $url...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.delete(url);
      developer.log('✅ [SuperAdminRemoteDataSource] Shop $shopId deleted! Response: $response', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('⚠️ [SuperAdminRemoteDataSource] deleteShop() API call error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
