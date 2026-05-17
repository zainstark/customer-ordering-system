import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class CheckoutHeader extends StatelessWidget {
  const CheckoutHeader({
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
        Text(title, style: textTheme.headlineLarge),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(subtitle, style: textTheme.bodyLarge),
      ],
    );
  }
}
