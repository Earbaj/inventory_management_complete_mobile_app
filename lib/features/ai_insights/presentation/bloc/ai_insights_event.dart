import 'package:equatable/equatable.dart';

abstract class AiInsightsEvent extends Equatable {
  const AiInsightsEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Fetch AI-driven product demand forecast.
class FetchPredictDemandEvent extends AiInsightsEvent {
  const FetchPredictDemandEvent();
}

/// Event: Fetch AI credit reliability rating for a specific customer.
class FetchCustomerCreditScoreEvent extends AiInsightsEvent {
  final String customerId;

  const FetchCustomerCreditScoreEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Event: Fetch AI business advisor insights & actionable profit tips.
class FetchBusinessAdvisorEvent extends AiInsightsEvent {
  const FetchBusinessAdvisorEvent();
}

/// Event: Fetch all AI Insights together (demand forecast + business advisor).
class FetchAllAiInsightsEvent extends AiInsightsEvent {
  const FetchAllAiInsightsEvent();
}
