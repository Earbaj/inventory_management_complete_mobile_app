import 'package:flutter/material.dart';
import '../../domain/entities/business_advisor_entity.dart';

class BusinessAdvisorCard extends StatelessWidget {
  final BusinessAdvisorEntity advisor;

  const BusinessAdvisorCard({
    super.key,
    required this.advisor,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Health Grade Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.purple, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      advisor.isAiPowered ? 'AI Business Advisor' : 'Business Advisor Insights',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Health Grade ${advisor.healthGrade}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Growth Opportunities
            if (advisor.growthOpportunities.isNotEmpty) ...[
              const Text(
                '🚀 Growth Opportunities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.purple),
              ),
              const SizedBox(height: 8),
              ...advisor.growthOpportunities.map((opp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.purple, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opp,
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 14),

            // Actionable Profit Tips
            if (advisor.actionableTips.isNotEmpty) ...[
              const Text(
                '💡 Actionable Profit Tips',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              ...advisor.actionableTips.map((tip) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates_outlined, color: Colors.teal, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
