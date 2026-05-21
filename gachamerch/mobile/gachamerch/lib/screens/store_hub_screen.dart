import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/stores.dart';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/store_card.dart';
import '../main.dart';

// Page 4 — pick a store
class StoreHubScreen extends StatelessWidget {
  const StoreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user   = context.watch<AuthProvider>().user;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GachaMerch'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.storefront, color: accent),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${user?.username ?? 'Traveler'}',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Choose your storefront to begin shopping.',
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: kStores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final store = kStores[i];
                    return StoreCard(
                      store: store,
                      onTap: () {
                        context.read<StoreProvider>().select(store);
                        Navigator.pushNamed(context, '/catalog');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
