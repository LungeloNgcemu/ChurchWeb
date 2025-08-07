import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master/services/notification_service.dart';
import 'package:master/ui/notifications/widgets/notificationSnackBar.dart';
import 'package:master/util/converter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final NotificationService notificationService = NotificationService();

  static Future init(BuildContext context) async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyC68W0ODoBk8taha9W08fVZcRbHUEbYUm0",
            authDomain: "churchconnect-8157d.firebaseapp.com",
            projectId: "churchconnect-8157d",
            storageBucket: "churchconnect-8157d.firebasestorage.app",
            messagingSenderId: "301652956348",
            appId: "1:301652956348:web:5773e288b7f491633e6cb9",
            measurementId: "G-6BBJLB1FXN"),
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Title: ${message.notification?.title}');
          debugPrint('Body: ${message.notification?.body}');

          try {
            showAwesomeNotification(
              context: context,
              title: message.notification?.title ?? 'New Notification',
              body: message.notification?.body ?? 'You have a new notification',
              contentType: ContentType.success,
            );
          } catch (e) {
            debugPrint('Error showing notification: $e');
          }
        }
      });

      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

      //  final serviceWorkerRegistration =
      // await navigator.serviceWorker.register(
      //   '/ChurchWeb/firebase-messaging-sw.js',
      //   scope: '/ChurchWeb/',
      // );

      getFCMToken();
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }

  static void showAwesomeNotification({
    required BuildContext context,
    required String title,
    required String body,
    required ContentType contentType,
  }) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 20,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AwesomeSnackbarContent(
            title: title,
            message: body,
            contentType: contentType,
            color: Colors.black87,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static void _handleMessage(RemoteMessage message) {
    debugPrint('Opened message: ${message.messageId}');
  }

  static Future<void> _firebaseBackgroundMessageHandler(
      RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  static Future<String?> getFCMToken() async {
    try {
      debugPrint('Attempting to get FCM token...');

      // For web, ensure messaging is properly initialized with service worker

      // This ensures the service worker is ready before token generation
      // await FirebaseMessaging.instance.setAutoInitEnabled(true);

      // // Explicitly request permissions if not granted
      // final NotificationSettings settings =
      //     await _firebaseMessaging.requestPermission();

      // if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      //   debugPrint('User denied notification permissions');
      //   return null;
      // }

      // Get token with VAPID keyt
      print("Starting...");
      String? token = await _firebaseMessaging.getToken(
        vapidKey:
            'BOcSkZvnrPLaW2gZicyvBphOAQQPkEmx1tDa3cQV04zFKzmQrpmqLqgJe8Jogrnv5dXapc4AsTHj2i4Oe0ymTPU',
      );
      print("end...");
      debugPrint('Successfully obtained FCM token: ${token ?? 'NULL'}');
      return token;
    } catch (e, stackTrace) {
      debugPrint('Error getting FCM token: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<bool> subscribeToChurchTopic(String church) async {
    String churchName = convertName(church);
    try {
      String? token = await getFCMToken();
      print('Token $token');
      if (token == null) return false;
      bool result =
          await notificationService.subscribeToTopic([token], churchName);
      if (result) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('subscribed_topic', churchName);
        debugPrint('Subscribed to church topic: $churchName');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to subscribe to topic $churchName: $e');
      return false;
    }
    return false;
  }

  static Future<bool> unsubscribeFromChurchTopic(String church) async {
    String churchName = convertName(church);
    try {
      String? token = await getFCMToken();
      if (token == null) return false;
      bool result =
          await notificationService.unsubscribeFromTopic([token], churchName);
      if (result) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('subscribed_topic');
        debugPrint('Unsubscribed from church topic: $churchName');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $churchName: $e');
      return false;
    }
    return false;
  }

  static Future<String?> getCurrentTopic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('subscribed_topic');
  }

  static Future<bool> sendMessageToTopic({
    required String topic,
    required String title,
    required String body,
  }) async {
    String churchName = convertName(topic);
    return notificationService.sendNotificationToTopic(
        topic: churchName, title: title, body: body);
  }
}
