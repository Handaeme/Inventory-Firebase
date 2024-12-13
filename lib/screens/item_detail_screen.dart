import 'dart:io';

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
        title: Text(
          widget.item.name,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informasi detail barang
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.item.imagePath.isNotEmpty
                          ? Image.file(
                              File(widget.item.imagePath),
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
                          Row(
                            children: [
                              Icon(Icons.label, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text(
                                widget.item.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Deskripsi: ${widget.item.description}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.category, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Kategori: ${widget.item.category}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.monetization_on, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Harga: Rp ${widget.item.price}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.inventory, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Stok: ${widget.item.stock}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
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
              child: Text(
                'Tambah Riwayat Transaksi',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            Expanded(
              child: _transactions.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada riwayat transaksi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              transaction.type == 'Masuk'
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              color: transaction.type == 'Masuk'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              '${transaction.type} - ${transaction.quantity}',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              'Tanggal: ${transaction.date}',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            trailing: Text(
                              'ID: ${transaction.id}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
