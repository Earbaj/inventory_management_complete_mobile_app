import 'package:flutter/material.dart';

class ReturnHeader
    extends StatelessWidget {

  const ReturnHeader();

  @override
  Widget build(BuildContext context) {

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(

      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(

        color: colorScheme
            .primary
            .withValues(
          alpha: 0.07,
        ),

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: colorScheme
              .primary
              .withValues(
            alpha: 0.15,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,

            decoration:
            BoxDecoration(
              color: colorScheme
                  .primary
                  .withValues(
                alpha: 0.12,
              ),

              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              Icons
                  .assignment_return_outlined,

              color:
              colorScheme.primary,

              size: 27,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  'Process Return',

                  style:
                  TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  'Select customer and invoice '
                      'to process returned items.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}