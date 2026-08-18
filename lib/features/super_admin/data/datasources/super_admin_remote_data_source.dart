import 'dart:developer' as developer;
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../subscription/data/models/payment_model.dart';

abstract class SuperAdminRemoteDataSource {
  Future<List<PaymentModel>> getPendingPayments({int page = 1, int limit = 20});
  Future<void> approvePayment(String paymentId);
  Future<void> rejectPayment(String paymentId);
}

class SuperAdminRemoteDataSourceImpl implements SuperAdminRemoteDataSource {
  final ApiClient apiClient;

  SuperAdminRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PaymentModel>> getPendingPayments({int page = 1, int limit = 20}) async {
    developer.log('👑 [SuperAdminRemoteDataSource] Calling GET /api/admin/payments (page: $page, limit: $limit)...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/admin/payments',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      developer.log('✅ [SuperAdminRemoteDataSource] Raw Response JSON: $response', name: 'SuperAdminRemoteDataSource');
      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] getPendingPayments() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> approvePayment(String paymentId) async {
    developer.log('👑 [SuperAdminRemoteDataSource] Calling POST /api/admin/payments/$paymentId/approve...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/admin/payments/$paymentId/approve',
      );
      developer.log('✅ [SuperAdminRemoteDataSource] Payment $paymentId approved! Response: $response', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] approvePayment() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> rejectPayment(String paymentId) async {
    developer.log('👑 [SuperAdminRemoteDataSource] Calling POST /api/admin/payments/$paymentId/reject...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/admin/payments/$paymentId/reject',
      );
      developer.log('✅ [SuperAdminRemoteDataSource] Payment $paymentId rejected! Response: $response', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] rejectPayment() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
