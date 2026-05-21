import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/item.dart';
import '../providers/store_provider.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/themed_button.dart';

// Page 6 â€” item detail with quantity stepper
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final item   = ModalRoute.of(context)!.settings.arguments as Item;
    final store  = context.watch<StoreProvider>().current;
    final fmt    = NumberFormat.currency(symbol: 'â‚±', decimalDigits: 2);
    final accent = Theme.of(context).colorScheme.primary;

    return Theme(
      data: buildStoreTheme(store.accent, store.background),
      child: Scaffold(
        appBar: AppBar(title: Text(item.name)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large image
              SizedBox(
                width: double.infinity,
                height: 260,
                child: item.image.startsWith('http')
                    ? Image.network(item.image, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(accent))
                    : Image.asset(item.image, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(accent)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: accent.withValues(alpha: 0.15),
                          border: Border.all(color: accent.withValues(alpha: 0.5)),
                        ),
                        child: Text(item.type,
                          style: TextStyle(color: accent, fontSize: 13)),
                      ),
                      const Spacer(),
                      Text('${item.stock} in stock',
                        style: Theme.of(context).textTheme.labelSmall),
                    ]),
                    const SizedBox(height: 10),
                    Text(item.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    Text(fmt.format(item.price),
                      style: TextStyle(color: accent, fontSize: 26,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Text(item.description,
                      style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    // Validation 3: quantity â‰¤ stock
                    Row(children: [
                      Text('Quantity:', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 12),
                      QuantityStepper(
                        value: _quantity,
                        min:   1,
                        max:   item.stock,
                        onChanged: (v) {
                          if (v > item.stock) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Only ${item.stock} in stock')));
                          } else {
                            setState(() => _quantity = v);
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 6),
                    if (item.stock == 0)
                      const Text('Out of stock', style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 20),
                    Text('Total: ${fmt.format(item.price * _quantity)}',
                      style: TextStyle(color: accent, fontSize: 18,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ThemedButton(
                      label: 'Proceed to Checkout',
                      icon: Icons.shopping_cart_checkout,
                      onPressed: item.stock == 0 ? null : () {
                        Navigator.pushNamed(context, '/checkout',
                          arguments: {'item': item, 'quantity': _quantity});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(Color accent) => Container(
    color: const Color(0xFF1E2340),
    child: Center(child: Icon(Icons.image_not_supported, color: accent, size: 60)));
}
