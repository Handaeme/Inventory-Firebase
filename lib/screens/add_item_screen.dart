import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sqlite/database/database_helper.dart';

import '../models/item.dart';

class AddItemScreen extends StatefulWidget {
  final Item? item;

  AddItemScreen({this.item});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _numberFormat = NumberFormat('#,##0', 'id_ID');

  String _name = '';
  String _description = '';
  String _category = '';
  double _price = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _name = widget.item!.name;
      _description = widget.item!.description;
      _category = widget.item!.category;
      _price = widget.item!.price;
      _imageFile = File(widget.item!.imagePath);
    }
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      _formKey.currentState!.save();

      final newItem = Item(
        id: widget.item?.id, // Jika item sudah ada, gunakan ID-nya.
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        imagePath: _imageFile!.path,
      );

      if (widget.item == null) {
        // Tambah item baru.
        await _dbHelper.insertItem(newItem);
      } else {
        // Perbarui item yang ada.
        await _dbHelper.updateItem(newItem);
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar belum dipilih!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nama Barang'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Kategori'),
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _price == 0 ? '' : _numberFormat.format(_price),
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _price = double.parse(value!.replaceAll('.', '')),
                validator: (value) =>
                    value!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              _imageFile == null
                  ? TextButton(
                      onPressed: _pickImage,
                      child: Text('Pilih Gambar'),
                    )
                  : Image.file(_imageFile!, height: 200),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
