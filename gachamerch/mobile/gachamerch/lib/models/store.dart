// Runtime store metadata fetched from /api/stores.
// For offline fallback and theming use config/stores.dart.
class StoreInfo {
  final String id;
  final String label;
  final String tagline;
  final String accent;
  final List<String> types;

  const StoreInfo({
    required this.id,
    required this.label,
    required this.tagline,
    required this.accent,
    required this.types,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> j) => StoreInfo(
    id:      j['id'] as String,
    label:   j['label'] as String,
    tagline: j['tagline'] as String,
    accent:  j['accent'] as String,
    types:   List<String>.from(j['types'] as List),
  );
}
