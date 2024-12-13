import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _currencyFormat = NumberFormat('#,##0', 'id_ID');
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Barang',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Belum ada barang',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(item: item),
                      ),
                    ).then((_) => _loadItems()),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blueAccent.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(item.imagePath),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory,
                                          color: Colors.grey, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Stok: ${item.stock}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.monetization_on,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Harga: ${_currencyFormat.format(item.price)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddItemScreen(item: item),
                                ),
                              ).then((_) => _loadItems()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddItemScreen()),
        ).then((_) => _loadItems()),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
