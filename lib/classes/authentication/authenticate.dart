import 'package:appwrite/models.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';
import 'package:flutter/material.dart';
import 'package:master/providers/registration_provider.dart';
import 'package:master/providers/user_data_provider.dart';
import 'package:master/services/api/auth_service.dart';
import 'package:master/services/api/user_service.dart';
import 'package:master/util/alerts.dart';

import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../providers/url_provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'otp_auth.dart';

class Authenticate {
  String? selectedGender;
  ChurchItemModel? selectedChurch;
  String role = "";
  String churchCode = "";
  String churchId = "";
  List<String> churchList = [];

  SqlDatabase sql = SqlDatabase();
  // AppWriteDataBase connect = AppWriteDataBase();
  SupabaseClient supabase = Supabase.instance.client;
  OtpAuth _otpAuth = OtpAuth();

  Future<List<String>> getChurchList(BuildContext context) async {
    try {
      final churchs = await supabase.from("Church").select("ChurchName");
      for (var church in churchs) {
        final name = church["ChurchName"];
        churchList.add(name);
      }
      return churchList;
    } catch (error) {
      alertReturn(context, "Empty Church List");
      return [];
    }
  }

  void getChurchCode(BuildContext context, String selectedChurch) async {
    try {
      final church = await supabase
          .from("Church")
          .select("ChurchId")
          .eq('ChurchName', selectedChurch)
          .single();

      churchId = church["ChurchId"];
    } catch (error) {
      alertReturn(context, "Problem with Selected Church");
    }
  }

  // void endSession() async {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final result = await connect.account.deleteSessions();
  //     print(result);
  //   });
  // }

  Widget dropDownMenu(BuildContext context, List<String> items,
      Function(void Function()) setState) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Select Gender',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: items
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          value: selectedGender,
          onChanged: (String? value) {
            setState(() {
              selectedGender = value;

              Provider.of<RegistrationProvider>(context, listen: false)
                  .registrationModel
                  .gender = value;

              context
                  .read<SelectedGenderProvider>()
                  .updateGender(newValue: selectedGender!);
            });
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: 160,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }

  Widget dropSearch(BuildContext context, List<ChurchItemModel> churches,
      Function(void Function()) setState, TextEditingController controller) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<ChurchItemModel>(
          isExpanded: true,
          hint: Text(
            'Select Church',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: churches
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item.churchName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          value: selectedChurch,
          onChanged: (value) {
            setState(() {
              selectedChurch = value;
            });

            context
                .read<RegistrationProvider>()
                .updateRegistration(uniqueChurchId: selectedChurch?.uniqueId);

            Provider.of<SelectedChurchProvider>(context, listen: false)
                .updateSelectedChurch(newValue: selectedChurch!);
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: 160,
          ),
          dropdownStyleData: const DropdownStyleData(
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: controller,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: 'Search for a Church...',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return item.value.toString().contains(searchValue);
            },
          ),
          //This to clear the search value when you close the menu
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              controller.clear();
            }
          },
        ),
      ),
    );
  }

  static Future<void> submitCode(BuildContext context, String code) async {
    String userId = Provider.of<tockenProvider>(context, listen: false).tocken;

    String? phoneNumber =
        Provider.of<RegistrationProvider>(context, listen: false)
            .registrationModel
            .phoneNumber;
    String? userName = Provider.of<RegistrationProvider>(context, listen: false)
        .registrationModel
        .userName;
    String? gender = Provider.of<RegistrationProvider>(context, listen: false)
        .registrationModel
        .gender;
    String? selectedChurch =
        Provider.of<SelectedChurchProvider>(context, listen: false)
            .selectedChurch
            .churchName;
    String? role = Provider.of<RegistrationProvider>(context, listen: false)
        .registrationModel
        .role;
    String? uniqueChurchId =
        Provider.of<RegistrationProvider>(context, listen: false)
            .registrationModel
            .uniqueChurchId;

    try {
      bool result = await AuthService.verifyOtp(
          phoneNumber ?? '',
          code,
          userName ?? '',
          gender ?? '',
          selectedChurch ?? '',
          role ?? '',
          uniqueChurchId ?? '');

      if (result) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutePaths.church,
          (Route<dynamic> route) => false,
        );
      } else {
        alertReturn(context, 'Somethings wrong with your code');
      }
    } catch (error) {
      alertReturn(context, 'Somethings wrong with your code');
    }
  }

  void signOut() async {
    // await connect.account.deleteSessions();
    // print("Session Refreshed");
  }

  static Future<void> authenticate(BuildContext context) async {
    try {
      final registrationData =
          context.read<RegistrationProvider>().registrationModel;

      final existingUser = await UserService.userExist(
          registrationData.phoneNumber!, registrationData.uniqueChurchId!);

      if (existingUser != null) {
      
          // if (registrationData.role == Role.admin) {
          //   final isPasswordValid = await AuthService.checkPassword(
          //       registrationData.password!, registrationData.uniqueChurchId!);

          //   if (!isPasswordValid) {
          //     alertReturn(context, "Wrong Password");
          //     return;
          //   }
          // }

          if (await AuthService.sendOtp(registrationData.phoneNumber!)) {
            Navigator.pushNamed(context, RoutePaths.code);
          }

      } else {
        if (registrationData.role == Role.admin) {
          final isPasswordValid = await AuthService.checkPassword(
              registrationData.password!, registrationData.uniqueChurchId!);

          if (!isPasswordValid) {
            alertReturn(context, "Wrong Password");
            return;
          }
        }

        if (await AuthService.sendOtp(registrationData.phoneNumber!)) {
          Navigator.pushNamed(context, RoutePaths.code);
        }
      }
    } catch (error) {
      alertReturn(context, "Problem with Number ${error}");
    }
  }

  static Future<List<ExistingUser>?> getUserFromPhoneNumber(
      String phoneNumber) async {
    return await UserService.getUserFromPhoneNumber(phoneNumber);
  }

  Future<String> numberCheck(context, String num) async {
    int length = num.length;

    if (length < 10 || length > 10) {
      alertReturn(context, "Your Phone Number must be 10 Numbers");
      return '';
    } else {
      var result = num.substring(1);

      return result;
    }
  }
}
