import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SummaryRow
    extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final bool large;

  const SummaryRow({
    required this.title,
    required this.value,
    this.valueColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight: large
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),

        Text(
          value,
          style: theme
              .textTheme
              .bodyLarge
              ?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: large ? 19 : null,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}