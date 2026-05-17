import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class PaymentProcessingIndicator extends StatelessWidget {
  const PaymentProcessingIndicator({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimensions.spacingXxxl),
        const CircularProgressIndicator(),
        const SizedBox(height: AppDimensions.spacingXl),
        Text(
          message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
