class Item {
  int? id;
  String name;
  String description;
  String category;
  double price;
  int stock;
  String imagePath;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.stock = 0,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
      imagePath: map['imagePath'],
    );
  }
}
