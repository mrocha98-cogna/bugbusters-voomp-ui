import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Adicione flutter_web_plugins no pubspec se necessário
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'src/app.dart';

void main() {
  usePathUrlStrategy();
  if (kIsWeb) {
    // Inicializa o factory para Web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Inicializa o factory para Desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  runApp(const VoompSellersApp());
}