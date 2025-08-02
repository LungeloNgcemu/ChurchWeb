// import 'package:flutter/material.dart';
// import '../widget/input_page.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   var _controllerA = TextEditingController();
//   var _controllerB = TextEditingController();

//   String email = '';
//   String password = '';

//   @override
//   void dispose() {
//     // Dispose of the controllers when the widget is disposed
//     _controllerA.dispose();
//     _controllerB.dispose();
//     super.dispose();
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: ImputPage(
//         onChanged1: (value) {
//           email = value;
//         },
//         onChanged2: (value) {
//           password = value;
//         },
//       controller1:_controllerA ,
//       controller2: _controllerB,

//         hype: const Text(
//           'Login to Your Account Now',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 50.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         word: const Text(
//           'Login',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20.0,
//           ),
//         ),
//         pressed: () async {

//           // ignore: use_build_context_synchronously
//           // Capture the context
//           try {
//             dynamic result = await _auth.signInWithEmailAndPassword(
//                 email: email, password: password);
//             if (result != null) {
//               Navigator.pushNamed(context, '/salon');
//             }
//           } catch (e) {
            
//             Alert(
//               context: context, // Use the captured context here,
//               type: AlertType.error,
//               title: "Wrong Login Details",
//               desc: "Please type in the right detail or contact the Developer.${Error}",
//               buttons: [
//                 DialogButton(
//                   child: Text(
//                     "Retry",
//                     style: TextStyle(color: Colors.white, fontSize: 20),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                   width: 120,
//                 )
//               ],
//             ).show();
//             // print('Error: $e');
//             // Handle authentication errors here (show a message to the user, etc.)
//           }
//           _controllerA.clear();
//           _controllerB.clear();
//         },
//       ),
//     );
//   }
// }
