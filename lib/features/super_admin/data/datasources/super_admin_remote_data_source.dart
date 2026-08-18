import 'dart:developer' as developer;
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_client.dart';
import '../../subscription/data/models/payment_model.dart';

abstract class SuperAdminRemoteDataSource {
  Future<List<PaymentModel>> getPendingPayments();
  Future<void> approvePayment(String paymentId);
  Future<void> rejectPayment(String paymentId);
}

class SuperAdminRemoteDataSourceImpl implements SuperAdminRemoteDataSource {
  final ApiClient apiClient;

  SuperAdminRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PaymentModel>> getPendingPayments() async {
    developer.log('👑 [SuperAdminRemoteDataSource] getPendingPayments() called...', name: 'SuperAdminRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/admin/payments',
      );

      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      developer.log('✅ [SuperAdminRemoteDataSource] getPendingPayments() success (${list.length} payments).', name: 'SuperAdminRemoteDataSource');
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] getPendingPayments() API Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> approvePayment(String paymentId) async {
    developer.log('👑 [SuperAdminRemoteDataSource] approvePayment() for ID: $paymentId', name: 'SuperAdminRemoteDataSource');
    try {
      await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/admin/payments/$paymentId/approve',
      );
      developer.log('✅ [SuperAdminRemoteDataSource] Payment $paymentId approved!', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] approvePayment() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> rejectPayment(String paymentId) async {
    developer.log('👑 [SuperAdminRemoteDataSource] rejectPayment() for ID: $paymentId', name: 'SuperAdminRemoteDataSource');
    try {
      await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/admin/payments/$paymentId/reject',
      );
      developer.log('✅ [SuperAdminRemoteDataSource] Payment $paymentId rejected!', name: 'SuperAdminRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [SuperAdminRemoteDataSource] rejectPayment() Error: $e', name: 'SuperAdminRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
