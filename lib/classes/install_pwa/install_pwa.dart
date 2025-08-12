import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:js' as js;
import 'dart:html' as html;

class InstallPwa {
  static const _installedKey = 'pwa_installed';
  static const _installPromptDismissedKey = 'pwa_install_dismissed';

  static void showInstallPrompt() {
    js.context.callMethod('showInstallPrompt');
  }

  static Future<void> setInstalled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_installedKey, true);
  }

  static Future<void> setDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_installPromptDismissedKey, true);
  }

  static Future<bool> isInstalled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_installedKey) ?? false;
  }

  static Future<bool> isDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_installPromptDismissedKey) ?? false;
  }

  static void listenForAppInstalled() {
    js.context.callMethod('addEventListener', [
      'appinstalled',
      (event) async {
        await setInstalled();
        debugPrint('PWA installed event detected');
      }
    ]);
  }

  static String platform() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();

    if (userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod')) {
      return 'ios';
    } else if (userAgent.contains('android')) {
      return 'android';
    } else {
      return 'web';
    }
  }
}
