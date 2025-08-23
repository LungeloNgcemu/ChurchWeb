import 'package:master/constants/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  String? baseUrl;

  NotificationService({String? baseUrl}) : baseUrl = baseUrl ?? BaseUrl.baseUrl;

  Future<bool> subscribeToTopic(List<String> tokens, String topic) async {
    final url = Uri.parse('$baseUrl/api/notifications/subscribe');
    print('Calling');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'registrationTokens': tokens,
        'topic': topic,
      }),
    );

    if (response.statusCode == 200) {
      print('Subscribed successfully!');
      return true;
    } else {
      print('Subscribe failed: ${response.body}');
      return false;
    }
  }

  Future<bool> unsubscribeFromTopic(List<String> tokens, String topic) async {
    final url = Uri.parse('$baseUrl/api/notifications/unsubscribe');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'registrationTokens': tokens,
        'topic': topic,
      }),
    );

    if (response.statusCode == 200) {
      print('Unsubscribed successfully!');
      return true;
    } else {
      print('Unsubscribe failed: ${response.body}');
      return false;
    }
  }

  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('$baseUrl/api/notifications/send');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
      return true;
    } else {
      print('Send notification failed: ${response.body}');
      return false;
    }
  }
}
