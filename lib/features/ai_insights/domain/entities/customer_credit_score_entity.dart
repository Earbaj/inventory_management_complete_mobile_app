/// Domain Entity for AI Customer Credit Reliability Score.
class CustomerCreditScoreEntity {
  final String customerId;
  final String customerName;
  final bool isAiPowered;
  final String modelUsed;
  final int reliabilityScore;
  final String creditRiskLevel;
  final double maxRecommendedDueLimit;
  final String aiSummary;

  const CustomerCreditScoreEntity({
    required this.customerId,
    required this.customerName,
    required this.isAiPowered,
    required this.modelUsed,
    required this.reliabilityScore,
    required this.creditRiskLevel,
    required this.maxRecommendedDueLimit,
    required this.aiSummary,
  });
}
