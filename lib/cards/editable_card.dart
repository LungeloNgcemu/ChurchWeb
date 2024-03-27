import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:master/componants/buttonChip.dart';

bool isSelected = false;

class EditableProductCard extends StatefulWidget {
  EditableProductCard({
    this.title,
    this.description,
    this.duration,
    this.image,
    this.tag,
    this.where,
    this.price,
    super.key,
  });

  final Color? tag;
  final String? image;
  final String? title;
  final String? description;
  final String? duration;
  final VoidCallback? where;
  final String? price;

  @override
  State<EditableProductCard> createState() => _EditableProductCardState();
}

class _EditableProductCardState extends State<EditableProductCard> {
  final ImagePicker _picker = ImagePicker();
  XFile? _productImage; // Change PickedFile to XFile

  Future<void> _productPickImage() async {
    _productImage =
        await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }

  void sheeting2() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 9200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal BottomSheet'),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: widget.image! ?? "",
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  height: 40.0,
                                  width: 40.0,
                                  child: CircularProgressIndicator(
                                    value: 1.0,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                              //height: 250,
                              //width: double.maxFinite,
                            ),
                          ),
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 10,
                            child: Text(
                               widget.title!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15.0),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Icon(Icons.bookmark_add_rounded,
                                color: widget.tag ?? Colors.black),
                          ),
                        ],
                      ),
                      Text(
                          widget.description! ??
                              "", style: TextStyle(fontSize: 11.0, color: Colors.grey),),

                      Row(
                        children: [
                          Text(
                            widget.duration!,

                          ),
                        ],
                      ),
                      //drop down meanu needed for this...
                      Row(
                        children: [
                          Text(
                            'R ${widget.price} '?? "0.00",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: NewButton(
                              inSideChip: 'Book for Client',
                              where: widget.where ?? (){},
                            ),
                          ),
                        ],
                      )
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: OutlinedButton(
                      //     //color: Colors.red,
                      //     onPressed: () {
                      //       setState(() {
                      //         isSelected = !isSelected;
                      //         Navigator.pushNamed(context, '/booking');
                      //       });
                      //       // _showBookingConfirmation(widget.inchip);
                      //     },
                      //
                      //     style: OutlinedButton.styleFrom(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 8.0, vertical: 4.0),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(20.0),
                      //       ),
                      //       backgroundColor: Colors.white,
                      //       side: const BorderSide(
                      //         color: Colors.red,
                      //         width: 2.0,
                      //       ),
                      //     ),
                      //     child: const Padding(
                      //       padding: EdgeInsets.all(4.0),
                      //       child: Text(
                      //         'Create Product',
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
