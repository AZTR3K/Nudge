import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // 2. Extract the name from metadata with a fallback
    // Supabase stores registration data in a map called 'user_metadata'
    final userName = user?.userMetadata?['full_name'] ?? 'Nudge User';
    final userEmail = user?.email ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.onPrimaryFixed,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Text(
            userName, // Dynamic name
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail, // Subtitle email
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 32),
          const Divider(color: AppColors.outlineVariant),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('App Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            trailing: const Text('Dark Mode'),
            onTap: () {},
          ),
          const Divider(color: AppColors.outlineVariant),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
    );
  }
}
