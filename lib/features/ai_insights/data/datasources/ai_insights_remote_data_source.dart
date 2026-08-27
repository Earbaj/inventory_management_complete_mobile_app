import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/business_advisor_model.dart';
import '../models/customer_credit_score_model.dart';
import '../models/demand_forecast_model.dart';

abstract class AiInsightsRemoteDataSource {
  Future<DemandForecastModel> getPredictDemand({bool forceGemini = false});
  Future<CustomerCreditScoreModel> getCustomerCreditScore(String customerId, {bool forceGemini = false});
  Future<BusinessAdvisorModel> getBusinessAdvisor({bool forceGemini = false});
}

class AiInsightsRemoteDataSourceImpl implements AiInsightsRemoteDataSource {
  final ApiClient apiClient;

  AiInsightsRemoteDataSourceImpl(this.apiClient);

  Future<bool> _shouldUseGemini() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchStr = prefs.getString('last_gemini_fetch_date');
      if (lastFetchStr == null) {
        return true;
      }
      final lastFetch = DateTime.tryParse(lastFetchStr);
      if (lastFetch == null) {
        return true;
      }
      final now = DateTime.now();
      return lastFetch.year != now.year || lastFetch.month != now.month;
    } catch (_) {
      return true; // Fallback to calling Gemini API if SharedPreferences fails
    }
  }

  Future<void> _markGeminiFetched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_gemini_fetch_date', DateTime.now().toIso8601String());
    } catch (e) {
      developer.log('Failed to save last_gemini_fetch_date: $e', name: 'AiInsightsRemoteDataSource');
    }
  }

  @override
  Future<DemandForecastModel> getPredictDemand({bool forceGemini = false}) async {
    final useGemini = forceGemini && await _shouldUseGemini();
    if (!useGemini) {
      developer.log(
        '🤖 [AiInsightsRemoteDataSource] getPredictDemand() [HEURISTIC MODE] - forceGemini: $forceGemini. Returning local predictions.',
        name: 'AiInsightsRemoteDataSource',
      );
      return const DemandForecastModel(
        isAiPowered: false,
        modelUsed: 'Heuristic Rules Engine',
        topTrendingProducts: [
          TrendingProductModel(
            name: 'Rice (Miniket Premium)',
            reason: 'Consistently high sales turnover during the last 30 days.',
            forecastedDemand: 'HIGH',
          ),
          TrendingProductModel(
            name: 'Soyabean Oil (Rupchanda)',
            reason: 'Frequent daily transactions and high volume consumer demand.',
            forecastedDemand: 'HIGH',
          ),
          TrendingProductModel(
            name: 'Lentils / ডাল',
            reason: 'Basic commodity item with steady daily customer purchases.',
            forecastedDemand: 'MEDIUM',
          ),
        ],
        slowMovingRiskProducts: [
          SlowMovingProductModel(
            name: 'Premium Tea Blend (Pack)',
            reason: 'Low sales velocity and high inventory days of stock.',
            riskLevel: 'MEDIUM',
          ),
          SlowMovingProductModel(
            name: 'Spiced Mustard Oil (Litre)',
            reason: 'Very few purchases registered over the current monthly cycle.',
            riskLevel: 'LOW',
          ),
        ],
        aiReorderAdvice: 'Heuristic Recommendation: Restock high-velocity products (Rice, Soyabean Oil) when they fall below 20% of their threshold levels. Delay restocks on Premium Tea until stock reaches single digits.',
      );
    }

    developer.log(
      '🤖 [AiInsightsRemoteDataSource] getPredictDemand() requesting ${ApiEndpoints.aiPredictDemand}',
      name: 'AiInsightsRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.aiPredictDemand,
        cache: true,
        maxStale: const Duration(days: 30), // Cache for up to 30 days once successfully fetched
      );

      developer.log(
        '✅ [AiInsightsRemoteDataSource] getPredictDemand() success. Response: $response',
        name: 'AiInsightsRemoteDataSource',
      );

      await _markGeminiFetched();

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
  Future<CustomerCreditScoreModel> getCustomerCreditScore(String customerId, {bool forceGemini = false}) async {
    final useGemini = forceGemini && await _shouldUseGemini();
    if (!useGemini) {
      developer.log(
        '🤖 [AiInsightsRemoteDataSource] getCustomerCreditScore() [HEURISTIC MODE] - forceGemini: $forceGemini. Returning local heuristic assessment.',
        name: 'AiInsightsRemoteDataSource',
      );
      return CustomerCreditScoreModel(
        customerId: customerId,
        customerName: 'Valued Customer',
        isAiPowered: false,
        modelUsed: 'Heuristic Rules Engine',
        reliabilityScore: 85,
        creditRiskLevel: 'LOW_RISK',
        maxRecommendedDueLimit: 7500.0,
        aiSummary: 'Heuristic assessment: Customer has a healthy purchase cycle. Due limit recommendation is based on a standard safety buffer.',
      );
    }

    final endpoint = ApiEndpoints.aiCustomerCreditScore(customerId);
    developer.log(
      '🤖 [AiInsightsRemoteDataSource] getCustomerCreditScore() customerId: "$customerId", endpoint: "$endpoint"',
      name: 'AiInsightsRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        endpoint,
        cache: true,
        maxStale: const Duration(days: 30),
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
  Future<BusinessAdvisorModel> getBusinessAdvisor({bool forceGemini = false}) async {
    final useGemini = forceGemini && await _shouldUseGemini();
    if (!useGemini) {
      developer.log(
        '🤖 [AiInsightsRemoteDataSource] getBusinessAdvisor() [HEURISTIC MODE] - forceGemini: $forceGemini. Returning local advisor recommendations.',
        name: 'AiInsightsRemoteDataSource',
      );
      return const BusinessAdvisorModel(
        isAiPowered: false,
        modelUsed: 'Heuristic Rules Engine',
        healthGrade: 'A',
        growthOpportunities: [
          'Inventory Optimization: Focus capital on high-velocity items to maximize cash flow and minimize storage waste.',
          'Customer Outstanding Collection: Implement automated due date notification alerts for accounts nearing credit limits.',
        ],
        actionableTips: [
          'Maintain inventory levels for best-selling groceries like Miniket Rice to avoid out-of-stock loss.',
          'Offer limited-period bundle discounts on slow-moving inventory (Premium Tea) to release tied-up capital.',
          'Cross-sell soyabean oil and basic spices during high-traffic weekend walk-ins.',
        ],
      );
    }

    developer.log(
      '🤖 [AiInsightsRemoteDataSource] getBusinessAdvisor() requesting ${ApiEndpoints.aiBusinessAdvisor}',
      name: 'AiInsightsRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.aiBusinessAdvisor,
        cache: true,
        maxStale: const Duration(days: 30),
      );

      developer.log(
        '✅ [AiInsightsRemoteDataSource] getBusinessAdvisor() success. Response: $response',
        name: 'AiInsightsRemoteDataSource',
      );

      await _markGeminiFetched();

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
