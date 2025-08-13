import 'package:flutter/material.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<bool?> alertReturn(BuildContext context, String message) {
  return Alert(
    context: context,
    type: AlertType.error,
    title: "ALERT",
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          "Ok",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}

Future<bool?> alertWelcome(BuildContext context, String message) {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    // type: AlertType.info,
    // title: "Welcome",
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          "Enter",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}

Future<bool?> alertDeleteMessage(BuildContext context, String message,
    Future<void> Function() delete) async {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.red,
        onPressed: () async {
          await delete();
          print("deleted message"); // Call the function
          Navigator.of(context).pop(); // Close the dialog
        },
        width: 120,
        child: const Text(
          "Delete",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

Future<bool?> alertDelete(BuildContext context, String message,
    Future<void> Function() delete) async {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.red,
        onPressed: () async {
          await delete();
          print("deleted message"); // Call the function
          Navigator.of(context).pop(); // Close the dialog
        },
        width: 120,
        child: const Text(
          "Delete",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

Future<bool?> alertComplete(BuildContext context, String message) {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    // type: AlertType.info,
    // title: "Welcome",
    desc: message,
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
}

Future<bool?> alertSuccess(BuildContext context, String message) {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    // type: AlertType.info,
    // title: "Welcome",
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.green,
        child: Text(
          "ok",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}

Future<bool?> alertLogout(BuildContext context, String message) async {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.red,
        onPressed: () async {
          ChurchInit church = ChurchInit();
          Navigator.of(context).pop();
          await church.clearProject(context);
          Future.delayed(Duration(seconds: 3), () {});
          Navigator.of(context).pushReplacementNamed(RoutePaths.crossRoad);
        },
        width: 120,
        child: const Text(
          "logout",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

Future<bool?> alertInstall(BuildContext context, String message,
    Future<void> Function() install, Future<void> Function() alreadyInstall) async {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.red,
        onPressed: () async {
          await install();
          Navigator.of(context).pop(); // Close the dialog
        },
        width: 120,
        child: const Text(
          "Install",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      DialogButton(
        color: Colors.red,
        onPressed: () async {
          await alreadyInstall();
          Navigator.of(context).pop(); // Close the dialog
        },
        width: 120,
        child: const Text(
          "Done",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ],
  ).show();
}

Future<bool?> alertIos(
    BuildContext context, String message, Future<void> Function() clear) async {
  return Alert(
    image: Image.asset('lib/images/clear.png'),
    context: context,
    desc: message,
    style: const AlertStyle(
      descStyle: TextStyle(
        fontWeight: FontWeight.w100,
      ),
    ),
    buttons: [
      DialogButton(
        color: Colors.red,
        onPressed: () async {
          await clear();
          Navigator.of(context).pop(); // Close the dialog
        },
        width: 120,
        child: const Text(
          "Ok",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}
