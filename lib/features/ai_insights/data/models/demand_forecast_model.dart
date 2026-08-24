import '../../domain/entities/demand_forecast_entity.dart';

class TrendingProductModel {
  final String name;
  final String reason;
  final String forecastedDemand;

  const TrendingProductModel({
    required this.name,
    required this.reason,
    required this.forecastedDemand,
  });

  factory TrendingProductModel.fromJson(Map<String, dynamic> json) {
    return TrendingProductModel(
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      forecastedDemand: json['forecastedDemand']?.toString() ?? json['demand']?.toString() ?? 'HIGH',
    );
  }

  TrendingProductEntity toEntity() => TrendingProductEntity(
        name: name,
        reason: reason,
        forecastedDemand: forecastedDemand,
      );
}

class SlowMovingProductModel {
  final String name;
  final String reason;
  final String riskLevel;

  const SlowMovingProductModel({
    required this.name,
    required this.reason,
    required this.riskLevel,
  });

  factory SlowMovingProductModel.fromJson(Map<String, dynamic> json) {
    return SlowMovingProductModel(
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      riskLevel: json['riskLevel']?.toString() ?? json['risk_level']?.toString() ?? 'HIGH',
    );
  }

  SlowMovingProductEntity toEntity() => SlowMovingProductEntity(
        name: name,
        reason: reason,
        riskLevel: riskLevel,
      );
}

class DemandForecastModel {
  final bool isAiPowered;
  final String modelUsed;
  final List<TrendingProductModel> topTrendingProducts;
  final List<SlowMovingProductModel> slowMovingRiskProducts;
  final String aiReorderAdvice;

  const DemandForecastModel({
    required this.isAiPowered,
    required this.modelUsed,
    required this.topTrendingProducts,
    required this.slowMovingRiskProducts,
    required this.aiReorderAdvice,
  });

  factory DemandForecastModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> forecastMap = json['forecast'] is Map<String, dynamic>
        ? json['forecast'] as Map<String, dynamic>
        : json;

    final List rawTrending = forecastMap['topTrendingProducts'] is List
        ? forecastMap['topTrendingProducts']
        : [];
    final List rawSlow = forecastMap['slowMovingRiskProducts'] is List
        ? forecastMap['slowMovingRiskProducts']
        : [];

    return DemandForecastModel(
      isAiPowered: json['isAiPowered'] == true || json['is_ai_powered'] == true,
      modelUsed: json['modelUsed']?.toString() ?? json['model_used']?.toString() ?? 'gemini-2.5-flash',
      topTrendingProducts: rawTrending.map((e) => TrendingProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      slowMovingRiskProducts: rawSlow.map((e) => SlowMovingProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      aiReorderAdvice: forecastMap['aiReorderAdvice']?.toString() ?? forecastMap['reorderAdvice']?.toString() ?? '',
    );
  }

  DemandForecastEntity toEntity() {
    return DemandForecastEntity(
      isAiPowered: isAiPowered,
      modelUsed: modelUsed,
      topTrendingProducts: topTrendingProducts.map((e) => e.toEntity()).toList(),
      slowMovingRiskProducts: slowMovingRiskProducts.map((e) => e.toEntity()).toList(),
      aiReorderAdvice: aiReorderAdvice,
    );
  }
}
