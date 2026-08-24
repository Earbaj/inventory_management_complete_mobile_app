import '../../domain/entities/customer_credit_score_entity.dart';

class CustomerCreditScoreModel {
  final String customerId;
  final String customerName;
  final bool isAiPowered;
  final String modelUsed;
  final int reliabilityScore;
  final String creditRiskLevel;
  final double maxRecommendedDueLimit;
  final String aiSummary;

  const CustomerCreditScoreModel({
    required this.customerId,
    required this.customerName,
    required this.isAiPowered,
    required this.modelUsed,
    required this.reliabilityScore,
    required this.creditRiskLevel,
    required this.maxRecommendedDueLimit,
    required this.aiSummary,
  });

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  factory CustomerCreditScoreModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> assessmentMap = json['assessment'] is Map<String, dynamic>
        ? json['assessment'] as Map<String, dynamic>
        : json;

    return CustomerCreditScoreModel(
      customerId: json['customerId']?.toString() ?? json['customer_id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['customer_name']?.toString() ?? 'Customer',
      isAiPowered: json['isAiPowered'] == true || json['is_ai_powered'] == true,
      modelUsed: json['modelUsed']?.toString() ?? json['model_used']?.toString() ?? 'gemini-2.5-flash',
      reliabilityScore: _parseInt(assessmentMap['reliabilityScore'] ?? assessmentMap['score'] ?? 80),
      creditRiskLevel: assessmentMap['creditRiskLevel']?.toString() ?? assessmentMap['riskLevel']?.toString() ?? 'LOW_RISK',
      maxRecommendedDueLimit: _parseDouble(assessmentMap['maxRecommendedDueLimit'] ?? assessmentMap['maxDueLimit'] ?? 5000),
      aiSummary: assessmentMap['aiSummary']?.toString() ?? assessmentMap['summary']?.toString() ?? '',
    );
  }

  CustomerCreditScoreEntity toEntity() {
    return CustomerCreditScoreEntity(
      customerId: customerId,
      customerName: customerName,
      isAiPowered: isAiPowered,
      modelUsed: modelUsed,
      reliabilityScore: reliabilityScore,
      creditRiskLevel: creditRiskLevel,
      maxRecommendedDueLimit: maxRecommendedDueLimit,
      aiSummary: aiSummary,
    );
  }
}
