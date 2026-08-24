/// Domain Entity for AI Business Advisor & Growth Tips.
class BusinessAdvisorEntity {
  final bool isAiPowered;
  final String modelUsed;
  final String healthGrade;
  final List<String> growthOpportunities;
  final List<String> actionableTips;

  const BusinessAdvisorEntity({
    required this.isAiPowered,
    required this.modelUsed,
    required this.healthGrade,
    required this.growthOpportunities,
    required this.actionableTips,
  });
}
