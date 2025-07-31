import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';


class CreateClass {


  void sheeting(BuildContext context, Widget screen,) {


    try {
      Widget buildBottomSheet(BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,) {
        return SingleChildScrollView(
            controller: scrollController,
            child: screen,
        );
      }



      showFlexibleBottomSheet(
  
        minHeight: 0,
        initHeight: 0.8,
        maxHeight: 0.8,
        context: context,
        builder: (context, scrollController, bottomSheetOffset) => buildBottomSheet(context, scrollController, bottomSheetOffset),
        isExpand: true,
        bottomSheetBorderRadius:const BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        bottomSheetColor: Colors.white,

      );
    } catch (error) {

      print("Bottom sheet error : $error");
    }
  }

}