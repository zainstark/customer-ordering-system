import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class PaymentErrorCard extends StatelessWidget {
  const PaymentErrorCard({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
