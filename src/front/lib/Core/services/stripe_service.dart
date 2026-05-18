import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static Future<void> init() async {
    // Set the publishable key for Stripe.
    Stripe.publishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';
    
    // Apply settings. This abstracts away Web vs iOS vs Android initialization details
    // under the hood when using flutter_stripe.
    await Stripe.instance.applySettings();
  }
}
