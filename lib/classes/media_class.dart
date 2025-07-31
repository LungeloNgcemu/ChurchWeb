
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../componants/global_booking.dart';
import '../providers/url_provider.dart';


class MediaClass {

  bool isLoading = false;

  Future<void> superbaseMedia(title, description, category, url,
      BuildContext context) async {

    print('Inserting Youtube');

    await supabase.from('Media').insert({
      'Title': title.toString(),
      'Description': description.toString(),
      'Category': category.toString(),
      'URL': url.toString(),
      'Church': Provider.of<christProvider>(context, listen: false)
          .myMap['Project']?['ChurchName'] ??
          ""

    });
  }

}
