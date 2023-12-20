import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as fire;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
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

Stream<List<Post>> getPostsFromFirebase() {
  try {
    return FirebaseDatabase.instance
        .ref()
        .child('posts')
        .onValue
        .map((event) {
      final data = (event.snapshot.value as Map<dynamic, dynamic>) ?? {};
      return data.entries
          .map((entry) => Post.fromMap(entry.key, entry.value))
          .toList();
    });
  } catch (e) {
    debugPrint('Error fetching posts from Firebase: $e');
    // Return an empty stream or handle the error accordingly
    return Stream.value([]);
  }
}
// Future<void> addPostToFirebase(Post post) async {
//   try {
//     DatabaseReference reference = FirebaseDatabase.instance.reference().child('posts');
//
//     // Upload image to Firebase Storage and get download URL
//     String imageUrl = await uploadImageToFirebaseStorage(File(post.imageUrl));
//
//     // Add post data to Firebase Realtime Database
//     await reference.push().set({
//       'title': post.title,
//       'description': post.description,
//       'imageUrl': imageUrl,
//     });
//   } catch (e) {
//     print('Error adding post to Firebase: $e');
//   }
// }

// Future<void> addPostToFirebase(Post post) async {
//   try {
//     DatabaseReference reference = FirebaseDatabase.instance.reference().child('posts');
//     await reference.push().set(post.toMap());
//   } catch (e) {
//     print('Error adding post to Firebase: $e');
//   }
// }

// Future<void> addPostToFirebase(Post post) async {
//   try {
//     await FirebaseFirestore.instance.collection('posts').add({
//       'title': post.title,
//       'description': post.description,
//       'imageUrl': post.imageUrl,
//     });
//   } catch (e) {
//     print('Error adding post to Firebase: $e');
//   }
// }
//
// Stream<List<Post>> getPostsFromFirebase() {
//   return FirebaseFirestore.instance
//       .collection('posts')
//       .snapshots()
//       .map((querySnapshot) {
//     return querySnapshot.docs.map((doc) {
//       return Post(
//         description: doc['description'] as String,
//         imageUrl: doc['imageUrl'] as String,
//       );
//     }).toList();
//   });
//
