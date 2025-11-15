// lib/screens/home.dart

// Import library Flutter dan Firebase serta model Item.
// Flutter: UI
// cloud_firestore: koneksi ke Firebase Cloud Firestore (database NoSQL di cloud)
// models/items.dart: definisi model Item (toMap, fromMap, field)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/items.dart';

// definisi HomePage(), dari main.dart masuk ke sini!
// Widget Stateful karena ada state (input, selectedItem, dsb.)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // masuk ke state
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller untuk input form di bagian atas halaman.
  // Digunakan untuk mengambil/men-set nilai pada TextFormField.
  final formKey = GlobalKey<FormState>();
  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final satuanController = TextEditingController();
  final hargaBeliController = TextEditingController();
  final hargaJualController = TextEditingController();

  // Koneksi ke Firebase Cloud Firestore:
  // - FirebaseFirestore.instance.collection('items') menunjuk ke koleksi "items"
  // - Koleksi "items" berada di project Firebase yang terkonfigurasi di aplikasi
  // - Dokumen pada koleksi ini disimpan dengan document ID = kode (lihat penggunaan .doc(kode))
  // Untuk melihat data: buka Firebase Console -> Firestore Database -> collection "items"
  CollectionReference itemsRef = FirebaseFirestore.instance.collection('items');

  // Menyimpan item yang sedang dipilih untuk keperluan edit/delete.
  Item? selectedItem;

  @override
  void dispose() {
    // Bebaskan controller saat widget di-destroy untuk mencegah memory leak.
    kodeController.dispose();
    namaController.dispose();
    satuanController.dispose();
    hargaBeliController.dispose();
    hargaJualController.dispose();
    super.dispose();
  }

  // Simpan atau update item ke Firestore.
  // - Validasi form dulu
  // - Simpan dengan document ID sama dengan 'kode'
  // - Field createdAt/updatedAt disimpan sebagai timestamp lokal saat ini
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

    // Bersihkan form setelah berhasil disimpan.
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

  // Hapus item dari Firestore by document ID (kode).
  Future<void> deleteItem(String kode) async {
    await itemsRef.doc(kode).delete();
    setState(() => selectedItem = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item deleted successfully')));
  }

  // Isi controller dengan data item untuk mengaktifkan mode edit.
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
          // Bagian form di atas: input kode, nama, satuan, harga beli, harga jual.
          // Ada tombol Add/Update dan Delete (visible saat edit).
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

          // LIST DATA
          // Bagian menampilkan semua dokumen di koleksi 'items' menggunakan StreamBuilder.
          // Stream: itemsRef.snapshots() -> real-time updates dari Firestore.
          // Untuk setiap dokumen, data di-convert ke model Item via Item.fromMap.
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
