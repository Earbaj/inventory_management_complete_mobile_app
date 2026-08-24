import 'package:equatable/equatable.dart';
import '../../domain/entities/business_advisor_entity.dart';
import '../../domain/entities/customer_credit_score_entity.dart';
import '../../domain/entities/demand_forecast_entity.dart';

abstract class AiInsightsState extends Equatable {
  const AiInsightsState();

  @override
  List<Object?> get props => [];
}

class AiInsightsInitialState extends AiInsightsState {
  const AiInsightsInitialState();
}

class AiInsightsLoadingState extends AiInsightsState {
  const AiInsightsLoadingState();
}

class AiInsightsLoadedState extends AiInsightsState {
  final DemandForecastEntity? demandForecast;
  final BusinessAdvisorEntity? businessAdvisor;
  final CustomerCreditScoreEntity? customerCreditScore;
  final bool isCustomerScoreLoading;

  const AiInsightsLoadedState({
    this.demandForecast,
    this.businessAdvisor,
    this.customerCreditScore,
    this.isCustomerScoreLoading = false,
  });

  AiInsightsLoadedState copyWith({
    DemandForecastEntity? demandForecast,
    BusinessAdvisorEntity? businessAdvisor,
    CustomerCreditScoreEntity? customerCreditScore,
    bool? isCustomerScoreLoading,
  }) {
    return AiInsightsLoadedState(
      demandForecast: demandForecast ?? this.demandForecast,
      businessAdvisor: businessAdvisor ?? this.businessAdvisor,
      customerCreditScore: customerCreditScore ?? this.customerCreditScore,
      isCustomerScoreLoading: isCustomerScoreLoading ?? this.isCustomerScoreLoading,
    );
  }

  @override
  List<Object?> get props => [
        demandForecast,
        businessAdvisor,
        customerCreditScore,
        isCustomerScoreLoading,
      ];
}

class AiInsightsErrorState extends AiInsightsState {
  final String message;

  const AiInsightsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
