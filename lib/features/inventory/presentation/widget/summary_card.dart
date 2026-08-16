import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SummaryCard
    extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  final bool selected;
  final VoidCallback onTap;

  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,

      borderRadius:
      BorderRadius.circular(16),

      child: Container(
        width: 145,

        padding:
        const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              .withValues(alpha: 0.08)
              : colorScheme.surface,

          borderRadius:
          BorderRadius.circular(16),

          border: Border.all(
            color: selected
                ? colorScheme.primary
                : theme.dividerColor,
          ),
        ),

        child: Row(
          children: [

            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: colorScheme.primary
                    .withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(10),
              ),

              child: Icon(
                icon,
                size: 21,
                color:
                colorScheme.primary,
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: theme
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}