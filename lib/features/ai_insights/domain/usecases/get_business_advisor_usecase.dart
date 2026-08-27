import '../entities/business_advisor_entity.dart';
import '../repositories/ai_insights_repository.dart';

/// UseCase: Fetches AI small business growth advisor, health grade & tips.
class GetBusinessAdvisorUseCase {
  final AiInsightsRepository repository;

  const GetBusinessAdvisorUseCase(this.repository);

  Future<BusinessAdvisorEntity> call({bool forceGemini = false}) {
    return repository.getBusinessAdvisor(forceGemini: forceGemini);
  }
}
