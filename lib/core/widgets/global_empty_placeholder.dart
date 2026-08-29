import 'package:flutter/material.dart';

class GlobalEmptyPlaceholder extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imagePath;
  final double imageSize;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? actionButton;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;

  const GlobalEmptyPlaceholder({
    super.key,
    this.title = 'No Data Found',
    this.subtitle,
    this.imagePath = 'assets/icon/empty_placeholder.png',
    this.imageSize = 140,
    this.actionText,
    this.onAction,
    this.actionButton,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    this.isScrollable = true,
  });

  /// Helper constructor to display inside Sliver lists or CustomScrollView.
  static Widget sliver({
    String title = 'No Data Found',
    String? subtitle,
    String imagePath = 'assets/icon/empty_placeholder.png',
    double imageSize = 140,
    String? actionText,
    VoidCallback? onAction,
    Widget? actionButton,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: GlobalEmptyPlaceholder(
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
        imageSize: imageSize,
        actionText: actionText,
        onAction: onAction,
        actionButton: actionButton,
        padding: padding,
        isScrollable: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Placeholder Image with fallback
        Image.asset(
          imagePath,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: imageSize * 0.7,
              height: imageSize * 0.7,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: imageSize * 0.35,
                color: colorScheme.primary,
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: colorScheme.onSurface,
          ),
        ),

        // Subtitle / Description
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],

        // Action Button
        if (actionButton != null) ...[
          const SizedBox(height: 20),
          actionButton!,
        ] else if (actionText != null && onAction != null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              actionText!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );

    if (isScrollable) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          child: content,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: padding,
        child: content,
      ),
    );
  }
}
