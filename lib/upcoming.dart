import 'package:flutter/material.dart';
import 'cards/cardBook.dart';
import 'componants/buttonChip.dart';

class UpComing extends StatefulWidget {
  UpComing(
      {this.clientName,
      this.productName,
      this.date,
      this.description,
      this.duration,
      this.productImage,
      this.profileImage,
      this.price,
      this.cancelBooking,
      this.completeBooking,
      this.slotTime,
      this.onPressedChat,
      this.onPressedCall,
      super.key});

  final String? clientName;
  final String? productName;
  final String? date;
  final String? description;
  final String? duration;
  final String? profileImage;
  final String? productImage;
  final String? price;
  final VoidCallback? cancelBooking;
  final VoidCallback? completeBooking;
  final String? slotTime;
  final VoidCallback? onPressedChat;
  final VoidCallback? onPressedCall;

  @override
  State<UpComing> createState() => _UpComingState();
}

class _UpComingState extends State<UpComing> {
  List<Widget> upcomingCared = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return CardBooked(
      cornerColor: Colors.green,
      cornerText: 'Up coming',
      clientName: widget.clientName ?? "",
      productName: widget.productName ?? "",
      duration: widget.duration ?? "",
      description: widget.description ?? "",
      date: widget.date ?? "",
      productImage: widget.productImage,
      profileImage: widget.profileImage,
      price: widget.price,
      slotTime: widget.slotTime,
      onPressedCall: widget.onPressedCall ?? () {},
      onPressedChat: widget.onPressedChat ?? () {},
      buttonChoice: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: NewButton(
                inSideChip: 'Cancel booking',
                where: widget.cancelBooking ?? () {},
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: NewButton(
                inSideChip: 'Complete',
                where: widget.completeBooking ?? () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ListView.builder(
// reverse: true,
// itemCount: upcomingCared.length,
// itemBuilder: (context, index) {
// return CommentBubble(lastComment: comments[index]);
// //Text('Angela: ${comments[index]}');
// }),;

//.colorizedBracketPairs
