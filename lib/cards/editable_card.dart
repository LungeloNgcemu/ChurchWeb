import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

bool isSelected = false;

class EditableProductCard extends StatefulWidget {
  const EditableProductCard({
    this.tag,
    super.key,
  });
  final Color? tag;

  @override
  State<EditableProductCard> createState() => _EditableProductCardState();
}

class _EditableProductCardState extends State<EditableProductCard> {
  final ImagePicker _picker = ImagePicker();
  XFile? _productImage; // Change PickedFile to XFile

  Future<void> _productPickImage() async {
    _productImage = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 30.0,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0.1,
                blurRadius: 10.0,
              )
            ]),
        height: 180.0,
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          height: 160.0,
                          width: double.maxFinite,
                        ),
                      ),
                      Positioned(
                        top: 150.0,
                        left: 5.0,
                        child: GestureDetector(
                          onTap: () {
                           _productPickImage();
                           debugPrint("taped");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.orange,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(1.0),
                              child: Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/create');
                          },
                          child: const Text(
                            ' Create Descriptions',
                          ),
                        ),
                        Icon(
                          Icons.bookmark_add_rounded,
                          color: widget.tag ?? Colors.white,
                        )
                      ],
                    ),
                    const Text(
                        'This is where we can describe the product and tell the client all they need to know. '),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton(
                        //color: Colors.red,
                        onPressed: () {
                          setState(() {
                            isSelected = !isSelected;
                            Navigator.pushNamed(context, '/booking');
                          });
                          // _showBookingConfirmation(widget.inchip);
                        },

                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            'Create Product',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
