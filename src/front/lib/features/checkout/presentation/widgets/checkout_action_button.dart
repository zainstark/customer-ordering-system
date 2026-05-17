import 'package:flutter/material.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

class CheckoutActionButton extends StatelessWidget {
  const CheckoutActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          ),
        ),
        child: isBusy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
