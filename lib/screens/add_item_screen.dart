import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';

class AddItemScreen extends StatefulWidget {
  final Item? item;

  AddItemScreen({this.item});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberFormat = NumberFormat('#,##0', 'id_ID');

  String _name = '';
  String _description = '';
  String _category = '';
  String? _selectedSupplierId;
  double _price = 0;
  File? _imageFile;
  String? _imageUrl;


  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');
  final CollectionReference _suppliersRef =
      FirebaseFirestore.instance.collection('suppliers');

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _name = widget.item!.name;
      _description = widget.item!.description;
      _category = widget.item!.category;
      _price = widget.item!.price;
      _selectedSupplierId = widget.item!.supplierId;
      _imageUrl = widget.item!.imagePath;
    }
  }

  void _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    String fileName = 'items/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    // Ambil URL download gambar
    return await snapshot.ref.getDownloadURL();
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate() &&
        (_imageFile != null || _imageUrl != null) &&
        _selectedSupplierId != null) {
      _formKey.currentState!.save();

      // Jika tidak ada gambar baru, gunakan URL lama
      String imageUrl = _imageFile != null
          ? await _uploadImageToFirebase(_imageFile!)
          : _imageUrl!;

      // Buat data item
      Map<String, dynamic> newItemData = {
        'name': _name,
        'description': _description,
        'category': _category,
        'price': _price,
        'stock': 0, 
        'imagePath': imageUrl,
        'supplierId': _selectedSupplierId, // Simpan ID supplier
      };

      if (widget.item == null) {
        // Tambahkan item baru ke Firestore
        await _itemsRef.add(newItemData);
      } else {
        // Update item jika sudah ada
        await _itemsRef.doc(widget.item!.id).update(newItemData);
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field wajib diisi, termasuk supplier!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Tambah Barang' : 'Edit Barang',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          )
                        : _imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[700],
                                  size: 50,
                                ),
                              ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: Icon(Icons.photo_library, color: Colors.white),
                          label: Text('Galeri',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          label: Text('Kamera',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 32),
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) => _name = value!,
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) => _description = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _price == 0 ? '' : _numberFormat.format(_price),
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _price = double.parse(value!.replaceAll('.', '')),
                  validator: (value) =>
                      value!.isEmpty ? 'Harga tidak boleh kosong' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) => _category = value!,
                ),
                SizedBox(height: 16),
                FutureBuilder<QuerySnapshot>(
                  future: _suppliersRef.get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final suppliers = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Supplier',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value:
                          suppliers.any((doc) => doc.id == _selectedSupplierId)
                              ? _selectedSupplierId
                              : null,
                      items: suppliers.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplierId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Pilih supplier' : null,
                    );
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveItem,
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
      ),
    );
  }
}
