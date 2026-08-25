import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/business_advisor_model.dart';
import '../models/customer_credit_score_model.dart';
import '../models/demand_forecast_model.dart';

abstract class AiInsightsRemoteDataSource {
  Future<DemandForecastModel> getPredictDemand();
  Future<CustomerCreditScoreModel> getCustomerCreditScore(String customerId);
  Future<BusinessAdvisorModel> getBusinessAdvisor();
}

class AiInsightsRemoteDataSourceImpl implements AiInsightsRemoteDataSource {
  final ApiClient apiClient;

  AiInsightsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DemandForecastModel> getPredictDemand() async {
    developer.log(
      '🤖 [AiInsightsRemoteDataSource] getPredictDemand() requesting ${ApiEndpoints.aiPredictDemand}',
      name: 'AiInsightsRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.aiPredictDemand,
        cache: true,
        maxStale: const Duration(minutes: 10),
      );

      developer.log(
        '✅ [AiInsightsRemoteDataSource] getPredictDemand() success. Response: $response',
        name: 'AiInsightsRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : {};
      return DemandForecastModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [AiInsightsRemoteDataSource] getPredictDemand() API Error: $e',
        name: 'AiInsightsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<CustomerCreditScoreModel> getCustomerCreditScore(String customerId) async {
    final endpoint = ApiEndpoints.aiCustomerCreditScore(customerId);
    developer.log(
      '🤖 [AiInsightsRemoteDataSource] getCustomerCreditScore() customerId: "$customerId", endpoint: "$endpoint"',
      name: 'AiInsightsRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        endpoint,
        cache: true,
        maxStale: const Duration(minutes: 10),
      );

      developer.log(
        '✅ [AiInsightsRemoteDataSource] getCustomerCreditScore() success for customerId: "$customerId"',
        name: 'AiInsightsRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : {};
      return CustomerCreditScoreModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [AiInsightsRemoteDataSource] getCustomerCreditScore() API Error for customerId "$customerId": $e',
        name: 'AiInsightsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<BusinessAdvisorModel> getBusinessAdvisor() async {
    developer.log(
      '🤖 [AiInsightsRemoteDataSource] getBusinessAdvisor() requesting ${ApiEndpoints.aiBusinessAdvisor}',
      name: 'AiInsightsRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.aiBusinessAdvisor,
        cache: true,
        maxStale: const Duration(minutes: 15),
      );

      developer.log(
        '✅ [AiInsightsRemoteDataSource] getBusinessAdvisor() success. Response: $response',
        name: 'AiInsightsRemoteDataSource',
      );

      final Map<String, dynamic> jsonResponse = response is Map<String, dynamic>
          ? response
          : {};
      return BusinessAdvisorModel.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      developer.log(
        '❌ [AiInsightsRemoteDataSource] getBusinessAdvisor() API Error: $e',
        name: 'AiInsightsRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
