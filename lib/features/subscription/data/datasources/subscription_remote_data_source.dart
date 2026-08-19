import 'dart:developer' as developer;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';
import '../models/subscription_package_model.dart';
import '../models/payment_info_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPackageModel>> getPackages();
  Future<PaymentInfoModel> getPaymentInfo();
  Future<PaymentModel> submitPayment({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  });
  Future<List<PaymentModel>> getPaymentLogs({int page = 1, int limit = 20});
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<SubscriptionPackageModel>> getPackages() async {
    developer.log('💳 [SubscriptionRemoteDataSource] Calling GET ${ApiEndpoints.subscriptionPackages}...', name: 'SubscriptionRemoteDataSource');
    try {
      final response = await apiClient.get(ApiEndpoints.subscriptionPackages);
      developer.log('✅ [SubscriptionRemoteDataSource] Packages Response: $response', name: 'SubscriptionRemoteDataSource');
      final List list = response is List ? response : (response['packages'] ?? response['data'] ?? []);
      if (list.isEmpty) {
        return const [
          SubscriptionPackageModel(
            id: 'free',
            name: 'Free Starter Tier',
            tier: 'free',
            price: 0.0,
            maxCustomers: 50,
            maxSales: 100,
            features: ['Up to 50 Customers', 'Up to 100 Sales Invoices', 'Basic Reports'],
          ),
          SubscriptionPackageModel(
            id: 'premium',
            name: 'Pro Premium Tier',
            tier: 'premium',
            price: 999.0,
            maxCustomers: -1,
            maxSales: -1,
            features: ['Unlimited Customers', 'Unlimited POS Invoices', 'Advanced Analytics', 'CSV/PDF Export', 'Priority Support'],
          ),
        ];
      }
      return list.map((json) => SubscriptionPackageModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('⚠️ [SubscriptionRemoteDataSource] getPackages() fallback: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      return const [
        SubscriptionPackageModel(
          id: 'free',
          name: 'Free Starter Tier',
          tier: 'free',
          price: 0.0,
          maxCustomers: 50,
          maxSales: 100,
          features: ['Up to 50 Customers', 'Up to 100 Sales Invoices', 'Basic Reports'],
        ),
        SubscriptionPackageModel(
          id: 'premium',
          name: 'Pro Premium Tier',
          tier: 'premium',
          price: 999.0,
          maxCustomers: -1,
          maxSales: -1,
          features: ['Unlimited Customers', 'Unlimited POS Invoices', 'Advanced Analytics', 'CSV/PDF Export', 'Priority Support'],
        ),
      ];
    }
  }

  @override
  Future<PaymentInfoModel> getPaymentInfo() async {
    developer.log('💳 [SubscriptionRemoteDataSource] Calling GET ${ApiEndpoints.paymentInfo}...', name: 'SubscriptionRemoteDataSource');
    try {
      final response = await apiClient.get(ApiEndpoints.paymentInfo);
      developer.log('✅ [SubscriptionRemoteDataSource] Payment Info Response: $response', name: 'SubscriptionRemoteDataSource');
      return PaymentInfoModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('⚠️ [SubscriptionRemoteDataSource] getPaymentInfo() fallback: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      return const PaymentInfoModel(
        bkashNumber: '01700000000 (Merchant)',
        nagadNumber: '01800000000 (Merchant)',
        rocketNumber: '01900000000 (Personal)',
        bankAccount: 'City Bank - A/C 123456789',
        instructions: 'Send money to our merchant number and submit TrxID below.',
      );
    }
  }

  @override
  Future<PaymentModel> submitPayment({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  }) async {
    developer.log('💳 [SubscriptionRemoteDataSource] Calling POST ${ApiEndpoints.submitManualPayment} with method="$method", trxId="$transactionId", amount=$amount', name: 'SubscriptionRemoteDataSource');
    try {
      dynamic response;
      final payload = {
        'method': method,
        'paymentMethod': method,
        'transactionId': transactionId,
        'trxId': transactionId,
        'amount': amount,
        'targetTier': targetTier,
        'packageId': targetTier,
      };

      try {
        response = await apiClient.post(
          ApiEndpoints.submitManualPayment,
          body: payload,
        );
      } catch (_) {
        response = await apiClient.post(
          '${ApiEndpoints.baseUrl}/api/subscription/pay',
          body: payload,
        );
      }

      developer.log('✅ [SubscriptionRemoteDataSource] Submit Payment Raw Response: $response', name: 'SubscriptionRemoteDataSource');
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
      developer.log('❌ [SubscriptionRemoteDataSource] submitPayment() Error: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentLogs({int page = 1, int limit = 20}) async {
    developer.log('💳 [SubscriptionRemoteDataSource] Calling GET ${ApiEndpoints.myPayments} (page: $page, limit: $limit)...', name: 'SubscriptionRemoteDataSource');
    try {
      dynamic response;
      try {
        response = await apiClient.get(
          ApiEndpoints.myPayments,
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );
      } catch (_) {
        response = await apiClient.get('${ApiEndpoints.baseUrl}/api/subscription/payments');
      }

      developer.log('✅ [SubscriptionRemoteDataSource] Payment History Response: $response', name: 'SubscriptionRemoteDataSource');
      final List list = response is List ? response : (response['payments'] ?? response['data'] ?? []);
      return list.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [SubscriptionRemoteDataSource] getPaymentLogs() Error: $e', name: 'SubscriptionRemoteDataSource', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
