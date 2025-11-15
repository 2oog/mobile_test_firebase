// Repository: mobile_test_firebase
// Tujuan: contoh aplikasi Flutter yang terhubung ke Firebase (Cloud Firestore).
// Fitur utama:
// - Menyimpan, memperbarui, dan menghapus data "items" pada koleksi 'items' di Firestore.
// - Menampilkan daftar items secara real-time menggunakan StreamBuilder.
// - Struktur kode: main.dart (inisialisasi Firebase + jalankan app), screens/home.dart (UI & CRUD), models/items.dart (model Item).
// Catatan: Pastikan file firebase_options.dart ter-generate (FlutterFire CLI) dan project Firebase sudah dikonfigurasi.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// import HomePage() dari file lain
// HomePage berisi UI form untuk Add/Update/Delete dan list real-time dari koleksi 'items'.
import './screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase sebelum menjalankan app.
  // DefaultFirebaseOptions.currentPlatform dihasilkan oleh FlutterFire CLI (firebase_options.dart)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Items Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
