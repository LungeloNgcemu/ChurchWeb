import 'package:flutter/material.dart';
import 'dart:io';


import 'package:master/providers/url_provider.dart';
import 'package:provider/provider.dart';


class Comment {
  String username;
  String text;
  DateTime timestamp;

  Comment({
    required this.username,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic>? map) {
    return Comment(
      username: map?['username'] ?? 'a',
      text: map?['text'] ?? '',
      timestamp: DateTime.parse(map?['timestamp'] ?? ''),
    );
  }

}