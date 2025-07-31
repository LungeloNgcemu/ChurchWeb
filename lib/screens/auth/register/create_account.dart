import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/componants/text_input_strip.dart';
import 'package:master/util/alerts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final supabase = Supabase.instance.client;
  Authenticate auth = Authenticate();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();

  // TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();
  TextEditingController controller7 = TextEditingController();
  TextEditingController controller8 = TextEditingController();

  String name = "";
  String churchName = "";
  String vision = "";
  String mission = "";
  String phoneNumber = "";
  String email = "";
  String address = "";
  String password = "";
  String number = '';

  bool churchExist = false;
  bool numberExist = false;
  bool isLoading = false;

  void clearEditor() {
    controller1.clear();
    controller2.clear();
    controller3.clear();
    controller4.clear();
    // controller5.clear();
    controller6.clear();
    controller7.clear();
    controller8.clear();
  }

  Future<void> searchChurchName(churchName) async {
    try {
      final church = await supabase
          .from("Church")
          .select("ChurchName")
          .eq('ChurchName', churchName)
          .single();

      if (!church.isEmpty) {
        setState(() {
          churchExist = true;
        });
      }
    } catch (error) {
      print("Church doesnt exist error");
    }
  }

  Future<void> searchChurcNumber(numberIn) async {
    try {
      final number = await supabase
          .from("Church")
          .select("PhoneNumber")
          .eq('PhoneNumber', numberIn)
          .single();

      if (!number.isEmpty) {
        setState(() {
          numberExist = true;
        });
      }
    } catch (error) {
      print("Church doesnt exist error");
    }
  }

  void supabaseInsert() async {
    try {
      await supabase.from('Church').insert(
        {
          "ChurchUser": name,
          "Email": email,
          "ContactNumber": phoneNumber,
          "ChurchName": churchName,
          "Address": address,
          "About": vision,
          "Read": mission,
          "ChurchId": password,
          // "ChurchUserId": userId
        },
      );
    } catch (error) {
      print("insert error $error");
    }
  }

  void registerChurch({churchName, ChurchNumber}) async {
    await searchChurchName(churchName);

    await searchChurcNumber(ChurchNumber);

    if (churchExist) {
      const message1 =
          "This church name already exist, choose another church name please.";
      alertReturn(context, message1);
    } else {
      if (numberExist) {
        const message2 =
            "This phone number is already registered for another church, please use another number";
        alertReturn(context, message2);
      } else {
        //we can register...

        supabaseInsert();
        const message =
            "Church successfully registerd, Your will be redirected to the Login screen";
        await alertSuccess(context, message);
        clearEditor();
        Navigator.pushNamed(context, "/RegisterLeader");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Register Free Church Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                    TextInputStrip(
                      title: "Full Name",
                      controller: controller1,
                      label: "Name",
                      con: Icons.person,
                      keyboard: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextInputStrip(
                      title: "Church Name",
                      controller: controller2,
                      label: "Church Name",
                      con: Icons.church,
                      keyboard: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextInputStrip(
                      title: "Vision",
                      controller: controller3,
                      label: "Vision",
                      con: Icons.directions,
                      keyboard: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextInputStrip(
                      title: "Mission",
                      controller: controller4,
                      label: "Mission",
                      con: Icons.directions,
                      keyboard: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(102, 158, 158, 158),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 15.0, bottom: 10.0),
                                child: Text(
                                  "Phone Number",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ),
                            ],
                          ),
                          IntlPhoneField(
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
                        ],
                      ),
                    ),
                    // TextInputStrip(
                    //     title: "Phone Number",
                    //     controller: controller5,
                    //     label: "Phone Number",
                    //     keyboard: TextInputType.number,
                    //     con: Icons.phone),
                    const SizedBox(
                      height: 10,
                    ),
                    TextInputStrip(
                      title: "Email",
                      controller: controller6,
                      label: "Email",
                      con: Icons.email,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextInputStrip(
                        title: "Address",
                        controller: controller7,
                        label: "Address",
                        keyboard: TextInputType.text,
                        con: Icons.home),
                    const SizedBox(
                      height: 10,
                    ),
                    TextInputStrip(
                      title: "Church PassCode",
                      controller: controller8,
                      label: "Church Password",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ExtraButton(
                          color: Colors.blue[900],
                          writing2: const Text(
                            "Register Church",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          skip: () {
                            setState(() {
                              name = controller1.text;
                              churchName = controller2.text;
                              vision = controller3.text;
                              mission = controller4.text;
                              phoneNumber = number;
                              email = controller6.text;
                              address = controller7.text;
                              password = controller8.text;
                            });

                            if (name.isNotEmpty &&
                                churchName.isNotEmpty &&
                                vision.isNotEmpty &&
                                mission.isNotEmpty &&
                                phoneNumber.isNotEmpty &&
                                email.isNotEmpty &&
                                address.isNotEmpty &&
                                password.isNotEmpty) {
                              setState(() {
                                isLoading = true;
                              });
                              // All fields are not empty, proceed with the next step
                              registerChurch(
                                churchName: churchName,
                                ChurchNumber: phoneNumber,
                              );

                              Future.delayed(Duration(seconds: 3), () {
                                setState(() {
                                  churchExist = false;
                                  numberExist = false;
                                  isLoading = false;
                                });
                              });
                            } else {
                              const message = "Please fill in the whole form.";
                              alertReturn(context, message);
                            }
                          }),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
