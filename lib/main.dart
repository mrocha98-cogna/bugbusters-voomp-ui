import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Adicione flutter_web_plugins no pubspec se necessário
import 'src/app.dart';

void main() {
  usePathUrlStrategy();

  runApp(const VoompSellersApp());
}
