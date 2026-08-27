import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_business_advisor_usecase.dart';
import '../../domain/usecases/get_customer_credit_score_usecase.dart';
import '../../domain/usecases/get_predict_demand_usecase.dart';
import 'ai_insights_event.dart';
import 'ai_insights_state.dart';

class AiInsightsBloc extends Bloc<AiInsightsEvent, AiInsightsState> {
  final GetPredictDemandUseCase getPredictDemandUseCase;
  final GetCustomerCreditScoreUseCase getCustomerCreditScoreUseCase;
  final GetBusinessAdvisorUseCase getBusinessAdvisorUseCase;

  AiInsightsBloc({
    required this.getPredictDemandUseCase,
    required this.getCustomerCreditScoreUseCase,
    required this.getBusinessAdvisorUseCase,
  }) : super(const AiInsightsInitialState()) {
    on<FetchPredictDemandEvent>(_onFetchPredictDemand);
    on<FetchCustomerCreditScoreEvent>(_onFetchCustomerCreditScore);
    on<FetchBusinessAdvisorEvent>(_onFetchBusinessAdvisor);
    on<FetchAllAiInsightsEvent>(_onFetchAllAiInsights);
  }

  Future<void> _onFetchPredictDemand(
    FetchPredictDemandEvent event,
    Emitter<AiInsightsState> emit,
  ) async {
    final currentState = state is AiInsightsLoadedState
        ? (state as AiInsightsLoadedState)
        : const AiInsightsLoadedState();

    try {
      final forecast = await getPredictDemandUseCase();
      emit(currentState.copyWith(demandForecast: forecast));
    } catch (e) {
      if (state is! AiInsightsLoadedState) {
        emit(AiInsightsErrorState(e.toString()));
      }
    }
  }

  Future<void> _onFetchCustomerCreditScore(
    FetchCustomerCreditScoreEvent event,
    Emitter<AiInsightsState> emit,
  ) async {
    final currentState = state is AiInsightsLoadedState
        ? (state as AiInsightsLoadedState)
        : const AiInsightsLoadedState();

    emit(currentState.copyWith(isCustomerScoreLoading: true));

    try {
      final creditScore = await getCustomerCreditScoreUseCase(
        event.customerId,
        forceGemini: event.forceGemini,
      );
      emit(currentState.copyWith(
        customerCreditScore: creditScore,
        isCustomerScoreLoading: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isCustomerScoreLoading: false));
      emit(AiInsightsErrorState('Failed to fetch AI credit score: $e'));
    }
  }

  Future<void> _onFetchBusinessAdvisor(
    FetchBusinessAdvisorEvent event,
    Emitter<AiInsightsState> emit,
  ) async {
    final currentState = state is AiInsightsLoadedState
        ? (state as AiInsightsLoadedState)
        : const AiInsightsLoadedState();

    try {
      final advisor = await getBusinessAdvisorUseCase();
      emit(currentState.copyWith(businessAdvisor: advisor));
    } catch (e) {
      if (state is! AiInsightsLoadedState) {
        emit(AiInsightsErrorState(e.toString()));
      }
    }
  }

  Future<void> _onFetchAllAiInsights(
    FetchAllAiInsightsEvent event,
    Emitter<AiInsightsState> emit,
  ) async {
    emit(const AiInsightsLoadingState());

    try {
      final forecastFuture = getPredictDemandUseCase(forceGemini: event.forceGemini);
      final advisorFuture = getBusinessAdvisorUseCase(forceGemini: event.forceGemini);

      final results = await Future.wait([forecastFuture, advisorFuture]);

      emit(AiInsightsLoadedState(
        demandForecast: results[0] as dynamic,
        businessAdvisor: results[1] as dynamic,
      ));
    } catch (e) {
      emit(AiInsightsErrorState(e.toString()));
    }
  }
}
