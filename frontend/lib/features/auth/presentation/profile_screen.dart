import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to leave Nudge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authServiceProvider).signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _editName(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.updateUser(
                UserAttributes(data: {'full_name': controller.text}),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(image.path);
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // ✅ Use 'public' bucket which exists by default in Supabase
      // OR change 'avatars' to whatever bucket you created in Supabase dashboard
      const bucketName =
          'avatars'; // must match exactly what's in Supabase Storage
      final path = '$userId/avatar.png'; // folder per user, avoids root clutter

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/png',
            ),
          );

      // ✅ Append cache-buster so the UI refreshes even if URL is the same
      final imageUrl =
          '${Supabase.instance.client.storage.from(bucketName).getPublicUrl(path)}'
          '?t=${DateTime.now().millisecondsSinceEpoch}';

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );
    } on StorageException catch (e) {
      if (!mounted) return;
      // ✅ Surface the actual Supabase storage error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Storage error: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    final userName = user?.userMetadata?['full_name'] ?? 'Nudge User';
    final userEmail = user?.email ?? 'No email found';
    final avatarUrl = user?.userMetadata?['avatar_url'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Avatar ──────────────────────────────────────────────
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person, size: 52, color: AppColors.primary)
                        : null,
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _updateProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Name & Email ────────────────────────────────────────
          GestureDetector(
            onTap: () => _editName(userName),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(userName, style: theme.textTheme.titleLarge),
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          // ── Account Section ─────────────────────────────────────
          _SectionLabel(label: 'ACCOUNT'),
          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: userName,
            onTap: () => _editName(userName),
          ),
          _SettingsTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: userEmail,
          ),

          const SizedBox(height: 24),

          // ── App Section ─────────────────────────────────────────
          _SectionLabel(label: 'APP'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: true, // hook up to a provider when ready
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'App Version',
            value: '1.0.0',
          ),

          const SizedBox(height: 24),

          // ── Danger Zone ─────────────────────────────────────────
          _SectionLabel(label: 'DANGER ZONE'),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Log Out',
            labelColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: _showLogoutDialog,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Reusable section label ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Reusable settings row ────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: value != null
            ? Text(value!, style: theme.textTheme.bodyMedium)
            : null,
        trailing:
            trailing ??
            (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
