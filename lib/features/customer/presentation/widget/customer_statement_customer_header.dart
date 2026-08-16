import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../customer.dart';

class CustomerHeader
    extends StatelessWidget {

  final Customer customer;

  const CustomerHeader({
    required this.customer,
  });

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

        color:
        colorScheme.surface,

        borderRadius:
        BorderRadius.circular(
          17,
        ),

        border:
        Border.all(
          color:
          Theme.of(context)
              .dividerColor,
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,

            decoration:
            BoxDecoration(
              color: colorScheme
                  .primary
                  .withValues(
                alpha: 0.10,
              ),

              shape:
              BoxShape.circle,
            ),

            child: Center(
              child: Text(
                _initials(
                  customer.name,
                ),

                style:
                TextStyle(
                  color:
                  colorScheme.primary,

                  fontSize: 18,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  customer.name,

                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  customer.phone,

                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),

                if (customer
                    .address
                    .isNotEmpty) ...[

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    customer.address,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(
      String name,
      ) {

    final parts =
    name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first
          .substring(
        0,
        parts.first.length > 1
            ? 2
            : 1,
      )
          .toUpperCase();
    }

    return (
        parts.first[0] +
            parts.last[0]
    ).toUpperCase();
  }
}