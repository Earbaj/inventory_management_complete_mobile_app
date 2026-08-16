import 'package:flutter/material.dart';

class QuantityController
    extends StatelessWidget {

  final int quantity;
  final int max;

  final ValueChanged<int>
  onChanged;

  const QuantityController({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,

        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),

      child: Row(
        children: [

          IconButton(
            visualDensity:
            VisualDensity.compact,

            onPressed:
            quantity > 0
                ? () {
              onChanged(
                quantity - 1,
              );
            }
                : null,

            icon:
            const Icon(
              Icons.remove_rounded,
              size: 19,
            ),
          ),

          SizedBox(
            width: 24,

            child: Text(
              '$quantity',

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          IconButton(
            visualDensity:
            VisualDensity.compact,

            onPressed:
            quantity < max
                ? () {
              onChanged(
                quantity + 1,
              );
            }
                : null,

            icon:
            const Icon(
              Icons.add_rounded,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}