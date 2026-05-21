import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/store_provider.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/store_hub_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/purchase_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/item_form_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: const GachaMerchApp(),
    ),
  );
}

class GachaMerchApp extends StatelessWidget {
  const GachaMerchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final store = storeProvider.current;
    // 5. Per-store re-theming: the entire MaterialApp re-themes when store changes
    return MaterialApp(
      title: 'GachaMerch',
      debugShowCheckedModeBanner: false,
      theme: buildStoreTheme(store.accent, store.background),
      home: const SplashScreen(),
      routes: {
        '/login':            (_) => const LoginScreen(),
        '/register':         (_) => const RegisterScreen(),
        '/hub':              (_) => const StoreHubScreen(),
        '/catalog':          (_) => const CatalogScreen(),
        '/detail':           (_) => const DetailScreen(),
        '/checkout':         (_) => const CheckoutScreen(),
        '/history':          (_) => const PurchaseHistoryScreen(),
        '/profile':          (_) => const ProfileScreen(),
        '/admin':            (_) => const AdminDashboardScreen(),
        '/admin/item-form':  (_) => const ItemFormScreen(),
      },
    );
  }
}

// Shared navigation drawer available from Hub onward
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final user   = auth.user;
    final store  = context.watch<StoreProvider>().current;
    final accent = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: store.background),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GachaMerch',
                    style: TextStyle(color: accent, fontSize: 22,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(user?.username ?? '',
                    style: const TextStyle(color: Color(0xFFB0B3C1))),
                  Text(user?.email ?? '',
                    style: const TextStyle(color: Color(0xFF6B6F82), fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.storefront, color: accent),
              title: const Text('Stores'),
              onTap: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
                Navigator.pushReplacementNamed(context, '/hub');
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: accent),
              title: const Text('Purchase History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/history');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: accent),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            if (user?.isAdmin == true) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.admin_panel_settings, color: accent),
                title: const Text('Admin Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
            ],
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
