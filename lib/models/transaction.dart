class ItemTransaction {
  String? id;
  String itemId;
  String type;
  int quantity;
  String date;

  ItemTransaction({
    this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.date,
  });

  /// Konversi objek ItemTransaction menjadi Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }

  /// Factory untuk membuat ItemTransaction dari Firestore Map
  factory ItemTransaction.fromMap(String id, Map<String, dynamic> map) {
    return ItemTransaction(
      id: id,
      itemId: map['itemId'] ?? '',
      type: map['type'] ?? '',
      quantity: map['quantity'] ?? 0,
      date: map['date'] ?? '',
    );
  }
}
