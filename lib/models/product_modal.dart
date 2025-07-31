import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../util/functions_for_cloud.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/url_provider.dart';
import 'package:provider/provider.dart';



class Products {
  String? title;
  String? description;
  String? duration;
  String? productImage;
  XFile? imageFromPicker;
  String? category;
  Color? selectedColor;
  String? price;


  Products({this.title, this.description,this.duration,this.productImage,this.category,this.price});


// Upload to data base

  Future<String> uploadProduct(Products products,imageFromPicker,selectedOption) async {
    try {
      String productImage =
      await uploadImageToFirebaseStorage(File(imageFromPicker!.path));
      // Provider.of<PostImageUrlProvider>(context, listen: false).imageUrl =
      //     postImageUrl;
      // debugPrint("this is it :" + postImageUrl);

      DocumentReference postRef =
      await FirebaseFirestore.instance.collection("Products").doc(selectedOption!,).collection("Item").add({
        'title': products.title,
        'description': products.description,
        'duration': products.duration,
        'productImage': productImage,
        'category': products.category,
        'price': products.price,

      });

      final newPostKey = postRef.id;

      print('Post added to Firestore successfully! ${newPostKey}');

      return newPostKey;
    } catch (e) {
      print('$e');
      return "";
    }
  }



}