import 'dart:convert';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/church_data_model.dart';
import 'package:master/Model/church_detail_model.dart';
import 'package:master/constants/constants.dart';
import 'package:http/http.dart' as http;

class GeneralDataService {
  static Future<List<ChurchItemModel>> getChurches() async {
    final response = await http
        .get(Uri.parse('${BaseUrl.baseUrl}/api/baseData/getChurches'));

    if (response.statusCode == 200) {
      var result = json.decode(response.body) as List;

      List<ChurchItemModel> churches =
          result.map((e) => ChurchItemModel.fromJson(e)).toList();

      return churches;
    } else {
      return [];
    }
  }

  static Future<ChurchItemModel?> getChurchItemModelByUniqueId(String uniqueId) async {
    final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/baseData/getChurchItemModelByChurchId/$uniqueId'));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      return ChurchItemModel.fromJson(result);
    } else {
      return null;
    }
  }

  static Future<ChurchDetailModel?> getChurchData(String uniqueId) async {
    final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/baseData/getChurchData/$uniqueId'));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      return ChurchDetailModel.fromJson(result);
    } else {
      return null;
    }
  }
}
