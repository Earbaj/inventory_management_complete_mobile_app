import 'dart:developer' as developer;
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<PaymentModel> submitPayment({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  });

  Future<List<PaymentModel>> getPaymentLogs();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaymentModel> submitPayment({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  }) async {
    developer.log('💳 [SubscriptionRemoteDataSource] Calling POST /api/subscription/pay with method="$method", transactionId="$transactionId", amount=$amount, targetTier="$targetTier"', name: 'SubscriptionRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/subscription/pay',
        body: {
          'method': method,
          'transactionId': transactionId,
          'amount': amount,
          'targetTier': targetTier,
        },
      );

      developer.log('✅ [SubscriptionRemoteDataSource] Raw Response JSON: $response', name: 'SubscriptionRemoteDataSource');
      return PaymentModel.fromJson(response is Map<String, dynamic> ? response : {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'shopId': '1',
        'method': method,
        'transactionId': transactionId,
        'amount': amount,
        'targetTier': targetTier,
        'status': 'pending',
      });
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRemoteDataSource] submitPayment() Error Response: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentLogs() async {
    developer.log('💳 [SubscriptionRemoteDataSource] Calling GET /api/subscription/payments...', name: 'SubscriptionRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/subscription/payments',
      );

      developer.log('✅ [SubscriptionRemoteDataSource] Raw Response JSON: $response', name: 'SubscriptionRemoteDataSource');
      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRemoteDataSource] getPaymentLogs() Error Response: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
