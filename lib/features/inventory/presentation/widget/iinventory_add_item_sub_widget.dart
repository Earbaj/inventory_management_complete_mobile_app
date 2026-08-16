import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormSectionTitle
    extends StatelessWidget {

  final String title;

  const FormSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(
        fontWeight:
        FontWeight.w800,
      ),
    );
  }
}