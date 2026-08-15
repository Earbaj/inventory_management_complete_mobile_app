import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  final Color iconBackground;
  final Color iconColor;

  final String? percentage;
  final String? subtitle;

  final bool isPositive;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.percentage,
    this.subtitle,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: theme.dividerColor.withValues(
            alpha: 0.5,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                  BorderRadius.circular(11),
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),

          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 5),

          if (percentage != null)
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 13,
                  color: isPositive
                      ? Colors.green
                      : Colors.red,
                ),

                Text(
                  percentage!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                const SizedBox(width: 4),

                Flexible(
                  child: Text(
                    'vs last week',
                    overflow:
                    TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}