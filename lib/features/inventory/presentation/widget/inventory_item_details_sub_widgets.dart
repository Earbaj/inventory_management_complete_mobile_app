import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemDetail
    extends StatelessWidget {

  final String title;
  final String value;
  final Color? valueColor;

  const ItemDetail({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style:
          theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,

          style: TextStyle(
            fontWeight:
            FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}


class StatusBadge
    extends StatelessWidget {

  final String text;

  const StatusBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerHighest,

        borderRadius:
        BorderRadius.circular(6),
      ),

      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}


class StockAlert
    extends StatelessWidget {

  final String text;
  final IconData icon;
  final bool isError;

  const StockAlert({
    required this.text,
    required this.icon,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {

    final color =
    isError
        ? Colors.red
        : Colors.orange;

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),

        borderRadius:
        BorderRadius.circular(9),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 17,
            color: color,
          ),

          const SizedBox(width: 7),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}