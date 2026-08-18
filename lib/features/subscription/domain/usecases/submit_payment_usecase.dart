import '../entities/payment_entity.dart';
import '../repositories/subscription_repository.dart';

class SubmitPaymentUseCase {
  final SubscriptionRepository repository;

  const SubmitPaymentUseCase(this.repository);

  Future<PaymentEntity> call({
    required String method,
    required String transactionId,
    required double amount,
    required String targetTier,
  }) {
    return repository.submitPayment(
      method: method,
      transactionId: transactionId,
      amount: amount,
      targetTier: targetTier,
    );
  }
}
