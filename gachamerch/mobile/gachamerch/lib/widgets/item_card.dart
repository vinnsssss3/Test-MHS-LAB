import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final fmt    = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: _ItemImage(image: item.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accent, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(fmt.format(item.price),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
                  Text('${item.stock} in stock',
                    style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String image;
  const _ItemImage({required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.startsWith('http')) {
      return Image.network(image, fit: BoxFit.cover, width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder());
    }
    // Asset image (path like assets/images/xxx.png)
    return Image.asset(image, fit: BoxFit.cover, width: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF1E2340),
    child: const Center(child: Icon(Icons.image_not_supported, color: Color(0xFF4A4F6A), size: 40)));
}
