import 'package:flutter/material.dart';

class SectionTitle
    extends StatelessWidget {

  final String title;
  final IconData icon;

  const SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Icon(
          icon,
          size: 19,

          color: Theme.of(context)
              .colorScheme
              .primary,
        ),

        const SizedBox(
          width: 7,
        ),

        Text(
          title,

          style:
          const TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }
}