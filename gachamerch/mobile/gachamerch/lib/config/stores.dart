import 'package:flutter/material.dart';

class StoreMeta {
  final String id;
  final String label;
  final String tagline;
  final Color accent;
  final Color background;
  final List<String> types;

  const StoreMeta({
    required this.id,
    required this.label,
    required this.tagline,
    required this.accent,
    required this.background,
    required this.types,
  });
}

const List<StoreMeta> kStores = [
  StoreMeta(
    id: 'honkai_star_retail',
    label: 'Honkai Star Retail',
    tagline: 'Galactic resources & light cones',
    accent: Color(0xFFFFD86B),
    background: Color(0xFF0B1026),
    types: ['Light Cone', 'Galactic Resource'],
  ),
  StoreMeta(
    id: 'genshin_import',
    label: 'Genshin Import',
    tagline: 'Teyvat weapons & artifacts',
    accent: Color(0xFF5BD0C7),
    background: Color(0xFF0E1A2B),
    types: ['Weapon', 'Artifact'],
  ),
  StoreMeta(
    id: 'wuthering_wares',
    label: 'Wuthering Wares',
    tagline: 'Resonator equipment & terminal supplies',
    accent: Color(0xFFE0455B),
    background: Color(0xFF13121A),
    types: ['Resonator Equipment', 'Terminal Supply'],
  ),
];

StoreMeta storeById(String id) =>
    kStores.firstWhere((s) => s.id == id, orElse: () => kStores.first);
