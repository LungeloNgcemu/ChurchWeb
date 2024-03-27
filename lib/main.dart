import 'package:flutter/material.dart';
import 'package:master/profile_screen.dart';
import 'screens/message_screen.dart';
//import 'screens/login_screen.dart';
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
import 'edit_page.dart';
import 'package:master/Product_poster.dart';
import 'package:appwrite/appwrite.dart';
import 'screens/login_appwrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/register_appwrite.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/code.dart';
import 'screens/splash_screen.dart';



const supabaseUrl = 'https://subejxnzdnqyovwhinle.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1YmVqeG56ZG5xeW92d2hpbmxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDg1NDI5NTMsImV4cCI6MjAyNDExODk1M30.hDMsQXcPhdq-ZE126aPOYMIZVmnU6xOQjeLwxOijHrs';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:supabaseUrl,
    anonKey:supabaseKey,
    // headers:
  );




  // final wsUrl = Uri.parse(
  //     'ws://cloud.appwrite.io/v1/realtime?project=65bc947456c1c0100060&channels%5B%5D=databases.65c375bf12fca26c65db.collections.65d0612a901236115ecc.documents');
  // late final channel = WebSocketChannel.connect(wsUrl);
  //
  //
  //   await channel.ready;
  //
  //   channel.stream.listen((message) {
  //     print("Connected to server");
  //    // channel.sink.add('received!');
  //
  //     print("MESSAGE : $message");
  //     channel.sink.close();
  //   });



  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('65bc947456c1c0100060')
      .setSelfSigned(status: true);
  Account account = Account(client);

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
        ChangeNotifierProvider<SelectedOptionProvider>(
          create: (BuildContext context) => SelectedOptionProvider(),
        ),
        ChangeNotifierProvider<CurrentRoomIdProvider>(
          create: (BuildContext context) => CurrentRoomIdProvider(),
        ),
        ChangeNotifierProvider< CurrentUserImageProvider>(
          create: (BuildContext context) =>  CurrentUserImageProvider(),
        ),
        ChangeNotifierProvider< ClientImageProvider>(
          create: (BuildContext context) =>  ClientImageProvider(),
        ),
        ChangeNotifierProvider< ItemProvider>(
          create: (BuildContext context) =>  ItemProvider(),
        ),
        ChangeNotifierProvider< tockenProvider>(
          create: (BuildContext context) =>  tockenProvider(),
        ),

        ChangeNotifierProvider< ClientNameProvider>(
          create: (BuildContext context) =>  ClientNameProvider(),
        ),
        ChangeNotifierProvider< ClientNumberProvider>(
          create: (BuildContext context) =>  ClientNumberProvider(),
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
          )
        ),

        // ...
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {

        '/splash' : (context) => SplashScreen(),
        '/loginAppwrite': (context) => LoginAppwrite(),
        '/code': (context)=> CodeAppwrite(),
       '/RegisterAppwrite': (context) => RegisterAppwrite(),

        '/login&register': (context) => const RegisterLoginScreen(),
        '/profile': (context) => const ProfileScreen(),
       // '/login': (context) => const LoginScreen(),
        '/salon': (context) => const SalonScreen(),
        '/booking': (context) => const BookingScreen(),
        '/create': (context) => const CreatePage(),
        '/edit': (context) => const EditPage(),
        '/productPoster': (context) => ProductPoster(),
        '/messageScreen': (context) => MessageScreen(),
      },
    );
  }
}
