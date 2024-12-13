import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Item item;

  AddTransactionScreen({required this.item});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _type = 'Masuk';
  int _quantity = 0;

  void _saveTransaction(BuildContext context) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final transaction = ItemTransaction(
      itemId: widget.item.id!,
      type: _type,
      quantity: _quantity,
      date: date,
    );

    await _dbHelper.insertTransaction(transaction);
    final newStock = _type == 'Masuk'
        ? widget.item.stock + _quantity
        : widget.item.stock - _quantity;
    await _dbHelper.updateItemStock(widget.item.id!, newStock);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Riwayat',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Masuk', 'Keluar']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
                decoration: InputDecoration(
                  labelText: 'Jenis Transaksi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Masukkan jumlah yang valid';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveTransaction(context);
                  }
                },
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
