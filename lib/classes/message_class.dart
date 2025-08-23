import 'package:flutter/material.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/Model/user_details_model.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/utils/user_details_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../componants/global_booking.dart';
import '../databases/database.dart';
import '../providers/url_provider.dart';

class MessageClass {
  Map<String, dynamic> currentUser = {};
  Stream? listen;

  Stream load(BuildContext context) {
    return supabase
        .from('Message')
        .stream(primaryKey: ['id'])
        .eq(
            'Church',
            Provider.of<christProvider>(context, listen: false).myMap['Project']
                ?['ChurchName'])
        .order('id', ascending: false);
  }

  void calling(BuildContext context, Function(void Function()) setState) {
    final calz = load(context);
    setState(() {
      listen = calz;
    });
  }

  Future<Map<String, dynamic>> getCurrentUser(BuildContext context) async {
    UserDetails? user = await UserDetailsService.getUserDetailsData();

    try {
      Map<String, dynamic> userData = {
        "UserName": user?.userName,
        "UserId": user?.userId,
        "PhoneNumber": user?.phoneNumber,
        'ProfileImage': user?.profileImage
      };

      currentUserImage(context, user?.phoneNumber ?? '');

      return userData;
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<void> currentUserImage(BuildContext context, String number) async {
    final item = await supabase
        .from('User')
        .select('ProfileImage')
        .eq('PhoneNumber', number)
        .single();

    final image = item['ProfileImage'];

    context
        .read<CurrentUserImageProvider>()
        .updatecCurrentRoomId(newValue: image);
  }

  void userInit(
      Function(void Function()) setState, BuildContext context) async {
    final user = await getCurrentUser(context);
    if (user != null) {
      setState(() {
        currentUser = user;
      });

      print('currentUser $currentUser');
    } else {
      print('User is null');
    }
  }

  Stream<dynamic> listining2() {
    return supabase.from('Message').stream(primaryKey: ['id']);
  }

  final supabase = Supabase.instance.client;

  List<String> items = [];

  Future sendMessage(
      BuildContext context,
      String sender,
      String senderId,
      String message,
      String id,
      String profileImage,
      String number,
      Function(void Function()) setState) async {
    var uuid = Uuid();
    var docId = uuid.v1();
    try {
      await supabase.from('Message').insert({
        'Sender': sender,
        'SenderId': "blank",
        'ChatRoomId': "blank",
        'Message': message,
        'ProfileImage': profileImage,
        'DocId': "blank",
        'Status': 'Unread',
        'Time': DateTime.now().toIso8601String(),
        'PhoneNumber': number,
        'Church': Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['ChurchName'] ??
            ""
      });

      print("Sent Message");
      setState(() {});
    } catch (error) {
      print('This is the eror : $error');
    }
  }
}
