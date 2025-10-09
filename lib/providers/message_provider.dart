import 'dart:async';

import 'package:flutter/material.dart';
import 'package:master/Model/message_model.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  final StreamController<List<MessageModel>> _messagesStreamController = 
      StreamController<List<MessageModel>>.broadcast();
  
  List<MessageModel> get messages => _messages;
  Stream<List<MessageModel>> get messagesStream => _messagesStreamController.stream;

  void init() {
    _messages = [];
    _messagesStreamController.add(_messages);
    notifyListeners();
  }

  void clear() {
    _messages = [];
    _messagesStreamController.add(_messages);
    notifyListeners();
  }

  void addMessages(List<MessageModel> newMessages) {
    // Sort messages by time when adding multiple messages
    newMessages.sort((a, b) {
      final timeA = DateTime.parse(a.time ?? DateTime.now().toIso8601String());
      final timeB = DateTime.parse(b.time ?? DateTime.now().toIso8601String());
      return timeA.compareTo(timeB);
    });

    this._messages = newMessages;
    _messagesStreamController.add(_messages);
    notifyListeners();
  }

  Future<void> addMessage(MessageModel message) async {

    // Check if message already exists
    bool exists = _messages.any((m) => m.id == message.id);
    if (exists) {
      return; // Exit early, don't add duplicate
    }

    _messages.add(message);

    // Sort messages after adding new message
    _messages.sort((a, b) {
      final timeA = DateTime.tryParse(a.time ?? '') ?? DateTime.now();
      final timeB = DateTime.tryParse(b.time ?? '') ?? DateTime.now();
      return timeA.compareTo(timeB);
    });


    // Update messages list
    this._messages = _messages;
    _messagesStreamController.add(_messages);

    // Notify listeners after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void removeMessage(String? messageId) {
    _messages.removeWhere((message) => message.id == messageId);
    _messagesStreamController.add(_messages);
    notifyListeners();
  }

  // Optional: Getter for sorted messages (if you need both sorted and unsorted versions)
  List<MessageModel> get sortedMessages {
    List<MessageModel> sortedList = List.from(_messages);
    sortedList.sort((a, b) {
      final timeA = DateTime.parse(a.time ?? DateTime.now().toIso8601String());
      final timeB = DateTime.parse(b.time ?? DateTime.now().toIso8601String());
      return timeA.compareTo(timeB);
    });
    return sortedList;
  }

  // Don't forget to close the stream controller when done
  void dispose() {
    _messagesStreamController.close();
    super.dispose();
  }
}