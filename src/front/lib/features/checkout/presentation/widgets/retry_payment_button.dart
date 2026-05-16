import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class RetryPaymentButton extends StatelessWidget {
  const RetryPaymentButton({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onRetry,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          ),
        ),
        child: const Text('Retry payment'),
      ),
    );
  }
}
