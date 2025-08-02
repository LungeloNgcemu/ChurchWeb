import 'package:flutter/material.dart';
import 'dart:io';
import 'comment_model.dart';

class Post {
  String? title;
  String description;
  String imageUrl;
  String? postId; // Change postKey to postId

  Post({
    this.title,
    required this.description,
    required this.imageUrl,
    this.postId, // Change postKey to postId
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'postId': postId, // Change postKey to postId
    };
  }

  factory Post.fromMap(String key, Map<dynamic, dynamic>? map) {
    if (map == null) {
      // Handle the case where map is null (e.g., return a default Post object)
      return Post(description: '', imageUrl: '', postId: ''); // Change postKey to postId
    }

    return Post(
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      postId: map['postId'], // Change postKey to postId
    );
  }
}

