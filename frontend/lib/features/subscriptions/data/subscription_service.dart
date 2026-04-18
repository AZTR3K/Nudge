import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  final SupabaseClient _supabase;

  SubscriptionService(this._supabase);

  /// Adds a new subscription to the database.
  /// The 'status' is set to 'Pending' by default.
  Future<void> addSubscription({
    required String name,
    required double amount,
    required DateTime dueDate,
    String? category,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to add subscriptions");
    }

    await _supabase.from('subscriptions').insert({
      'user_id': user.id,
      'service_name': name,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'category': category ?? 'General',
      'status': 'Pending', // Explicitly setting default status
    });
  }

  /// Returns a real-time stream of subscriptions for the current user.
  /// This triggers an automatic UI rebuild whenever a row is updated,
  /// deleted, or inserted in Supabase.
  Stream<List<Map<String, dynamic>>> getSubscriptionsStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to fetch subscriptions");
    }

    // .stream() requires the primaryKey to track changes across the web socket
    return _supabase
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('due_date', ascending: true);
  }

  /// Updates an existing subscription (used by Edit and Snooze sheets).
  Future<void> updateSubscription(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await _supabase.from('subscriptions').update(updates).eq('id', id);
  }
}
