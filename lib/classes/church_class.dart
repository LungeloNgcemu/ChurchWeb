


import '../componants/global_booking.dart';

class Church {

  String count = '0';


  void superbaseCount(Function(void Function()) setState) async {
    try {
      final user = await connect.account.get();
      final phoneNumber = user.phone;

      //get manager chat list
      final userData = await supabase
          .from('Manager')
          .select('SingleChatId')
          .eq('PhoneNumber', phoneNumber)
          .single();

      var idList = userData['SingleChatId'] ?? [];

      if (idList.isNotEmpty) {
        final documents = await supabase
            .from('Message')
            .select()
            .inFilter('ChatRoomId', idList)
            .eq('Status', "Unread")
            .neq('PhoneNumber', phoneNumber);

        final countx = documents.length;

        setState(() {
          count = countx.toString();
        });
        print(count);
      }
    } catch (error) {
      print(error);
    }
  }

}