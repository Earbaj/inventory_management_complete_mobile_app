import 'dart:developer' as developer;
import '../../../../core/network/api_endpoints.dart';
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
    developer.log('💳 [SubscriptionRemoteDataSource] Calling POST ${ApiEndpoints.submitManualPayment} with method="$method", transactionId="$transactionId", amount=$amount, targetTier="$targetTier"', name: 'SubscriptionRemoteDataSource');
    try {
      dynamic response;
      try {
        response = await apiClient.post(
          ApiEndpoints.submitManualPayment,
          body: {
            'method': method,
            'transactionId': transactionId,
            'amount': amount,
            'targetTier': targetTier,
          },
        );
      } catch (_) {
        response = await apiClient.post(
          '${ApiEndpoints.baseUrl}/api/subscription/pay',
          body: {
            'method': method,
            'transactionId': transactionId,
            'amount': amount,
            'targetTier': targetTier,
          },
        );
      }

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
    developer.log('💳 [SubscriptionRemoteDataSource] Calling GET ${ApiEndpoints.myPayments}...', name: 'SubscriptionRemoteDataSource');
    try {
      dynamic response;
      try {
        response = await apiClient.get(ApiEndpoints.myPayments);
      } catch (_) {
        response = await apiClient.get('${ApiEndpoints.baseUrl}/api/subscription/payments');
      }

      developer.log('✅ [SubscriptionRemoteDataSource] Raw Response JSON: $response', name: 'SubscriptionRemoteDataSource');
      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRemoteDataSource] getPaymentLogs() Error Response: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
