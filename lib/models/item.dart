class Item {
  String? id; 
  String name;
  String description;
  String category;
  double price;
  int stock;
  String imagePath;
  String supplierId; 

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.stock = 0,
    required this.imagePath,
    required this.supplierId,
  });


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
      'supplierId': supplierId,
    };
  }


  factory Item.fromMap(Map<String, dynamic> map, String documentId) {
    return Item(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      imagePath: map['imagePath'] ?? '',
      supplierId: map['supplierId'] ?? '',
    );
  }


  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? stock,
    String? imagePath,
    String? supplierId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      supplierId: supplierId ?? this.supplierId,
    );
  }
}
