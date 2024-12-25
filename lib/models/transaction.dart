class ItemTransaction {
  int? id;
  int itemId;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }

  factory ItemTransaction.fromMap(Map<String, dynamic> map) {
    return ItemTransaction(
      id: map['id'],
      itemId: map['itemId'],
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'],
    );
  }
}
