import 'package:flutter/material.dart';

class NoTransactions
    extends StatelessWidget {

  const NoTransactions({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(25),

      decoration:
      BoxDecoration(

        color:
        Theme.of(context)
            .colorScheme
            .surface,

        borderRadius:
        BorderRadius.circular(
          15,
        ),

        border:
        Border.all(
          color:
          Theme.of(context)
              .dividerColor,
        ),
      ),

      child: Column(
        children: [

          const Icon(
            Icons
                .receipt_long_outlined,

            size: 35,
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'No transactions yet',

            style:
            TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}