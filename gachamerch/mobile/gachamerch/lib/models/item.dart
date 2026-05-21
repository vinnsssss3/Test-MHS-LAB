class Item {
  final int id;
  final String store;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String image;
  final double price;

  const Item({
    required this.id,
    required this.store,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> j) => Item(
    id:          j['id'] as int,
    store:       j['store'] as String,
    name:        j['name'] as String,
    type:        j['type'] as String,
    description: j['description'] as String,
    stock:       j['stock'] as int,
    image:       j['image'] as String,
    price:       double.parse(j['price'].toString()),
  );

  Item copyWith({int? stock}) => Item(
    id: id, store: store, name: name, type: type,
    description: description, stock: stock ?? this.stock,
    image: image, price: price,
  );
}
