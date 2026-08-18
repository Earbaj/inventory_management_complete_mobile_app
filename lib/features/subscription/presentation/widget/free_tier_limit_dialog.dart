import 'package:flutter/material.dart';
import 'payment_checkout_modal.dart';

class FreeTierLimitDialog extends StatelessWidget {
  final String limitTitle;
  final String limitMessage;

  const FreeTierLimitDialog({
    super.key,
    required this.limitTitle,
    required this.limitMessage,
  });

  static void show(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => FreeTierLimitDialog(
        limitTitle: title,
        limitMessage: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              limitTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            limitMessage,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upgrade to Premium for Unlimited Customers, Unlimited Sales, and PDF Reports Export!',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => const PaymentCheckoutModal(),
            );
          },
          child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
