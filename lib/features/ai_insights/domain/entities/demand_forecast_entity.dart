/// Domain Entity for Trending Product Prediction.
class TrendingProductEntity {
  final String name;
  final String reason;
  final String forecastedDemand;

  const TrendingProductEntity({
    required this.name,
    required this.reason,
    required this.forecastedDemand,
  });
}

/// Domain Entity for Slow Moving Product Risk.
class SlowMovingProductEntity {
  final String name;
  final String reason;
  final String riskLevel;

  const SlowMovingProductEntity({
    required this.name,
    required this.reason,
    required this.riskLevel,
  });
}

/// Domain Entity for AI Product Demand Forecasting.
class DemandForecastEntity {
  final bool isAiPowered;
  final String modelUsed;
  final List<TrendingProductEntity> topTrendingProducts;
  final List<SlowMovingProductEntity> slowMovingRiskProducts;
  final String aiReorderAdvice;

  const DemandForecastEntity({
    required this.isAiPowered,
    required this.modelUsed,
    required this.topTrendingProducts,
    required this.slowMovingRiskProducts,
    required this.aiReorderAdvice,
  });
}
