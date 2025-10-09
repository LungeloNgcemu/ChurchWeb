import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:master/Model/message_model.dart';
import 'package:master/constants/constants.dart';
import 'package:master/providers/message_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class IOService {
  static late IO.Socket socket;
  static final String serverUrl = BaseUrl.baseUrl!;

  IOService();

  static Future<void> initializeWithProvider(BuildContext context) async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    _initSocket(messageProvider);
  }

  static void _initSocket(MessageProvider messageProvider) {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.onError((error) {
      print('Socket error: $error');
    });

    socket.on('initial messages', (data) {
      print('initial messages: $data');
      if (messageProvider != null) {
        final messages = _convertToMessageModelList(data);
        messageProvider!.addMessages(messages);
      }
    });

    socket.on('new message', (data) async {
      if (data != null) {
        try {
          if (data is Map<String, dynamic>) {
            final message = MessageModel.fromJson(data);

            scheduleMicrotask(() {
              messageProvider!.addMessage(message);
            });

            print('Successfully processed message: ${message.message}');
          } else {
            print('Unexpected data type: ${data.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('Error processing message: $e');
          print('Stack trace: $stackTrace');
        }
      }
    });

    socket.on('delete message', (data) {
      print('deleted data message: $data');
      final messageId = data;
      if (messageProvider != null) {
        messageProvider!.removeMessage(messageId);
      }
    });

    socket.on('delete_error', (data) {
      final messageId = data['id'];
      final error = data['error'];
    });
    socket.connect();
  }

  static List<MessageModel> _convertToMessageModelList(dynamic data) {
    if (data is List) {
      return data.map<MessageModel>((item) {
        if (item is Map<String, dynamic>) {
          return MessageModel.fromJson(item);
        } else {
          return MessageModel.fromJson({});
        }
      }).toList();
    }
    return [];
  }

  static void joinRoom(String uniqueId) {
    socket.emit('join', uniqueId);
  }

  static Future<void> sendMessage({
    required String uniqueId,
    required String message,
    required String sender,
    required String senderId,
    required String time,
    required String church,
  }) async {
    socket.emit('chat message', {
      'uniqueId': uniqueId,
      'message': message,
      'sender': sender,
      'senderId': senderId,
      'time': time,
      'church': church,
    });
  }

  Future<void> deleteMessage(String uniqueId, String messageId) async {
    socket.emit('delete message', {
      'uniqueId': uniqueId,
      'messageId': messageId,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
