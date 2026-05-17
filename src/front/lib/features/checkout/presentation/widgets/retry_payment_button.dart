import 'package:flutter/material.dart';

class RetryPaymentButton extends StatelessWidget {
  const RetryPaymentButton({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onRetry,
      child: const Text('Retry payment'),
    );
  }
}
