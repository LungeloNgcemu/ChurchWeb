import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/providers/message_provider.dart';
import 'package:master/providers/registration_provider.dart';
import 'package:master/providers/user_data_provider.dart';
import 'package:master/screens/home/church_screen.dart';
import 'package:master/screens/auth/register/create_account.dart';
import 'package:master/screens/auth/cross_road.dart';
import 'package:master/screens/splash/splash_screen.dart';
import 'package:master/services/utils/env_service.dart';
import 'constants/constants.dart';
import 'screens/home/create_minister.dart';
import 'screens/prayer/create_prayer.dart';
import 'screens/chat/message_screen.dart';
import 'extra/booking_screen.dart';
import 'extra/create_page.dart';
import 'util/firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/url_provider.dart';
import 'screens/auth/login/login_appwrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/register/register_leader.dart';
import 'screens/auth/register/register_member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/otp/code.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvService.envInit();

  await Supabase.initialize(url: Keys.supabaseUrl, anonKey: Keys.supabaseKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  PushNotifications.getFCMToken();

  Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('65bc947456c1c0100060')
      .setSelfSigned(status: true);
  Account(client);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  ImageUrlProvider imageUrlProvider = ImageUrlProvider();

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
        ChangeNotifierProvider<SelectedOptionProvider>(
          create: (BuildContext context) => SelectedOptionProvider(),
        ),
        ChangeNotifierProvider<CurrentRoomIdProvider>(
          create: (BuildContext context) => CurrentRoomIdProvider(),
        ),
        ChangeNotifierProvider<CurrentUserImageProvider>(
          create: (BuildContext context) => CurrentUserImageProvider(),
        ),
        ChangeNotifierProvider<ClientImageProvider>(
          create: (BuildContext context) => ClientImageProvider(),
        ),
        ChangeNotifierProvider<ItemProvider>(
          create: (BuildContext context) => ItemProvider(),
        ),
        ChangeNotifierProvider<tockenProvider>(
          create: (BuildContext context) => tockenProvider(),
        ),
        ChangeNotifierProvider<ClientNameProvider>(
          create: (BuildContext context) => ClientNameProvider(),
        ),
        ChangeNotifierProvider<ClientNumberProvider>(
          create: (BuildContext context) => ClientNumberProvider(),
        ),
        ChangeNotifierProvider<churchProvider>(
          create: (BuildContext context) => churchProvider(),
        ),
        ChangeNotifierProvider<christProvider>(
          create: (BuildContext context) => christProvider(),
        ),
        ChangeNotifierProvider<VisibilityProvider>(
          create: (BuildContext context) => VisibilityProvider(),
        ),
        ChangeNotifierProvider<IdProvider>(
          create: (BuildContext context) => IdProvider(),
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (BuildContext context) => RoleProvider(),
        ),
        ChangeNotifierProvider<SelectedDateProvider>(
          create: (BuildContext context) => SelectedDateProvider(),
        ),
        ChangeNotifierProvider<SelectedChurchProvider>(
          create: (BuildContext context) => SelectedChurchProvider(),
        ),
        ChangeNotifierProvider<SelectedGenderProvider>(
          create: (BuildContext context) => SelectedGenderProvider(),
        ),
        ChangeNotifierProvider<UserDataProvider>(
          create: (BuildContext context) => UserDataProvider(),
        ),
        ChangeNotifierProvider<RegistrationProvider>(
          create: (BuildContext context) => RegistrationProvider(),
        ),
        ChangeNotifierProvider<MessageProvider>(
          create: (BuildContext context) => MessageProvider(),
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
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.racingSansOneTextTheme(
          Theme.of(context).textTheme.apply(
                fontSizeFactor: 0.8,
              ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/crossRoad': (context) => const CrossRoad(),
        '/RegisterLeader': (context) => const RegisterLeader(),
        '/RegisterMember': (context) => const RegisterMember(),
        '/church': (context) => const ChurchScreen(),
        '/loginAppwrite': (context) => LoginAppwrite(),
        '/code': (context) => const CodeAppwrite(),
        '/create': (context) => const CreatePage(),
        '/createMinister': (context) => const CreateMinister(),
        '/createPrayer': (context) => CreatePrayer(),
        '/messageScreen': (context) => const MessageScreen(),
        '/createAccount': (context) => const CreateAccount(),
      },
    );
  }
}
