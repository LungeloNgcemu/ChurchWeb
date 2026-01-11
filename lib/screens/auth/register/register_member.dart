import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/church_detail_model.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/componants/multi_church_select.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';
import 'package:master/providers/registration_provider.dart';
import 'package:master/screens/profile/profile_screen.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/general_data_service.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/extrabutton.dart';
import '../../../classes/authentication/authenticate.dart';
import '../otp/code.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RegisterMember extends StatefulWidget {
  const RegisterMember({super.key});

  @override
  State<RegisterMember> createState() => _RegisterMemberState();
}

class _RegisterMemberState extends State<RegisterMember> {
  Authenticate auth = Authenticate();
  Restrictions restrict = Restrictions();
  List<ChurchItemModel> names_of_churches = [];
  SqlDatabase sql = SqlDatabase();

  @override
  void initState() {
    churchListInit(context);
    auth.role = "Member";
    // TODO: implement initState
    super.initState();
  }

  Future<void> churchListInit(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final List<ChurchItemModel> list = await GeneralDataService.getChurches();

    setState(() {
      names_of_churches = list;
    });

    print(names_of_churches);

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  String userName = '';
  String number = '';

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerNumber = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerCode = TextEditingController();

  bool isLoading = false;
  String num = '';

  final TextEditingController churchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                constraints: BoxConstraints(minHeight: h),

                //  color: Colors.grey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        //animate this text
                        child: Container(
                          alignment: Alignment.center,
                          height: 200,
                          child: Center(
                            child: DefaultTextStyle(
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'racingSansOne'),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText('Login'),
                                  TypewriterAnimatedText('Welcome Beloved'),
                                  TypewriterAnimatedText(
                                      'Please Enter Your Mobile Number...'),
                                ],
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                          ),
                        )),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0,
                                  top: 30.0,
                                  left: 10.0,
                                  right: 10.0),
                              child: IntlPhoneField(
                                decoration: const InputDecoration(
                                  isDense: true,
                                  // Added this
                                  contentPadding: EdgeInsets.all(8),

                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  labelText: 'Phone Number',
                                  hintText: 'Phone Number',
                                ),
                                initialCountryCode: 'ZA', // South Africa
                                onChanged: (phone) {
                                  Provider.of<RegistrationProvider>(context,
                                          listen: false)
                                      .registrationModel
                                      .phoneNumber = phone.completeNumber;

                                  number = phone.completeNumber;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ExtraButton(
                      skip: () async {
                        if (number != '') {
                          List<ExistingUser>? users =
                              await Authenticate.getUserFromPhoneNumber(number);

                          if (users != null) {
                            if (users.isEmpty) {
                              alertReturn(context,
                                  'Your Number is not linked to any church');

                              setState(() {
                                isLoading = false;
                              });

                              return;
                            }

                            if (users.length > 1) {
                              final selectedUser = await showChurchSelectDialog(
                                  context, users, (user) {
                                Navigator.pop(context, user);
                              });

                              if (selectedUser?.role == Role.admin) {
                                bool? isPasswordValid = await showAdminDialog(
                                    context,
                                    TextEditingController(),
                                    selectedUser!.uniqueChurchId!);

                                if (isPasswordValid == null) {
                                  return;
                                }

                                if (!isPasswordValid) {
                                  alertReturn(context, "Wrong Password");
                                  return;
                                }
                              }

                              if (selectedUser != null) {
                                //Assign the user to the provider
                                Provider.of<RegistrationProvider>(context,
                                            listen: false)
                                        .registrationModel
                                        .uniqueChurchId =
                                    selectedUser.uniqueChurchId;

                                Provider.of<RegistrationProvider>(context,
                                        listen: false)
                                    .registrationModel
                                    .role = selectedUser.role;

                                ChurchItemModel? churchItemModel =
                                    await GeneralDataService
                                        .getChurchItemModelByUniqueId(
                                            selectedUser.uniqueChurchId!);

                                if (churchItemModel != null) {
                                  await SqlDatabase.insertChurcItem(
                                      churchItem: churchItemModel);
                                } else {
                                  alertReturn(context, 'Church Not Found');
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                await Authenticate.authenticate(context);

                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } else {
                              setState(() {
                                isLoading = true;
                              });

                              //Assign the user to the provider
                              Provider.of<RegistrationProvider>(context,
                                      listen: false)
                                  .registrationModel
                                  .uniqueChurchId = users.first.uniqueChurchId;

                              Provider.of<RegistrationProvider>(context,
                                      listen: false)
                                  .registrationModel
                                  .role = users.first.role;

                              if (users.first.role == Role.admin) {
                                bool? isPasswordValid = await showAdminDialog(
                                    context,
                                    TextEditingController(),
                                    users.first.uniqueChurchId!);

                                if (isPasswordValid == null) {
                                  return;
                                }

                                if (!isPasswordValid) {
                                  alertReturn(context, "Wrong Password");
                                  return;
                                }
                              }

                              ChurchItemModel? churchItemModel =
                                  await GeneralDataService
                                      .getChurchItemModelByUniqueId(
                                          users.first.uniqueChurchId!);

                              if (churchItemModel != null) {
                                await SqlDatabase.insertChurcItem(
                                    churchItem: churchItemModel);
                              } else {
                                alertReturn(context, 'Church Not Found');
                              }

                              await Authenticate.authenticate(context);

                              setState(() {
                                isLoading = false;
                              });
                            }
                          } else {
                            alertReturn(context, 'User Not Found');
                          }
                        } else {
                          alertReturn(context, 'Please add a phone number');
                        }
                      },
                      writing2: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  // Semi-transparent overlay
                  child: const Center(
                    child: SizedBox(
                      // height: 100.0,
                      // width: 100.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
