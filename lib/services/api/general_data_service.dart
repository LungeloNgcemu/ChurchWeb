import 'dart:convert';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/constants/constants.dart';
import 'package:http/http.dart' as http;

class GeneralDataService {

 static  Future<List<ChurchItemModel>> getChurches() async {
    final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/api/baseData/getChurches'));

    if (response.statusCode == 200) {
      var result = json.decode(response.body) as List;

      List<ChurchItemModel> churches =
          result.map((e) => ChurchItemModel.fromJson(e)).toList();

      return churches;
    } else {
      return [];
    }
  }
}
