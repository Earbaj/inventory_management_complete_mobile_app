import 'package:inventory_management_complete/features/subscription/domain/entities/payment_entity.dart';

abstract class SubscriptionRepository {
  /// Submits subscription payment details (POST /api/subscription/pay).
  Future<PaymentEntity> submitPayment({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  });

  /// Fetches payment history logs for shop.
  Future<List<PaymentEntity>> getPaymentLogs();
}
