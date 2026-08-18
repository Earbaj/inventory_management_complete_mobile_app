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
    developer.log('💳 [SubscriptionRemoteDataSource] submitPayment() method: $method, trxId: $transactionId, amount: $amount', name: 'SubscriptionRemoteDataSource');
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

      developer.log('✅ [SubscriptionRemoteDataSource] submitPayment() success.', name: 'SubscriptionRemoteDataSource');
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
      developer.log('❌ [SubscriptionRemoteDataSource] submitPayment() API Error: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentLogs() async {
    developer.log('💳 [SubscriptionRemoteDataSource] getPaymentLogs() called...', name: 'SubscriptionRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/subscription/payments',
      );

      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      developer.log('✅ [SubscriptionRemoteDataSource] getPaymentLogs() success (${list.length} payments).', name: 'SubscriptionRemoteDataSource');
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRemoteDataSource] getPaymentLogs() API Error: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
