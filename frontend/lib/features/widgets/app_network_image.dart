import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.restaurant_outlined,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;


    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: colorScheme.surfaceContainerHigh,
            child: Center(
              child: Icon(
                placeholderIcon,
                size: AppDimensions.iconXl,
                color: colorScheme.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colorScheme.surfaceContainerHigh,
            child: Center(
              child: Icon(
                placeholderIcon,
                size: AppDimensions.iconXl,
                color: colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
