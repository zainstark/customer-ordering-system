import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class OrdersSectionHeader extends StatelessWidget {
  const OrdersSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(title, style: textTheme.headlineLarge),
              const SizedBox(height: AppDimensions.spacingSm),
              SelectableText(subtitle, style: textTheme.bodyLarge),
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
