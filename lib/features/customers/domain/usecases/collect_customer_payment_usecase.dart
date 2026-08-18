import '../repositories/customer_repository.dart';

/// UseCase to process payment against customer due balance (POST /api/payments).
class CollectCustomerPaymentUseCase {
  final CustomerRepository repository;

  CollectCustomerPaymentUseCase(this.repository);

  Future<void> call({
    required String customerId,
    required double amount,
    String paymentMethod = 'cash',
    String? note,
  }) async {
    return repository.collectCustomerPayment(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      note: note,
    );
  }
}
