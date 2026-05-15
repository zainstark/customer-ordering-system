import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class CartSectionHeader extends StatelessWidget {
  const CartSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(title, style: textTheme.headlineLarge),
        const SizedBox(height: AppDimensions.spacingSm),
        SelectableText(subtitle, style: textTheme.bodyLarge),
      ],
    );
  }
}
