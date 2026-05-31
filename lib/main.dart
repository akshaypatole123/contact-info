import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_router.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Ensure Flutter engine is initialized before calling native platforms (like SQLite & image picker)
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize sqflite FFI on desktop platforms so the global
  // `openDatabase` API works correctly.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const ContactsApp());
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration (Material 3 Light and Dark Tones)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow user device preference dynamically
      
      // Routing Configurations via GetX
      initialRoute: AppRoutes.splash,
      getPages: AppRouter.routes,
      
      // Clean transition speeds
      defaultTransition: Transition.rightToLeftWithFade,
    );
  }
}
