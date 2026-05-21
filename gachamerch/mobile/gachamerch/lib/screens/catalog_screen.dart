import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/stores.dart';
import '../config/theme.dart';
import '../models/item.dart';
import '../providers/store_provider.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import '../main.dart';

// Page 5 — re-themed per store, search + FilterChips + pull-to-refresh
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();
  List<Item> _items = [];
  bool _loading = true;
  String? _error;
  String? _selectedType;

  StoreMeta get _store => context.read<StoreProvider>().current;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _fetchItems({String? q, String? type}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final store = _store;
      _items = await ItemService.fetchItems(
        store: store.id,
        type:  type,
        q:     q?.isNotEmpty == true ? q : null,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String q) {
    _fetchItems(q: q, type: _selectedType);
  }

  void _onTypeSelected(String? type) {
    setState(() => _selectedType = type);
    _fetchItems(q: _searchCtrl.text, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>().current;
    // 5. Per-store re-theming: rebuild the entire catalog with this store's theme
    return Theme(
      data: buildStoreTheme(store.accent, store.background),
      child: Builder(builder: (ctx) => _buildScaffold(ctx, store)),
    );
  }

  Widget _buildScaffold(BuildContext ctx, StoreMeta store) {
    final accent = Theme.of(ctx).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(store.label),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accent),
          onPressed: () => Navigator.pop(ctx),
        ),
        actions: [
          Builder(builder: (c) => IconButton(
            icon: Icon(Icons.menu, color: accent),
            onPressed: () => Scaffold.of(c).openDrawer(),
          )),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Color(0xFFE6E8EF)),
              decoration: InputDecoration(
                hintText: 'Search ${store.label}…',
                prefixIcon: Icon(Icons.search, color: accent),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: accent),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        })
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // FilterChips for item type
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedType == null,
                    onSelected: (_) => _onTypeSelected(null),
                  ),
                  const SizedBox(width: 8),
                  ...store.types.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: _selectedType == t,
                      onSelected: (_) => _onTypeSelected(_selectedType == t ? null : t),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                    : _items.isEmpty
                        ? Center(child: Text('No items found',
                            style: Theme.of(ctx).textTheme.bodyMedium))
                        : RefreshIndicator(
                            onRefresh: () => _fetchItems(
                              q: _searchCtrl.text, type: _selectedType),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.72,
                                ),
                              itemCount: _items.length,
                              itemBuilder: (_, i) => ItemCard(
                                item: _items[i],
                                onTap: () => Navigator.pushNamed(
                                  ctx, '/detail', arguments: _items[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
