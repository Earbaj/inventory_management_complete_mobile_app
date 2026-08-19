import 'package:flutter/material.dart';

class CustomerInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const CustomerInfo({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}