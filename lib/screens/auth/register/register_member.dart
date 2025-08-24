import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
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

  final List<String> items = [
    'Male',
    'Female',
  ];

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
                          ///color: Colors.deepOrange,
                          height: 200,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 50.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'racingSansOne'),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText('Welcome Beloved'),
                                TypewriterAnimatedText(
                                    'Please Enter Your Details Below...'),
                              ],
                              onTap: () {
                                print("Tap Event");
                              },
                            ),
                          ),
                        )),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Column(
                              children: [
                                InputAppwrite(
                                  keyboard: TextInputType.text,
                                  //  message: 'Enter Name',
                                  controller: controllerName,
                                  label: 'Name',
                                  text: 'Name',
                                  onChanged: (value) {
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
                                initialCountryCode: '+27',
                                onChanged: (phone) {
                                  print(phone.completeNumber);
                                  number = phone.completeNumber;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    //Search for church here...
                    ExtraButton(
                      skip: () async {
                        
                        Provider.of<RegistrationProvider>(context,
                                listen: false)
                            .registrationModel
                            .role = "Member";

                        final registrationData =
                            Provider.of<RegistrationProvider>(context,
                                    listen: false)
                                .registrationModel;

                        final selectedChurch =
                            Provider.of<SelectedChurchProvider>(context,
                                    listen: false)
                                .selectedChurch;

                        if (registrationData.uniqueChurchId != null &&
                            registrationData.uniqueChurchId != "") {
                          setState(() {
                            isLoading = true;
                          });

                          SqlDatabase.insertChurcItem(
                              churchItem: selectedChurch);

                          if (number != '') {
                            final canAdd =
                                await Restrictions.restrictionAlgorithm(
                                    number: number,
                                    selectedChurch: selectedChurch);

                            if (canAdd) {
                              Authenticate.authenticate(context);

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  controllerName.clear();
                                  controllerNumber.clear();
                                });
                              });
                            } else {
                              //alert;
                              const message =
                                  "The church plan is currently full, please contact the church owner to increse plan ";
                              alertReturn(context, message);
                            }
                          } else {
                            alertReturn(context, 'Please add a phone number');
                          }

                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              num = '';
                              number = '';
                              isLoading = false;
                            });
                          });
                        } else {
                          alertReturn(context, "Please select a church");
                        }
                      },

                      // skip: () async {
                      //   num = await  auth.numberCheck(this,number);

                      //   setState(() {
                      //     isLoading = true;
                      //   });
                      //   auth.createPhoneAccount1(context,num, userName,auth.role);
                      //   //Navigator.pushNamed(context, '/code');

                      //   Future.delayed(Duration(seconds: 3), () {
                      //     setState(() {
                      //       controllerName.clear();
                      //       controllerNumber.clear();
                      //       isLoading = false;
                      //       num = '';
                      //       number = '';
                      //     });
                      //   });
                      // },
                      writing2: const Text(
                        'Register/Login',
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
