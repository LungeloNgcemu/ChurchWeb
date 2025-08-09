import 'package:appwrite/models.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';
import 'package:flutter/material.dart';
import 'package:master/providers/user_data_provider.dart';
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
  String? selectedChurch;
  String role = "";
  String churchCode = "";
  String churchId = "";
  List<String> churchList = [];

  SqlDatabase sql = SqlDatabase();
  AppWriteDataBase connect = AppWriteDataBase();
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

  void endSession() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await connect.account.deleteSessions();
      print(result);
    });
  }

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

  Widget dropSearch(BuildContext context, List<String> churches,
      Function(void Function()) setState, TextEditingController controller) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
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
                      item,
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
                .read<SelectedChurchProvider>()
                .updateSelectedChurch(newValue: selectedChurch!);

            getChurchCode(context, selectedChurch!);
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

  void submitCode(BuildContext context, String code) async {
    String userId = Provider.of<tockenProvider>(context, listen: false).tocken;

    try {
      final session = await connect.account
          .updatePhoneSession(userId: userId, secret: code);

      if (session != null) {
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

  // void superbaseSubmitCode(
  //     BuildContext context, String number, String code) async {
  //   User? user = await _otpAuth.superbaseVerifyOtpLogin(supabase, number, code);
  //
  //   if (user != null) {
  //     Navigator.of(context).pushNamedAndRemoveUntil(
  //       RoutePaths.church,
  //       (Route<dynamic> route) => false,
  //     );
  //   } else {
  //     alertReturn(context, 'The code entered is invalid');
  //   }
  // }

  Future<void> superbaseOtpLogin(BuildContext context, String number) async {
    await _otpAuth.superbaseOtpLogin(supabase, number);
    Provider.of<UserDataProvider>(context, listen: false)
        .updatePhoneNUmber(number);
  }

  void signOut() async {
    await connect.account.deleteSessions();
    print("Session Refreshed");
  }

  Future<void> superbaseAccountLogin(BuildContext context, String number,
      String name, String role, String gender) async {
    try {
      final phoneNumber = number;

      final existingUser = await supabase
          .from("User")
          .select("UserId, Role")
          .eq('PhoneNumber', phoneNumber)
          .maybeSingle();

      if (existingUser != null) {
        if (role == existingUser["Role"]) {
          await superbaseOtpLogin(context, phoneNumber);
          Navigator.pushNamed(context, RoutePaths.code);
        } else {
          alertReturn(context, "You are in the Wrong Registration screen");
        }
      } else {
        if (role == "Admin" && churchCode != churchId) {
          alertReturn(context, "Wrong Church Code");
          return;
        }

        final userId = Uuid().v6();

        await superbaseOtpLogin(context, phoneNumber);

        await supabase.from("User").insert({
          "UserName": name,
          "UserId": userId,
          'PhoneNumber': phoneNumber,
          'Gender': gender,
          'Church': selectedChurch,
          'Role': role,
        });

        Navigator.pushNamed(context, RoutePaths.code);
      }
    } catch (error) {
      print("Error: $error");
      alertReturn(context, "Problem with Number");
    }
  }

  // Future<void> createPhoneAccount1(BuildContext context, String number,
  //     String name, String role, String gender) async {
  //   try {
  //     final phoneNumber = number;
  //     final existingUser = await supabase
  //         .from("User")
  //         .select("UserId, Role")
  //         .eq('PhoneNumber', phoneNumber)
  //         .single();
  //
  //     final userId =
  //         existingUser != null ? existingUser["UserId"] : Uuid().v6();
  //
  //     final userRole = existingUser["Role"];
  //
  //     if (role == userRole) {
  //       final sessionToken = await connect.account.createPhoneSession(
  //         userId: userId,
  //         phone: phoneNumber,
  //       );
  //
  //       context
  //           .read<tockenProvider>()
  //           .updateTocken(newValue: sessionToken.userId);
  //
  //       if (sessionToken != null) {
  //         Navigator.pushNamed(context, '/code');
  //       }
  //     } else {
  //       alertReturn(context, "You are in the Wrong Registration screen");
  //     }
  //   } catch (error) {
  //     try {
  //       if (role == "Admin") {
  //         if (churchCode == churchId) {
  //           final phoneNumber = number;
  //           final userId = Uuid().v6();
  //
  //           final sessionToken = await connect.account.createPhoneSession(
  //             userId: userId,
  //             phone: phoneNumber,
  //           );
  //
  //           await supabase.from("User").insert({
  //             "UserName": name,
  //             "UserId": userId,
  //             'PhoneNumber': phoneNumber,
  //             'Gender': selectedGender,
  //             'Church': selectedChurch,
  //             'Role': role,
  //             'Gender': gender,
  //           });
  //
  //           context
  //               .read<tockenProvider>()
  //               .updateTocken(newValue: sessionToken.userId);
  //
  //           Navigator.pushNamed(context, '/code');
  //         } else {
  //           //wromg church code
  //
  //           alertReturn(context, "Wrong Church Code");
  //         }
  //       } else {
  //         final phoneNumber = number;
  //         final userId = Uuid().v6();
  //
  //         final sessionToken = await connect.account.createPhoneSession(
  //           userId: userId,
  //           phone: phoneNumber,
  //         );
  //
  //         await supabase.from("User").insert({
  //           "UserName": name,
  //           "UserId": userId,
  //           'PhoneNumber': phoneNumber,
  //           'Gender': selectedGender,
  //           'Church': selectedChurch,
  //           'Role': role,
  //           'Gender': gender,
  //         });
  //
  //         context
  //             .read<tockenProvider>()
  //             .updateTocken(newValue: sessionToken.userId);
  //
  //         Navigator.pushNamed(context, '/code');
  //       }
  //     } catch (e) {
  //       alertReturn(context, "Problem with Number");
  //     }
  //     print(error);
  //   }
  // }

  Future<Token?> createPhoneSession(
    BuildContext context,
    String userId,
    String phoneNumber,
  ) async {
    try {
      final token = await connect.account.createPhoneToken(
        userId: userId,
        phone: phoneNumber,
      );
      return token;
    } catch (error) {
      print("Error creating phone session: $error");
      alertReturn(context, 'Invalid phone number');
      return null;
    }
  }

  Future<void> appwriteAccountOtp(
    BuildContext context,
    String number,
    String name,
    String role,
    String gender,
  ) async {
    try {
      final phoneNumber = number;

      final existingUser = await supabase
          .from("User")
          .select("UserId, Role")
          .eq('PhoneNumber', phoneNumber)
          .maybeSingle();

      if (existingUser != null) {
        if (role == existingUser["Role"]) {
          if (role == "Admin" && churchCode != churchId) {
            alertReturn(context, "Wrong Church Code");
            return;
          }

          final sessionToken = await createPhoneSession(
            context,
            existingUser["UserId"],
            phoneNumber,
          );

          if (sessionToken != null) {
            context
                .read<tockenProvider>()
                .updateTocken(newValue: sessionToken.userId);
            Navigator.pushNamed(context, RoutePaths.code);
          }
        } else {
          alertReturn(context, "You are in the Wrong Registration screen");
        }
      } else {
        if (role == "Admin" && churchCode != churchId) {
          alertReturn(context, "Wrong Church Code");
          return;
        }

        final userId = Uuid().v6();
        final sessionToken =
            await createPhoneSession(context, userId, phoneNumber);

        if (sessionToken != null) {
          await supabase.from("User").insert({
            "UserName": name,
            "UserId": userId,
            'PhoneNumber': phoneNumber,
            'Gender': gender,
            'Church': selectedChurch,
            'Role': role,
          });

          context
              .read<tockenProvider>()
              .updateTocken(newValue: sessionToken.userId);
          Navigator.pushNamed(context, RoutePaths.code);
        }
      }
    } catch (error) {
      print("Error in appwriteAccountOtp: $error");
      alertReturn(context, "Problem with Number");
    }
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
