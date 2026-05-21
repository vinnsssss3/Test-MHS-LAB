class Purchase {
  final int id;
  final int userId;
  final int itemId;
  final String store;
  final int quantity;
  final double unitPrice;
  final double total;
  final DateTime createdAt;
  final String? itemName;
  final String? itemImage;
  final String? username;

  const Purchase({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.store,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.createdAt,
    this.itemName,
    this.itemImage,
    this.username,
  });

  factory Purchase.fromJson(Map<String, dynamic> j) => Purchase(
    id:        j['id'] as int,
    userId:    j['user_id'] as int,
    itemId:    j['item_id'] as int,
    store:     j['store'] as String,
    quantity:  j['quantity'] as int,
    unitPrice: double.parse(j['unit_price'].toString()),
    total:     double.parse(j['total'].toString()),
    createdAt: DateTime.parse(j['created_at'] as String),
    itemName:  j['item_name'] as String?,
    itemImage: j['item_image'] as String?,
    username:  j['username'] as String?,
  );
}
