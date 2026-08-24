import '../entities/demand_forecast_entity.dart';
import '../repositories/ai_insights_repository.dart';

/// UseCase: Fetches AI product demand forecasting & slow moving risk.
class GetPredictDemandUseCase {
  final AiInsightsRepository repository;

  const GetPredictDemandUseCase(this.repository);

  Future<DemandForecastEntity> call() {
    return repository.getPredictDemand();
  }
}
