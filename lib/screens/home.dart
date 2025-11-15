// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/items.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final satuanController = TextEditingController();
  final hargaBeliController = TextEditingController();
  final hargaJualController = TextEditingController();

  CollectionReference itemsRef = FirebaseFirestore.instance.collection('items');

  Item? selectedItem;

  @override
  void dispose() {
    kodeController.dispose();
    namaController.dispose();
    satuanController.dispose();
    hargaBeliController.dispose();
    hargaJualController.dispose();
    super.dispose();
  }

  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) return;

    final kode = kodeController.text.trim();
    final nama = namaController.text.trim();
    final satuan = satuanController.text.trim();
    final hargaBeli = double.tryParse(hargaBeliController.text.trim());
    final hargaJual = double.tryParse(hargaJualController.text.trim());
    final now = DateTime.now();

    await itemsRef
        .doc(kode)
        .set(
          Item(
            kode: kode,
            nama: nama,
            satuan: satuan,
            hargaBeli: hargaBeli,
            hargaJual: hargaJual,
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );

    kodeController.clear();
    namaController.clear();
    satuanController.clear();
    hargaBeliController.clear();
    hargaJualController.clear();
    setState(() => selectedItem = null);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item saved successfully')));
  }

  Future<void> deleteItem(String kode) async {
    await itemsRef.doc(kode).delete();
    setState(() => selectedItem = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item deleted successfully')));
  }

  void editItem(Item item) {
    kodeController.text = item.kode;
    namaController.text = item.nama ?? '';
    satuanController.text = item.satuan ?? '';
    hargaBeliController.text = item.hargaBeli?.toString() ?? '';
    hargaJualController.text = item.hargaJual?.toString() ?? '';
    setState(() => selectedItem = item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          // INPUTS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: kodeController,
                    decoration: const InputDecoration(labelText: 'Kode'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Kode tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: satuanController,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Satuan tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: hargaBeliController,
                    decoration: const InputDecoration(labelText: 'Harga Beli'),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Harga Beli tidak boleh kosong'
                                : null,
                  ),
                  TextFormField(
                    controller: hargaJualController,
                    decoration: const InputDecoration(labelText: 'Harga Jual'),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Harga Jual tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: saveItem,
                        child: Text(selectedItem == null ? 'Add' : 'Update'),
                      ),
                      const SizedBox(width: 12),
                      if (selectedItem != null)
                        ElevatedButton(
                          onPressed: () => deleteItem(selectedItem!.kode),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: itemsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data!.docs;
                final items =
                    docs
                        .map(
                          (doc) =>
                              Item.fromMap(doc.data() as Map<String, dynamic>),
                        )
                        .toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(item.nama ?? ''),
                        subtitle: Text(
                          '${item.satuan ?? ''} - Rp${item.hargaJual?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                        trailing: Text(item.kode),
                        onTap: () => editItem(item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
