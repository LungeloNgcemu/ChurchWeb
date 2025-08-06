// import 'package:animated_snack_bar/animated_snack_bar.dart';
// import 'package:flutter/Material.dart';
// import 'package:master/componants/extrabutton.dart';

// notificationSnackBar(String title, String body, BuildContext context) {
//   return AnimatedSnackBar(
//     duration: Duration(seconds: 3),
//     builder: ((context) {
//       return Column(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color.fromARGB(128, 0, 0, 0)!, // Shadow color
//                     offset: Offset(0, 4), // Horizontal and vertical offset
//                     blurRadius: 8, // Blur radius
//                     spreadRadius: 2, // Optional: How much the shadow spreads
//                   ),
//                 ],
//                 borderRadius: BorderRadius.circular(10.0)),
//             padding: const EdgeInsets.all(8),
//             height: 100,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Image.asset(
//                   "lib/images/clear.png",
//                   height: 100.0,
//                   width: 100.0,
//                 ),
//                 Text(
//                   title,
//                   softWrap: true,
//                   style: const TextStyle(fontSize: 15),
//                 ),
//                 Text(body),
//               ],
//             ),
//           ),
//           ExtraButton(
//               color: Colors.red,
//               writing2: const Text(
//                 "Update",
//                 style: TextStyle(color: Colors.white, fontSize: 15),
//               ),
//               skip: () async {}),
//         ],
//       );
//     }),
//   ).show(context);
// }
