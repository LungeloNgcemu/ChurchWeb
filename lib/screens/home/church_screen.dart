import 'package:flutter/material.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/church_class.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/screens/profile/profile_screen.dart';
import 'package:master/databases/database.dart';
import 'package:master/screens/post/post_screen.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/socket/io_service.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../classes/church_init.dart';
import '../../providers/url_provider.dart';
import '../../extra/contact_screen.dart';
import 'home_screeen.dart';
import '../media/media_screen.dart';
import 'package:master/widgets/common/connect_bottom_nav.dart';
import 'dart:async';

class ChurchScreen extends StatefulWidget {
  const ChurchScreen({super.key});

  @override
  State<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends State<ChurchScreen> {
  // ── preserved ─────────────────────────────────────────────────────────────
  ChurchInit churchStart = ChurchInit();
  Authenticate auth = Authenticate();
  bool _initialized = false;

  final Uri _url =
      Uri.parse('https://lungelongcemu.github.io/Church-Connect-App-Site');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) throw Exception('Could not launch $_url');
  }

  void snackInit() {
    // preserved — subscription expiry check (commented out upstream)
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _initChurch();
      });
      _initialized = true;
    }
  }

  Future<void> _initChurch() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // preserved: socket + token + push + welcome
      await IOService.initializeWithProvider(context);
      TokenUser? user = await TokenService.tokenUser();
      if (user != null) IOService.joinRoom(user.uniqueChurchId!);
      PushNotifications.init(context);
      snackInit();
      const message = 'Welcome to Church Connect';
      alertWelcome(context, message);
    });
  }

  // preserved: Supabase Message stream
  void countStreamInit() => setState(() { listening = listining2(); });

  Stream? listening;
  Stream<dynamic> listining2() =>
      supabase.from('Message').stream(primaryKey: ['id']);

  final supabase = Supabase.instance.client;
  final PageController controller = PageController();
  int visit = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    PostScreen(),
    MediaScreen(),
    ContactScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final visibilityProvider = Provider.of<VisibilityProvider>(context);
    final isVisible = visibilityProvider.isVisible;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // preserved: supabase message stream listener
          StreamBuilder(
            stream: listening,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData) {
                print('Main count');
              }
              return const SizedBox.shrink();
            },
          ),
          PageView(
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) => setState(() => visit = index),
            controller: controller,
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: isVisible,
        child: ConnectBottomNav(
          currentIndex: visit,
          isDark: visit == 2, // dark variant on Media tab
          onTap: (index) {
            setState(() => visit = index);
            controller.animateToPage(index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          },
        ),
      ),
    );
  }
}
