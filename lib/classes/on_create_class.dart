import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';

class CreateClass {
  Future<void> sheeting(
    BuildContext context,
    Widget screen,
  ) async {
    try {
      showFlexibleBottomSheet(
        minHeight: 0,
        initHeight: 0.8,
        maxHeight: 0.8,
        context: context,
        // Pass the screen directly — it's a Scaffold with its own scroll view.
        // Wrapping in SingleChildScrollView would give unbounded constraints to
        // a Scaffold, which cannot size itself and renders blank.
        builder: (context, scrollController, bottomSheetOffset) => screen,
        isExpand: true,
        bottomSheetBorderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        bottomSheetColor: Colors.white,
      );
    } catch (error) {
      print("Bottom sheet error : $error");
    }
  }
}
