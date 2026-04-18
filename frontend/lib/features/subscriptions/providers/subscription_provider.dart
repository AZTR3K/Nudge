import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Ensure this path matches your project structure!
import 'package:nudge/features/subscriptions/data/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(Supabase.instance.client);
});

// The modern Riverpod approach: Notifier
class SubmittingNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Initial state

  // Create a safe method to update the state from our UI
  void setStatus(bool isSubmitting) {
    state = isSubmitting;
  }
}

// Expose the Notifier to the rest of the app
final isSubmittingProvider = NotifierProvider<SubmittingNotifier, bool>(
  SubmittingNotifier.new,
);
