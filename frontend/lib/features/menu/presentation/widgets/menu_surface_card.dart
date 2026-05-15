import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class MenuSurfaceCard extends StatelessWidget {
  const MenuSurfaceCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: child,
    );
  }
}
