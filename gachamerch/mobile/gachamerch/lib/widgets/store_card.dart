import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/stores.dart';

class StoreCard extends StatelessWidget {
  final StoreMeta store;
  final VoidCallback onTap;

  const StoreCard({super.key, required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: store.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: store.accent, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: store.accent.withValues(alpha: 0.15),
                  border: Border.all(color: store.accent, width: 1.5),
                ),
                child: Icon(Icons.storefront, color: store.accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.label,
                      style: GoogleFonts.orbitron(
                        color: store.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    const SizedBox(height: 4),
                    Text(store.tagline,
                      style: const TextStyle(color: Color(0xFFB0B3C1), fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: store.types.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: store.accent.withValues(alpha: 0.12),
                          border: Border.all(color: store.accent.withValues(alpha: 0.4)),
                        ),
                        child: Text(t,
                          style: TextStyle(color: store.accent, fontSize: 11)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: store.accent),
            ],
          ),
        ),
      ),
    );
  }
}
