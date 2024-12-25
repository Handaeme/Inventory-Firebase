import 'package:flutter/material.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ItemTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  /// Memuat transaksi dari database
  void _loadTransactions() async {
    final transactions = await _dbHelper.getTransactions(widget.item.id!);
    setState(() {
      _transactions = transactions;
    });
  }

  /// Menghapus item dari database
  void _deleteItem() async {
    await _dbHelper.deleteItem(widget.item.id!);
    Navigator.pop(context); // Kembali ke layar sebelumnya setelah menghapus
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteItem();
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informasi detail barang
          ListTile(
            title: Text(widget.item.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi: ${widget.item.description}'),
                Text('Kategori: ${widget.item.category}'),
                Text('Harga: Rp ${widget.item.price}'),
                Text('Stok: ${widget.item.stock}'),
              ],
            ),
            isThreeLine: true,
          ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionScreen(item: widget.item),
                  ),
                ).then((_) {
                  _loadTransactions(); 
                });
              },
              child: Text('Tambah Riwayat Transaksi'),
            ),
          ),
          SizedBox(height: 10),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? Center(child: Text('Belum ada riwayat transaksi'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return ListTile(
                        leading: Icon(
                          transaction.type == 'Masuk'
                              ? Icons.add
                              : Icons.remove,
                          color: transaction.type == 'Masuk'
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(
                            '${transaction.type} - ${transaction.quantity}'),
                        subtitle: Text('Tanggal: ${transaction.date}'),
                        trailing: Text(
                          'ID: ${transaction.id}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
