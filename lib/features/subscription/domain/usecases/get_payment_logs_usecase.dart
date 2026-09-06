import '../entities/payment_entity.dart';
import '../repositories/subscription_repository.dart';

class GetPaymentLogsUseCase {
  final SubscriptionRepository repository;

  const GetPaymentLogsUseCase(this.repository);

  Future<List<PaymentEntity>> call() {
    return repository.getPaymentLogs();
  }
}
