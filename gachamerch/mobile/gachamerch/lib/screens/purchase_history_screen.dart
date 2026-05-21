import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/stores.dart';
import '../models/purchase.dart';
import '../services/purchase_service.dart';
import '../main.dart';

// Page 8 â€” purchase history grouped by date with store badge
class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  List<Purchase> _purchases = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _purchases = await PurchaseService.fetchMyPurchases();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Group by date (YYYY-MM-DD)
  Map<String, List<Purchase>> get _grouped {
    final fmt = DateFormat('yyyy-MM-dd');
    final map = <String, List<Purchase>>{};
    for (final p in _purchases) {
      final key = fmt.format(p.createdAt.toLocal());
      map.putIfAbsent(key, () => []).add(p);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final accent  = Theme.of(context).colorScheme.primary;
    final moneyFmt = NumberFormat.currency(symbol: 'â‚±', decimalDigits: 2);
    final dateFmt  = DateFormat('MMMM d, yyyy');
    final grouped  = _grouped;
    final keys     = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : _purchases.isEmpty
                  ? Center(child: Text('No purchases yet.',
                      style: Theme.of(context).textTheme.bodyMedium))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: keys.length,
                        itemBuilder: (_, gi) {
                          final dateStr = keys[gi];
                          final list = grouped[dateStr]!;
                          final dateLabel = dateFmt.format(DateTime.parse(dateStr));
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(dateLabel,
                                  style: TextStyle(color: accent,
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              ...list.map((p) {
                                final storeMeta = storeById(p.store);
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: storeMeta.accent.withValues(alpha: 0.12),
                                        border: Border.all(color: storeMeta.accent),
                                      ),
                                      child: Icon(Icons.storefront,
                                        color: storeMeta.accent, size: 20),
                                    ),
                                    title: Text(p.itemName ?? 'Item #${p.itemId}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: storeMeta.accent.withValues(alpha: 0.1),
                                          ),
                                          child: Text(storeMeta.label,
                                            style: TextStyle(
                                              color: storeMeta.accent, fontSize: 11)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Qty: ${p.quantity} Ã— ${moneyFmt.format(p.unitPrice)}'),
                                      ],
                                    ),
                                    trailing: Text(moneyFmt.format(p.total),
                                      style: TextStyle(color: accent,
                                        fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}
