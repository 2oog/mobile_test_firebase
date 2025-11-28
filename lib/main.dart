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

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // You can do logging here if needed.
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // Ask runtime permission (Android 13+)
  final settings = await FirebaseMessaging.instance.requestPermission();
  // You could check settings.authorizationStatus here if you want.

  // Create Android notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'firestore_changes_channel',
    'Firestore Changes',
    description: 'Notifications for Firestore CRUD.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Subscribe to topic so all devices get the same messages
  await FirebaseMessaging.instance.subscribeToTopic('firestore_changes');

  // Foreground messages: show local notification
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'firestore_changes_channel',
            'Firestore Changes',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  // When user taps a notification and opens the app
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Optional: navigate to a specific page or show a dialog.
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initNotifications();
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
