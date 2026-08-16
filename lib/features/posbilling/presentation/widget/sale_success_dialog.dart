import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SaleSuccessDialog
    extends StatelessWidget {
  const SaleSuccessDialog();

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(22),
      ),

      contentPadding:
      const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        18,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 40,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Sale Successful!',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'The items have been successfully sold.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),

          const SizedBox(height: 18),

          Container(
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Invoice',
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'INV-2026-00125',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
              ),
            ),
          ),
        ],
      ),
    );
  }
}