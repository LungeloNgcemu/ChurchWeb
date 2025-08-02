import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/church_class.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/screens/prayer/prayer_screen.dart';
import 'package:master/screens/profile/profile_screen.dart';
import 'package:master/databases/database.dart';
import 'package:master/screens/post/post_screen.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tab_container/tab_container.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../classes/church_init.dart';
import '../../providers/url_provider.dart';
import '../../extra/contact_screen.dart';
import '../event/event_screen.dart';
import 'home_screeen.dart';
import '../media/media_screen.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:appwrite/appwrite.dart' as ap;
import 'package:master/screens/chat/chat_screen.dart';
import 'package:badges/badges.dart' as b;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class ChurchScreen extends StatefulWidget {
  const ChurchScreen({super.key});

  @override
  State<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends State<ChurchScreen>
    with SingleTickerProviderStateMixin {
  ChurchInit churchStart = ChurchInit();
  Authenticate auth = Authenticate();

  final Uri _url =
      Uri.parse('https://lungelongcemu.github.io/Church-Connect-App-Site');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  snack() {
    return AnimatedSnackBar(
      duration: Duration(days: 365),
      builder: ((context) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(128, 0, 0, 0)!, // Shadow color
                      offset: Offset(0, 4), // Horizontal and vertical offset
                      blurRadius: 8, // Blur radius
                      spreadRadius: 2, // Optional: How much the shadow spreads
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10.0)),
              padding: const EdgeInsets.all(8),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "lib/images/clear.png",
                    height: 100.0,
                    width: 100.0,
                  ),
                  const Text(
                    'Current Plan Expired',
                    softWrap: true,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: churchStart.visibilityToggle(context),
              child: ExtraButton(
                color: Colors.red,
                writing2: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                skip: () async {
                  const message =
                      "Send Admin proof of payment at lungelofarm@gmail.com\n\n After payment has reflected the App restrictions will be lifted\nThen  Restart App";
                  await alertSuccess(context, message);
                  _launchUrl();
                },

                // skip: () async {
                //   const message =
                //       "You will be directed to the Website \n\n1. Login \n2. Make Payment \n3. Restart App";
                //   await auth.alertSuccess(context, message);
                //   _launchUrl();
                // },
              ),
            ),
          ],
        );
      }),
    ).show(context);
  }

  void snackInit() {
    final isExpired = Provider.of<christProvider>(context, listen: false)
            .myMap['Project']?['Expire'] ??
        false;

    if (!isExpired) {
      return snack();
    }
  }

  @override
  void initState() {
    // countStreamInit();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initChurch();
    });

    // TODO: implement initState
    super.initState();
  }

  Future<void> _initChurch() async {
    ChurchInit churchStart = ChurchInit();
    Authenticate auth = Authenticate();

    await churchStart.init(context);
    snackInit();
    final message = " Welcome to Church Connect";
    alertWelcome(
        context, message); // Wait for the initialization to complete

    // setState(() {});
  }

  void countStreamInit() {
    final mm = listining2();
    setState(() {
      listening = mm;
    });
  }

  Stream? listening;

  Stream<dynamic> listining2() {
    return supabase.from('Message').stream(primaryKey: ['id']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  AppWriteDataBase connect = AppWriteDataBase();

  Church churchSystems = Church();

  final supabase = Supabase.instance.client;

  final PageController controller = PageController();
  int visit = 0;
  bool isVisble = false;
  List<TabItem> items = const [
    TabItem(
      icon: Icons.home_filled,
      title: 'Home',
    ),
    TabItem(
      icon: FontAwesomeIcons.cross,
      title: 'Connect',
    ),
    TabItem(
      icon: Icons.mic,
      title: 'Media',
    ),
    // TabItem(
    //   icon: Icons.campaign_sharp,
    //   title: 'Events',
    // ),
    TabItem(
      icon: Icons.people_alt_outlined,
      title: 'Bible-Chat',
    ),
    TabItem(
      icon: Icons.account_circle_outlined,
      title: 'Account',
    ),
  ];

  //
  // List<TabItem> items = const [
  //   TabItem(
  //     icon: Icons.home_filled,
  //     title: 'Home',
  //   ),
  //   TabItem(
  //     icon: Icons.post_add,
  //     title: 'Social',
  //   ),
  //   TabItem(
  //     icon: Icons.mic,
  //     title: 'Media',
  //   ),
  //   TabItem(
  //     icon: Icons.book,
  //     title: 'Events',
  //   ),
  //   TabItem(
  //     icon: Icons.church,
  //     title: 'Prayer',
  //   ),
  //   TabItem(
  //     icon: Icons.people_alt_outlined,
  //     title: 'Chat',
  //   ),
  //   TabItem(
  //     icon: Icons.account_circle_outlined,
  //     title: 'Account',
  //   ),
  // ];

  final List<Widget> _pages = const [
    HomeScreen(),
    PostScreen(),
    MediaScreen(),
    // EventScreen(),
    // PrayerScreen(),
    ContactScreen(),
    // ChatScreen(),
    ProfileScreen()
  ];

  void sheeting2() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal BottomSheet'),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void sheeting() {
    Widget _buildBottomSheet(
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
    ) {
      return Material(
        child: Container(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
          ),
        ),
      );
    }

    showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 0.8,
      context: context,
      builder: _buildBottomSheet,
      isExpand: false,
    );
  }

  late final TabController _tabController =
      TabController(length: 7, vsync: this);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    final visibilityProvider = Provider.of<VisibilityProvider>(context);

    // Read the visibility state
    bool isVisible = visibilityProvider.isVisible;

    // return Scaffold(
    //   body: TabContainer(
    //     controller: _tabController,
    //     tabEdge: TabEdge.left,
    //     tabsStart: 0.1,
    //     tabsEnd: 0.9,
    //     tabMaxLength: 100,
    //     borderRadius: BorderRadius.circular(10),
    //     tabBorderRadius: BorderRadius.circular(10),
    //     childPadding: const EdgeInsets.all(0.0),
    //     selectedTextStyle: const TextStyle(
    //       color: Colors.white,
    //       fontSize: 15.0,
    //     ),
    //     unselectedTextStyle: const TextStyle(
    //       color: Colors.black,
    //       fontSize: 13.0,
    //     ),
    //     colors: [
    //       Colors.white,
    //       Colors.white,
    //       Colors.white,
    //       Colors.white,
    //       Colors.grey.shade300,
    //       Colors.grey.shade400,
    //       Colors.grey.shade300,
    //
    //     ],
    //     tabs: [
    //       Icon(Icons.home_filled),
    //       Icon(Icons.post_add),
    //       Icon(Icons.mic),
    //       Icon(Icons.event_sharp),
    //       Icon(Icons.church),
    //       Icon(Icons.people_alt_outlined),
    //       Icon(Icons.account_circle_outlined),
    //
    //     ],
    //     children:_pages,
    //   ),
    // );
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
            stream: listening,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const SizedBox.shrink();
                case ConnectionState.waiting:
                  return const SizedBox.shrink();
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    //TODO uncoment
                    print('Main count');
                    churchSystems.superbaseCount(setState);
                    //getCount();

                    // Future.delayed(Duration.zero, () async {
                    //   setState(() {
                    //
                    //   });
                    // });

                    break;
                  }
                case ConnectionState.done:
                  return const SizedBox.shrink();
                default:
                  return const SizedBox.shrink();
              }
              return Container();
            },
          ),
          PageView(
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() {
                visit = index;
                (context as Element).markNeedsBuild();
              });
            },
            controller: controller,
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: isVisible,
        child: BottomBarFloating(
          items: items,
          backgroundColor: Colors.white,
          color: Colors.black,
          colorSelected: Colors.grey,
          indexSelected: visit,
          paddingVertical: 8,
          onTap: (int index) => setState(() {
            visit = index;
            controller.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          }),
        ),
      ),
    );
  }
}

class StartLeftText extends StatelessWidget {
  const StartLeftText({
    this.wait,
    this.call,
    super.key,
  });

  final FontWeight? wait;
  final String? call;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$call',
          style: TextStyle(
            fontWeight: wait ?? FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, this.iconimage, this.icontext});

  final Icon? iconimage;
  final Text? icontext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 15.0),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: () {}, icon: iconimage!),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: icontext!,
          )
        ],
      ),
    );
  }
}
