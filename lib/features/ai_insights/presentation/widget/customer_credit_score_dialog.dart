import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../domain/entities/customer_credit_score_entity.dart';

class CustomerCreditScoreDialog extends StatelessWidget {
  final CustomerCreditScoreEntity creditScore;

  const CustomerCreditScoreDialog({
    super.key,
    required this.creditScore,
  });

  Color _getRiskColor(String risk) {
    return switch (risk.toUpperCase()) {
      'LOW_RISK' || 'LOW' => Colors.green,
      'MEDIUM_RISK' || 'MEDIUM' => Colors.orange,
      _ => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final riskColor = _getRiskColor(creditScore.creditRiskLevel);
    final score = creditScore.reliabilityScore;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge & Model Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.purple, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'AI Assessment (${creditScore.modelUsed})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Customer Name
              Text(
                creditScore.customerName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'AI Reliability & Credit Score',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              // Gauge Circular Score Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100.0,
                      strokeWidth: 12,
                      backgroundColor: riskColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: riskColor,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Risk Level & Max Recommended Due Limit Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text('Credit Risk Level', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            creditScore.creditRiskLevel.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: riskColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text('Recommended Due Limit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '${MoneyUtil.currencySymbol} ${creditScore.maxRecommendedDueLimit.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // AI Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology_outlined, color: Colors.purple, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        creditScore.aiSummary,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close Assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
