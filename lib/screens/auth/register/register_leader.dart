import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/providers/registration_provider.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/general_data_service.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import '../../../classes/authentication/authenticate.dart';
import '../otp/code.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterLeader extends StatefulWidget {
  const RegisterLeader({super.key});

  @override
  State<RegisterLeader> createState() => _RegisterLeaderState();
}

class _RegisterLeaderState extends State<RegisterLeader> {
  Authenticate auth = Authenticate();
  List<ChurchItemModel> names_of_churches = [];
  Restrictions restrict = Restrictions();
  SqlDatabase sql = SqlDatabase();

  @override
  void initState() {
    // TODO: implement initState

    churchListInit(context);
    auth.role = "Admin";

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
  String countryCode = '';

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerNumber = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerCode = TextEditingController();

  bool isLoading = false;
  String num = '';

  final List<String> items = [
    'Male',
    'Female',
  ];

  TextEditingController churchController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    churchController.dispose();
    super.dispose();
  }

  //TODO auth.churchCode

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(minHeight: h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 50.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'racingSansOne'),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText('Welcome Pastor'),
                              TypewriterAnimatedText(
                                  'Please Enter Your Details Below...'),
                            ],
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Column(
                              children: [
                                InputAppwrite(
                                  controller: controllerName,
                                  label: 'Name',
                                  text: 'Name',
                                  keyboard: TextInputType.text,
                                  onChanged: (value) {
                                    Provider.of<RegistrationProvider>(context,
                                            listen: false)
                                        .registrationModel
                                        .userName = value;
                                    userName = value;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      auth.dropDownMenu(
                                          context, items, setState),
                                      auth.dropSearch(
                                          context,
                                          names_of_churches,
                                          setState,
                                          churchController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 20.0,
                                  top: 20.0),
                              child: Column(
                                children: [
                                  IntlPhoneField(
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(8),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30.0),
                                        ),
                                      ),
                                      labelText: 'Phone Number',
                                      hintText: 'Phone Number',
                                    ),
                                    initialCountryCode: '+27',
                                    onChanged: (phone) {
                                      Provider.of<RegistrationProvider>(context,
                                              listen: false)
                                          .registrationModel
                                          .phoneNumber = phone.completeNumber;

                                      number = phone.completeNumber;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InputAppwrite(
                            message: 'Enter Church Security Code below',
                            controller: codeController,
                            label: 'Security Code',
                            text: 'Security Code',
                            onChanged: (value) {
                              Provider.of<RegistrationProvider>(context,
                                      listen: false)
                                  .registrationModel
                                  .password = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    ExtraButton(
                      skip: () async {
                        Provider.of<RegistrationProvider>(context,
                                listen: false)
                            .registrationModel
                            .role = "Admin";

                        final registrationData =
                            Provider.of<RegistrationProvider>(context,
                                    listen: false)
                                .registrationModel;

                        final selectedChurch =
                            Provider.of<SelectedChurchProvider>(context,
                                    listen: false)
                                .selectedChurch;

                        if (registrationData.uniqueChurchId != "" &&
                            registrationData.uniqueChurchId != null) {
                          setState(() {
                            isLoading = true;
                          });

                          SqlDatabase.insertChurcItem(
                              churchItem: selectedChurch);

                          if (number.isNotEmpty) {
                            print('number $number');
                            final canAdd =
                                await Restrictions.restrictionAlgorithm(
                                    number: number,
                                    selectedChurch: selectedChurch);
                            print('canAdd $canAdd');

                            if (canAdd) {
                              await Authenticate.authenticate(context);

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  controllerName.clear();
                                  controllerNumber.clear();
                                  codeController.clear();
                                });
                              });


                            } else {
                              alertReturn(context,
                                  "The church plan is currently full, please contact the church owner to increse plan ");
                            }
                          } else {
                            alertReturn(context, 'Please add a phone number');
                          }

                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        } else {
                          alertReturn(context, "Please Select a church");
                        }

                        Future.delayed(Duration(seconds: 5), () {
                          setState(() {
                            isLoading = false;
                          });
                        });
                      },
                      writing2: const Text(
                        'Register/Login',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
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
      ),
    );
  }
}

class InputAppwrite extends StatelessWidget {
  InputAppwrite(
      {this.controller,
      this.onChanged,
      this.text,
      this.label,
      this.message,
      super.key,
      this.keyboard});

  TextEditingController? controller;
  Function(String)? onChanged;
  String? label;
  String? text;
  String? message;
  TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
          child: Text(
            message ?? '',
            style: TextStyle(fontSize: 15.0),
          ),
        ),
        ForTextInput(
          controller: controller,
          onChanged: onChanged ?? (String) {},
          label: label,
          text: text,
          keyboard: keyboard ?? TextInputType.text,
        ),
      ],
    );
  }
}
