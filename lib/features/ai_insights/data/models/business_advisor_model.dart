import '../../domain/entities/business_advisor_entity.dart';

class BusinessAdvisorModel {
  final bool isAiPowered;
  final String modelUsed;
  final String healthGrade;
  final List<String> growthOpportunities;
  final List<String> actionableTips;

  const BusinessAdvisorModel({
    required this.isAiPowered,
    required this.modelUsed,
    required this.healthGrade,
    required this.growthOpportunities,
    required this.actionableTips,
  });

  factory BusinessAdvisorModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> adviceMap = json['advice'] is Map<String, dynamic>
        ? json['advice'] as Map<String, dynamic>
        : json;

    final List rawOpp = adviceMap['growthOpportunities'] is List
        ? adviceMap['growthOpportunities']
        : (adviceMap['opportunities'] is List ? adviceMap['opportunities'] : []);
    final List rawTips = adviceMap['actionableTips'] is List
        ? adviceMap['actionableTips']
        : (adviceMap['tips'] is List ? adviceMap['tips'] : []);

    return BusinessAdvisorModel(
      isAiPowered: json['isAiPowered'] == true || json['is_ai_powered'] == true,
      modelUsed: json['modelUsed']?.toString() ?? json['model_used']?.toString() ?? 'gemini-2.5-flash',
      healthGrade: adviceMap['healthGrade']?.toString() ?? adviceMap['grade']?.toString() ?? 'A',
      growthOpportunities: rawOpp.map((e) => e.toString()).toList(),
      actionableTips: rawTips.map((e) => e.toString()).toList(),
    );
  }

  BusinessAdvisorEntity toEntity() {
    return BusinessAdvisorEntity(
      isAiPowered: isAiPowered,
      modelUsed: modelUsed,
      healthGrade: healthGrade,
      growthOpportunities: growthOpportunities,
      actionableTips: actionableTips,
    );
  }
}
