import '../entities/customer_credit_score_entity.dart';
import '../repositories/ai_insights_repository.dart';

/// UseCase: Fetches AI customer reliability rating & credit risk limit.
class GetCustomerCreditScoreUseCase {
  final AiInsightsRepository repository;

  const GetCustomerCreditScoreUseCase(this.repository);

  Future<CustomerCreditScoreEntity> call(String customerId) {
    return repository.getCustomerCreditScore(customerId);
  }
}
