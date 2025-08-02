import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

bool isSelected = false;

class ProductCard extends StatefulWidget {
  final String? title;
  final String? description;
  final String? productImage;
  final String? duration;
  final String? catagory;
  final String? price;

  const ProductCard({
    this.title,
    this.description,
    this.productImage,
    this.duration,
    this.catagory,
    this.tag,
    this.price,
    super.key,
  });

  final Color? tag;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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
                        child: Image.network(
                          widget.productImage ?? "",
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 1.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: Column(
                  //Place for product description
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Text(
                            widget.title ?? "",
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.bookmark_add_rounded,
                          color: widget.tag ?? Colors.black,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            widget.description ?? "",
                            style:
                                TextStyle(color: Colors.black, fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            widget.price ?? "",
                            style:
                                TextStyle(color: Colors.black, fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            widget.duration ?? "",
                            style:
                                TextStyle(color: Colors.black, fontSize: 15.0),
                          ),
                        ],
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

////////////////////////////////////////////////////////////////old

// bool isSelected = false;
//
// class ProductCard extends StatefulWidget {
//   final String? title;
//   final String? description;
//   final String? productImage;
//   final String? duration;
//   final String? catagory;
//
//   const ProductCard({
//     this.title,
//     this.description,
//     this.productImage,
//     this.duration,
//     this.catagory,
//     this.tag,
//     super.key,
//   });
//
//   final Color? tag;
//
//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }
//
// class _ProductCardState extends State<ProductCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(
//         left: 10.0,
//         right: 10.0,
//         top: 30.0,
//       ),
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 0.0),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8.0),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.grey,
//                 spreadRadius: 0.1,
//                 blurRadius: 10.0,
//               )
//             ]),
//         height: 180.0,
//         width: double.maxFinite,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       height: 160.0,
//                       width: double.maxFinite,
//                       child: CachedNetworkImage(
//                         imageUrl:
//                         widget.productImage ?? "",
//                         placeholder: (context, url) => const Center(
//                           child: SizedBox(
//                             height: 40.0,
//                             width: 40.0,
//                             child: CircularProgressIndicator(
//                               value: 1.0,
//                             ),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => Icon(Icons.error),
//                         fit: BoxFit.cover,
//                         //height: 250,
//                         //width: double.maxFinite,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 1,
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                   top: 12.0,
//                   left: 10.0,
//                   right: 10.0,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.title ?? "",
//                           style: const TextStyle(
//                             fontSize: 15.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Icon(
//                           Icons.bookmark_add_rounded,
//                           color: widget.tag ?? Colors.white,
//                         )
//                       ],
//                     ),
//                     Text(
//                       widget.description ?? "",
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: OutlinedButton(
//                         //color: Colors.red,
//                         onPressed: () {
//                           setState(() {
//                             isSelected = !isSelected;
//                             Navigator.pushNamed(context, '/booking');
//                           }); // _showBookingConfirmation(widget.inchip);
//                         },
//
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0, vertical: 4.0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20.0),
//                           ),
//                           backgroundColor: Colors.white,
//                           side: const BorderSide(
//                             color: Colors.red,
//                             width: 2.0,
//                           ),
//                         ),
//                         child: const Padding(
//                           padding: EdgeInsets.all(4.0),
//                           child: Text(
//                             'Available for booking',
//                             style: TextStyle(
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(right: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text(
//                             'Share Product  ',
//                             style: TextStyle(
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Icon(
//                             Icons.share_outlined,
//                             size: 18.0,
//                             color: Colors.blue,
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
