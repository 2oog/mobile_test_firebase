// lib/models/item.dart

// Definisi class Item buat nanti kalo nambah-nambah class lainnya (seperti karyawan) lebih gampang

import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String kode;
  final String? nama;
  final String? satuan;
  final double? hargaBeli;
  final double? hargaJual;
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

  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'kode': kode,
      'nama': nama,
      'satuan': satuan,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'created_at': createdAt ?? now,
      'updated_at': updatedAt ?? now,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      kode: map['kode'] as String,
      nama: map['nama'] as String?,
      satuan: map['satuan'] as String?,
      hargaBeli: (map['harga_beli'] as num?)?.toDouble(),
      hargaJual: (map['harga_jual'] as num?)?.toDouble(),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    );
  }
}
