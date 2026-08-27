import '../entities/business_advisor_entity.dart';
import '../entities/customer_credit_score_entity.dart';
import '../entities/demand_forecast_entity.dart';

/// Abstract Repository Contract for AI Predictions & Intelligence.
abstract class AiInsightsRepository {
  /// Fetches AI-driven product demand forecast (GET /api/ai/predict-demand).
  Future<DemandForecastEntity> getPredictDemand();

  /// Fetches AI customer credit reliability rating (GET /api/ai/customer-credit-score/:customerId).
  Future<CustomerCreditScoreEntity> getCustomerCreditScore(String customerId);

  /// Fetches AI business growth advisor tips (GET /api/ai/business-advisor).
  Future<BusinessAdvisorEntity> getBusinessAdvisor();
}
