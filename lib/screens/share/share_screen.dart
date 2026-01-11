import 'dart:html' as html; // For web URL access
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/Model/church_token_model.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/componants/logo_header.dart';
import 'package:master/componants/multi_church_select.dart';
import 'package:master/constants/constants.dart';
import 'package:master/screens/auth/register/register_leader.dart';
import 'package:master/screens/splash/splash_screen.dart';
import 'package:master/services/api/user_service.dart';
import 'package:master/util/alerts.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables
  String? _selectedGender;
  String church = "";
  String? image;
  bool isLoading = false;
  bool isExpired = false;
  bool nameError = false;
  bool emailError = false;
  String? errorMessage;
  Authenticate auth = Authenticate();
  ChurchTokenData? churchTokenData;

  final List<String> items = [
    'Male',
    'Female',
  ];

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadChurchData();
  }

  Future<void> openExternalHost() async {
    String baseUrlLaunch = BaseUrl.baseUrlLaunch!;

    // Force opening in a new browser tab
    // if (!await launchUrl(
    //   Uri.parse(baseUrlLaunch),
    //   mode: LaunchMode.externalApplication,
    // )) {
    //   throw 'Could not launch $baseUrlLaunch';
    // }

    html.window.location.href = baseUrlLaunch.toString(); // replaces current tab
    // or use html.window.location.assign(url);


  }

  Future<void> _loadChurchData() async {
    try {
      // Get the current URL from the browser
      final url = html.window.location.href;
      print('Current URL: $url'); // Debug print

      if (url.isNotEmpty) {
        churchTokenData = await Authenticate.getChurchDataFromUrl(url);
        if (churchTokenData != null) {
          if (churchTokenData!.isExpired) {
            setState(() {
              isExpired = true;
              errorMessage =
                  'Sorry, this link has expired. Please request a new one.';
              isLoading = false;
            });
          } else {
            setState(() {
              church = churchTokenData!.churchName;
              image = churchTokenData!.imageUrl;
              isLoading = false;
            });
          }
        } else {
          // Handle case where data couldn't be parsed
          setState(() {
            errorMessage =
                'Invalid invitation link. Please ask for a new invitation link.';
            isLoading = false;
          });
        }
      } else {
        // Handle case where URL is empty
        setState(() {
          errorMessage = 'No invitation link provided.';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading church data: $e');
      setState(() {
        errorMessage =
            'An error occurred while processing the invitation. Please try again later.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || isExpired) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  isExpired ? 'Link Expired' : 'Error',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? 'An unknown error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Logo Header at the top
          LogoHeader(
            title: "Join ${church}",
            image: image,
          ),
          // Centered content with scroll
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container for the animated text with fixed height
                        Container(
                          height: 150, // Fixed height to prevent layout shifts
                          alignment: Alignment.center,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'racingSansOne',
                            ),
                            textAlign: TextAlign.center,
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText('Welcome'),
                                TypewriterAnimatedText(
                                    'Please Share Your Details Below...'),
                              ],
                              onTap: () {
                                print("Tap Event");
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InputAppwrite(
                          icon: Icons.person,
                          controller: _nameController,
                          label: 'Name',
                          text: 'Name',
                          hasError: nameError,
                          errorMessage: 'Please enter a name',
                          keyboard: TextInputType.text,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        // InputAppwrite(
                        //   icon: Icons.email,
                        //   controller: _emailController,
                        //   label: 'Email',
                        //   text: 'Email',
                        //   keyboard: TextInputType.emailAddress,
                        //   hasError: emailError,
                        //   errorMessage: 'Please enter an email address',
                        //   onChanged: (value) {},
                        // ),
                        const SizedBox(height: 16),
                        // auth.dropDownMenu(context, items, setState),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: IntlPhoneField(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                              ),
                              labelText: 'Phone Number',
                              hintText: 'Phone Number',
                            ),
                            initialCountryCode: 'ZA',
                            onChanged: (phone) {
                              _numberController.text = phone.completeNumber;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ExtraButton(
                            writing2: const Text(
                              "Join Church",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            skip: () async {
                              setState(() {
                                isLoading = true;
                              });

                              if (_nameController.text.isEmpty) {
                                setState(() {
                                  nameError = true;
                                  isLoading = false;
                                });
                              }

                              // if (_emailController.text.isEmpty) {
                              //   setState(() {
                              //     emailError = true;
                              //   });
                              // }

                              if (_numberController.text.isEmpty) {
                                alertReturn(
                                    context, "Please enter a phone number");

                                setState(() {
                                  isLoading = false;
                                });

                                return;
                              }

                              if (!nameError) {
                                ExistingUser? existingUser =
                                    await UserService.userExist(
                                        _numberController.text,
                                        churchTokenData!.uniqueChurchId!);

                                if (existingUser != null) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  alertReturn(context, "User already exists");
                                  return;
                                }

                                if (churchTokenData!.isLeader) {
                                  bool? isPasswordValid = await showAdminDialog(
                                      context,
                                      _passwordController,
                                      churchTokenData!.uniqueChurchId!);

                                  if (!isPasswordValid!) {
                                    alertReturn(context, "Wrong password");
                                    return;
                                  }
                                  await Authenticate.registerUser(
                                    name: _nameController.text,
                                    phone: _numberController.text,
                                    uniqueChurchId:
                                        churchTokenData!.uniqueChurchId!,
                                    role: churchTokenData!.role!,
                                  );

                                  await openExternalHost();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/registerMember', // named route
                                    (route) => false,
                                  );

                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  await Authenticate.registerUser(
                                    name: _nameController.text,
                                    phone: _numberController.text,
                                    uniqueChurchId:
                                        churchTokenData!.uniqueChurchId!,
                                    role: churchTokenData!.role!,
                                  );
                                  await openExternalHost();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/registerMember', // named route
                                    (route) => false,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
