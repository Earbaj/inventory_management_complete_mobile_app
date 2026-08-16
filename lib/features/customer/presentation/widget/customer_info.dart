import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerInfo
    extends StatelessWidget {

  final String title;
  final String value;

  const CustomerInfo({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
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
          height: 3,
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }
}