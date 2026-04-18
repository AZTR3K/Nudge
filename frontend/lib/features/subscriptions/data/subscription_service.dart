import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  final SupabaseClient _supabase;
  SubscriptionService(this._supabase);

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
    });
  }

  // NEW: Stream to fetch subscriptions in real-time
  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to fetch subscriptions");
    }

    // Notice we use .select() instead of .stream()
    return await _supabase
        .from('subscriptions')
        .select()
        .eq('user_id', user.id)
        .order('due_date', ascending: true);
  }
}
