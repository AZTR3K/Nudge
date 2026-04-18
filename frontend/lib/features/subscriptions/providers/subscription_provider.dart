import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Ensure this path matches your project structure!
import 'package:nudge/features/subscriptions/data/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(Supabase.instance.client);
});

// The modern Riverpod approach for tracking UI states (like loading buttons)
class SubmittingNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Initial state

  void setStatus(bool isSubmitting) {
    state = isSubmitting;
  }
}

final isSubmittingProvider = NotifierProvider<SubmittingNotifier, bool>(
  SubmittingNotifier.new,
);

// ---------------------------------------------------------
// FIX: Changed from FutureProvider to StreamProvider
// and updated the method call to getSubscriptionsStream()
// ---------------------------------------------------------
final subscriptionsFutureProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final service = ref.watch(subscriptionServiceProvider);

  // This now points to the new Stream method in your service!
  return service.getSubscriptionsStream();
});
