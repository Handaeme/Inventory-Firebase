import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  ItemDetailScreen({required this.item});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currencyFormat = NumberFormat('#,##0', 'id_ID');
  List<ItemTransaction> _transactions = [];
  String _supplierName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadSupplierName();
  }

  void _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('itemId', isEqualTo: widget.item.id)
          .get();

      setState(() {
        _transactions = querySnapshot.docs.map((doc) {
          return ItemTransaction(
            id: doc.id,
            itemId: doc['itemId'],
            type: doc['type'],
            quantity: doc['quantity'],
            date: doc['date'] != null && doc['date'] is Timestamp
                ? (doc['date'] as Timestamp).toDate().toString()
                : DateTime.now().toString(),
          );
        }).toList();
      });
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSupplierName() async {
    try {
      if (widget.item.supplierId.isNotEmpty) {
        final doc = await _firestore
            .collection('suppliers')
            .doc(widget.item.supplierId)
            .get();

        setState(() {
          _supplierName =
              doc.exists ? doc['name'] ?? 'Tidak diketahui' : 'Tidak diketahui';
        });
      } else {
        setState(() {
          _supplierName = 'Tidak diketahui';
        });
      }
    } catch (e) {
      print('Error loading supplier name: $e');
    }
  }

  void _deleteItem() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final transactionSnapshot = await _firestore
          .collection('transactions')
          .where('itemId', isEqualTo: widget.item.id)
          .get();

      for (var doc in transactionSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('items').doc(widget.item.id).delete();
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting item: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          widget.item.name,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Hapus Barang'),
                  content:
                      Text('Apakah Anda yakin ingin menghapus barang ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteItem();
                      },
                      child: Text('Hapus'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.item.imagePath.isNotEmpty
                              ? Image.network(
                                  widget.item.imagePath,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Kategori: ${widget.item.category}\n'
                                'Harga: Rp.${_currencyFormat.format(widget.item.price)}\n'
                                'Stok: ${widget.item.stock}\n'
                                'Supplier: $_supplierName',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.type == 'Masuk'
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              transaction.type == 'Masuk'
                                  ? Icons.add
                                  : Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            transaction.type,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('Jumlah: ${transaction.quantity}'),
                          trailing: Text(transaction.date,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12)),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTransactionScreen(item: widget.item),
                      ),
                    );
                    _loadTransactions();
                  },
                  child: Text('Tambah Transaksi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
