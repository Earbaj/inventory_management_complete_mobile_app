import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyCustomers
    extends StatelessWidget {

  const EmptyCustomers();

  @override
  Widget build(BuildContext context) {

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Center(

      child: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Container(
              width: 80,
              height: 80,

              decoration:
              BoxDecoration(
                color: colorScheme
                    .primary
                    .withValues(
                  alpha: 0.08,
                ),

                shape:
                BoxShape.circle,
              ),

              child: Icon(
                Icons
                    .people_outline_rounded,

                size: 38,

                color:
                colorScheme.primary,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'No customers found',

              style:
              TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              'Try another customer name.',

              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,

              textAlign:
              TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}