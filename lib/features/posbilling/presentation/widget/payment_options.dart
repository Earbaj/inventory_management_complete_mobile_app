import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentOption
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PaymentOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(13),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              .withValues(alpha: 0.08)
              : null,
          borderRadius:
          BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : Theme.of(context)
                .dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? colorScheme.primary
                  : null,
              size: 20,
            ),

            const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                fontWeight:
                FontWeight.w600,
                color: selected
                    ? colorScheme.primary
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}