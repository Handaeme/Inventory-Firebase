import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatelessWidget {
  final Item item;
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _type = 'Masuk';
  int _quantity = 0;

  AddTransactionScreen({required this.item});

  void _saveTransaction(BuildContext context) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final transaction = ItemTransaction(
      itemId: item.id!,
      type: _type,
      quantity: _quantity,
      date: date,
    );

    await _dbHelper.insertTransaction(transaction);
    final newStock =
        _type == 'Masuk' ? item.stock + _quantity : item.stock - _quantity;
    await _dbHelper.updateItemStock(item.id!, newStock);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Riwayat')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: ['Masuk', 'Keluar']
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => _type = value!,
              decoration: InputDecoration(labelText: 'Jenis Transaksi'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Jumlah'),
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
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
