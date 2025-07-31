import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../cards/prayer_card.dart';
import '../componants/buttonChip.dart';

class Completed extends StatefulWidget {
  const Completed(
      {this.clientName,
      this.productName,
      this.date,
      this.description,
      this.duration,
      this.productImage,
      this.profileImage,
      this.price,
        this.onPressedCall,
        this.onPressedChat,
      super.key});

  final String? clientName;
  final String? productName;
  final String? date;
  final String? description;
  final String? duration;
  final String? profileImage;
  final String? productImage;
  final String? price;
  final VoidCallback? onPressedCall;
  final VoidCallback? onPressedChat;

  @override
  State<Completed> createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  List<Widget> completedCared = [];

  @override
  Widget build(BuildContext context) {
    return PrayerCard(
      cornerText: 'Completed',
      cornerColor: Colors.blue,
      clientName: widget.clientName ?? "",
      productName: widget.productName ?? "",
      duration: widget.duration ?? "",
      description: widget.description ?? "",
      date: widget.date ?? "",
      productImage: widget.productImage,
      profileImage: widget.profileImage,
      price: widget.price,
      onPressedCall: widget.onPressedCall ?? (){},
      onPressedChat: widget.onPressedChat ?? (){},

      buttonChoice: NewButton(
        inSideChip: 'View Details',
        where: (){
          Alert(
            context: context,
            type: AlertType.info,
            title: "Completed",
            desc: "Booking was succesfuly completed",
            buttons: [
              DialogButton(
                child: Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        },
      ),
    );
  }
}
