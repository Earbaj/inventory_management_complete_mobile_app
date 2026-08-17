import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerSummary
    extends StatelessWidget {

  final int totalCustomers;

  const CustomerSummary({
    required this.totalCustomers,
  });

  @override
  Widget build(BuildContext context) {

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      margin:
      const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),

      padding:
      const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: colorScheme
            .primary
            .withValues(alpha: 0.07),

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color: colorScheme
              .primary
              .withValues(alpha: 0.15),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: colorScheme
                  .primary
                  .withValues(
                alpha: 0.12,
              ),

              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),

            child: Icon(
              Icons.people_alt_outlined,
              color:
              colorScheme.primary,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                '$totalCustomers',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              Text(
                'Total Customers',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}