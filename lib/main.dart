import 'package:billing_app/presentation/home.dart';

import 'package:flutter/material.dart';

// No need to import 'dart:io' or 'package:sqflite_common_ffi/sqflite_ffi.dart'
// for mobile-only applications, as the default sqflite works out of the box.

Future<void> main() async {
  // Ensure that Flutter's widget binding is initialized.
  // This is crucial before any Flutter-specific operations,
  // including running the app or accessing plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // For mobile platforms (Android/iOS), the default SQLite implementation
  // provided by the `sqflite` package is used automatically.
  // No special initialization like `sqfliteFfiInit()` or `databaseFactoryFfi`
  // is required for mobile.

  // Run the main application widget.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the core widget for a Material Design app.
    return const MaterialApp(
      // Disables the debug banner in the top right corner of the app.
      debugShowCheckedModeBanner: false,
      // Sets the initial screen of the application to the Splash widget.
      home: DashboardScreen(),
    );
  }
}