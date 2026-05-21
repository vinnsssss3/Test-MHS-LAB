import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../main.dart';

// Page 9 â€” user info + logout
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final user   = auth.user;
    final accent = Theme.of(context).colorScheme.primary;
    final dateFmt = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: accent.withValues(alpha: 0.15),
                  child: Text(
                    user.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 36, color: accent,
                      fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Text(user.username,
                  style: Theme.of(context).textTheme.headlineMedium),
                Text(user.email,
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: accent.withValues(alpha: 0.15),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Text(user.role.toUpperCase(),
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _infoRow('Account type', user.oauthProvider, context),
                      const Divider(),
                      _infoRow('Member since',
                        dateFmt.format(user.createdAt.toLocal()), context),
                      const Divider(),
                      _infoRow('User ID', '#${user.id}', context),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (_) => false);
                      }
                    },
                  ),
                ),
              ]),
            ),
    );
  }

  Widget _infoRow(String label, String value, BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: Theme.of(ctx).textTheme.bodyMedium),
      Text(value, style: Theme.of(ctx).textTheme.bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600)),
    ]),
  );
}
