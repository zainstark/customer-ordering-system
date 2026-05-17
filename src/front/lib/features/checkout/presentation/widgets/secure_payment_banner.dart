import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class SecurePaymentBanner extends StatelessWidget {
  const SecurePaymentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: colorScheme.primary),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              'Encrypted & secure checkout powered by your chosen payment provider.',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
