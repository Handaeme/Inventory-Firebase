import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String _type = 'Masuk';
  int _quantity = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveTransaction(BuildContext context) async {
    if (_type == 'Keluar' && widget.item.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stok tidak mencukupi untuk transaksi Keluar')));
      return;
    }

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final transaction = ItemTransaction(
      itemId: widget.item.id!,
      type: _type,
      quantity: _quantity,
      date: date,
    );

    try {
      await _firestore.collection('transactions').add(transaction.toMap());

      await _firestore.collection('items').doc(widget.item.id).update({
        'stock':
            FieldValue.increment(_type == 'Masuk' ? _quantity : -_quantity),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Transaksi berhasil disimpan')));

      Navigator.pop(context); // Kembali setelah menyimpan transaksi
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')));
    }
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
