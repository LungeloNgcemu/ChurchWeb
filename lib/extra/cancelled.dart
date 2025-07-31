import 'package:flutter/material.dart';
import 'package:master/cards/prayer_card.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../componants/buttonChip.dart';

class Cancelled extends StatefulWidget {
  Cancelled({this.clientName,this.productName,this.date,this.description,this.duration,this.productImage,this.profileImage,this.price,this.onPressedCall,this.onPressedChat,this.cornerText, super.key});

  final String? clientName;
  final String? productName;
  final String? date;
  final String? description;
  final String? duration;
  final String? profileImage;
  final String? productImage;
  final String? price;
  final String? cornerText;
  final VoidCallback? onPressedCall;
  final VoidCallback? onPressedChat;


  @override
  State<Cancelled> createState() => _CancelledState();
}

class _CancelledState extends State<Cancelled> {
  List<Widget> canceledCared = [];

  @override
  Widget build(BuildContext context) {
    return PrayerCard(
      cornerColor: Colors.purple,
      cornerText: widget.cornerText ?? "",
      clientName: widget.clientName ?? "",
      productName: widget.productName ?? "",
      duration: widget.duration ?? "",
      description: widget.description ?? "",
      date:  widget.date ?? "" ,
      productImage: widget.productImage,
      profileImage: widget.profileImage,
      price: widget.price,
      onPressedCall: widget.onPressedCall ?? (){},
      onPressedChat: widget.onPressedChat ?? (){},
      // buttonChoice: NewButton(
      //   inSideChip: 'Prayer Complete',
      //   where: (){
      //     Alert(
      //       context: context,
      //       type: AlertType.info,
      //       title: "Cancelled",
      //       desc: "Booking was succesfuly canceled",
      //       buttons: [
      //         DialogButton(
      //           child: Text(
      //             "Done",
      //             style: TextStyle(color: Colors.white, fontSize: 20),
      //           ),
      //           onPressed: () => Navigator.pop(context),
      //           width: 120,
      //         )
      //       ],
      //     ).show();
      //   },
      // ),
    );
  }
}
