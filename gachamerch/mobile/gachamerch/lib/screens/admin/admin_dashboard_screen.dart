import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/stores.dart';
import '../../models/item.dart';
import '../../services/item_service.dart';
import '../../main.dart';

// Page 10 — admin item management with store tabs
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Item> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: kStores.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _loadForStore(kStores[_tab.index].id);
    });
    _loadForStore(kStores.first.id);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _loadForStore(String storeId) async {
    setState(() { _loading = true; _error = null; });
    try {
      _items = await ItemService.fetchItems(store: storeId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Item item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ItemService.deleteItem(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} deleted')));
      _loadForStore(kStores[_tab.index].id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent  = Theme.of(context).colorScheme.primary;
    final fmt     = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final store   = kStores[_tab.index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: accent,
          unselectedLabelColor: const Color(0xFF6B6F82),
          indicatorColor: accent,
          tabs: kStores.map((s) => Tab(text: s.label)).toList(),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.pushNamed(
            context, '/admin/item-form',
            arguments: {'store': store.id, 'item': null});
          if (created == true && mounted) {
            _loadForStore(store.id);
          }
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  onRefresh: () => _loadForStore(store.id),
                  child: _items.isEmpty
                      ? const Center(child: Text('No items yet. Tap + to add one.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final item = _items[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 48, height: 48,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.image.startsWith('http')
                                        ? Image.network(item.image, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image_not_supported))
                                        : Image.asset(item.image, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image_not_supported)),
                                  ),
                                ),
                                title: Text(item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('${item.type} • ${fmt.format(item.price)}'
                                  ' • Stock: ${item.stock}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: accent),
                                      onPressed: () async {
                                        final updated = await Navigator.pushNamed(
                                          context, '/admin/item-form',
                                          arguments: {'store': store.id, 'item': item});
                                        if (updated == true && mounted) {
                                          _loadForStore(store.id);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                      onPressed: () => _delete(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
