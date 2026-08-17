import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatementSummaryCard
    extends StatelessWidget {

  final String title;
  final double value;

  const StatementSummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
      const EdgeInsets.all(12),

      decoration:
      BoxDecoration(

        color:
        Theme.of(context)
            .colorScheme
            .surface,

        borderRadius:
        BorderRadius.circular(
          13,
        ),

        border:
        Border.all(
          color:
          Theme.of(context)
              .dividerColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            '৳ ${value.toStringAsFixed(0)}',

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}