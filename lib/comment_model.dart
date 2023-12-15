import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'poster.dart';

class Comment {
  String username;
  String text;
  DateTime timestamp; // Add this line

  Comment({
    required this.username,
    required this.text,
    required this.timestamp, // Add this line
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'text': text,
      'timestamp': timestamp.toUtc().toIso8601String(), // Adjust this line if needed
    };
  }

  factory Comment.fromMap(Map<Object, dynamic>? map) {
    if (map == null) {
      return Comment(username: '', text: '', timestamp: DateTime.now()); // Adjust this line if needed
    }

    return Comment(
      username: map['username'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  factory Comment.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
    return Comment(
      username: map['username'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

}

class CommentService {
  final DatabaseReference commentsRef =
  FirebaseDatabase.instance.ref().child('comments');

  Stream<List<Comment>> getCommentsStream(String postId) {
    DatabaseReference postRef = commentsRef.child(postId).child('comments');

    return postRef.onValue.map((event) {
      List<Comment> comments = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          comments.add(Comment.fromSnapshot(event.snapshot.child(key)));
        });
      }
      return comments;
    });
  }
}
final DatabaseReference commentsRef = FirebaseDatabase.instance.ref('comments');

void uploadComment(String username, String text, String postKey) {
  Comment newComment = Comment(username: username, text: text, timestamp: DateTime.now());

  final DatabaseReference commentsRef = FirebaseDatabase.instance.ref('posts/$postKey/comments');

  commentsRef.push().set({
    'username': newComment.username,
    'text': newComment.text,
    'timestamp': newComment.timestamp.toUtc().toIso8601String(),
  });
}

DatabaseReference postCommentsRef = FirebaseDatabase.instance.ref().child('posts').child(postKey).child('comments');

Stream<List<Comment>> getCommentsForPost() {
  return postCommentsRef.onValue.map((event) {
    List<Comment> comments = [];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
      map.forEach((key, value) {
        comments.add(Comment.fromSnapshot(event.snapshot.child(key)));
      });
    }
    return comments;
  });
}

