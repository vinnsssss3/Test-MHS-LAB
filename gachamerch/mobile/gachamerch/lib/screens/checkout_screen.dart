import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/item.dart';
import '../providers/store_provider.dart';
import '../services/item_service.dart';
import '../widgets/themed_button.dart';

// Page 7 — confirm quantity × price = total, then call /buy
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = false;

  Future<void> _confirm(BuildContext ctx, Item item, int quantity) async {
    setState(() => _loading = true);
    final nav       = Navigator.of(ctx);
    final messenger = ScaffoldMessenger.of(ctx);
    try {
      await ItemService.buyItem(item.id, quantity);
      if (!mounted) return;
      // Pop detail + checkout, return to catalog
      nav
        ..pop()  // checkout
        ..pop(); // detail
      messenger.showSnackBar(SnackBar(
        content: Text('Purchased $quantity x ${item.name} successfully!')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args     = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final item     = args['item'] as Item;
    final quantity = args['quantity'] as int;
    final total    = item.price * quantity;
    final fmt      = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final store    = context.watch<StoreProvider>().current;
    final accent   = Theme.of(context).colorScheme.primary;

    return Theme(
      data: buildStoreTheme(store.accent, store.background),
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Summary',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _row('Item', item.name, context),
                      const Divider(),
                      _row('Type', item.type, context),
                      const Divider(),
                      _row('Store', store.label, context),
                      const Divider(),
                      _row('Unit Price', fmt.format(item.price), context),
                      const Divider(),
                      _row('Quantity', '$quantity', context),
                      const Divider(),
                      _row('Total', fmt.format(total), context,
                        style: TextStyle(color: accent, fontWeight: FontWeight.bold,
                          fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Total = ${fmt.format(item.price)} × $quantity = ${fmt.format(total)}',
                style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              ThemedButton(
                label: 'Confirm Purchase',
                loading: _loading,
                icon: Icons.check_circle_outline,
                onPressed: () => _confirm(context, item, quantity),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent, side: BorderSide(color: accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                  child: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, BuildContext ctx, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(ctx).textTheme.bodyMedium),
          Flexible(child: Text(value,
            textAlign: TextAlign.end,
            style: style ?? Theme.of(ctx).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
