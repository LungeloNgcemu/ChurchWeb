import 'package:flutter/material.dart';
import 'package:master/profile_screen.dart';

import 'screens/login_screen.dart';
import 'screens/front_screen.dart';
import 'screens/login_register.dart';
import 'screens/salon_screen.dart';
import 'profile_screen.dart';
import 'screens/product_service_screen.dart';
import 'screens/booking_screen.dart';
import 'create_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'url_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ImageUrlProvider imageUrlProvider = ImageUrlProvider();

  // Load the image URL from local storage
  await imageUrlProvider.loadImageUrlLocally();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageUrlProvider>(
          create: (BuildContext context) => ImageUrlProvider(),
        ),
        ChangeNotifierProvider<ProfileImageUrlProvider>(
          create: (BuildContext context) => ProfileImageUrlProvider(),
        ),
        ChangeNotifierProvider<BackImageUrlProvider>(
          create: (BuildContext context) => BackImageUrlProvider(),
        ),
        ChangeNotifierProvider<PostImageUrlProvider>(
          create: (BuildContext context) => PostImageUrlProvider(),
        ),
        ChangeNotifierProvider<PostIdProvider>(
          create: (BuildContext context) => PostIdProvider(),
        ),


      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const FrontScreen(),
        '/login&register': (context) => const RegisterLoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/salon': (context) => const SalonScreen(),
        '/booking': (context) => const BookingScreen(),
        '/create': (context) => const CreatePage(),
      },
    );
  }
}
