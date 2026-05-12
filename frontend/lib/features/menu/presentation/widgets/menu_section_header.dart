import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class MenuSectionHeader extends StatelessWidget {
  const MenuSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
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
              Text(title, style: textTheme.headlineLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Text(subtitle!, style: textTheme.bodyLarge),
              ],
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
