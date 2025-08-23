import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<void> envInit() async {
    final currentUrl = html.window.location.href;
    if (currentUrl.contains("uat")) {
      await dotenv.load(fileName: "envUat");
    } else if (currentUrl.contains("localhost")) {
      await dotenv.load(fileName: "envDev");
    } else {
      await dotenv.load(fileName: "envProd");
    }
  }
}
