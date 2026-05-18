import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class PaymentStatusBanner extends StatelessWidget {
  const PaymentStatusBanner({
    super.key,
    required this.status,
    required this.message,
  });

  final String status;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuccess = status.toLowerCase() == 'success';
    final color = isSuccess
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color: color,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
