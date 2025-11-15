// lib/models/item.dart

// Definisi model Item untuk merepresentasikan data produk/barang.
// Digunakan untuk konversi antara objek Dart <-> Map<String, dynamic>
// ketika menyimpan/ambil data dari Firebase Cloud Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  // Unique identifier untuk item. Di aplikasi ini digunakan juga sebagai
  // document ID di koleksi 'items' pada Firestore.
  final String kode;

  // Nama barang (nullable).
  final String? nama;

  // Satuan (mis. 'pcs', 'kg') (nullable).
  final String? satuan;

  // Harga beli dan jual (nullable). Tipe double digunakan untuk operasi
  // numerik. Saat menyimpan ke Firestore, disimpan sebagai number.
  final double? hargaBeli;
  final double? hargaJual;

  // createdAt / updatedAt menyimpan waktu pembuatan dan update.
  // Saat disimpan ke Firestore, kita menyimpan DateTime (Firestore akan
  // menyimpan sebagai Timestamp jika dikonversi oleh client SDK).
  // Saat membaca, kita mengonversi dari Timestamp ke DateTime.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    required this.kode,
    this.nama,
    this.satuan,
    this.hargaBeli,
    this.hargaJual,
    this.createdAt,
    this.updatedAt,
  });

  // Konversi objek Item -> Map untuk disimpan ke Firestore.
  // - Field names disesuaikan dengan key yang digunakan di Firestore.
  // - Jika createdAt/updatedAt null, kita isi dengan waktu sekarang.
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'kode': kode,
      'nama': nama,
      'satuan': satuan,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      // Gunakan DateTime; Firebase SDK akan mengonversi ke Timestamp.
      'created_at': createdAt ?? now,
      'updated_at': updatedAt ?? now,
    };
  }

  // Konversi Map (dari Firestore) -> objek Item.
  // - Firestore menyimpan Timestamp untuk field waktu, sehingga kita
  //   melakukan cast dari Timestamp ke DateTime dengan .toDate().
  // - Untuk numeric fields, cast ke num? lalu toDouble() untuk aman.
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      kode: map['kode'] as String,
      nama: map['nama'] as String?,
      satuan: map['satuan'] as String?,
      hargaBeli: (map['harga_beli'] as num?)?.toDouble(),
      hargaJual: (map['harga_jual'] as num?)?.toDouble(),
      // Jika field created_at/updated_at di Firestore berupa Timestamp,
      // lakukan cast ke Timestamp lalu .toDate(). Jika sudah disimpan
      // sebagai DateTime, cast ke DateTime? bisa langsung digunakan.
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    );
  }
}
