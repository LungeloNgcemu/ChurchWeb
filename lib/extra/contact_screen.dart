import 'package:flutter/material.dart';
import 'package:tab_container/tab_container.dart';
import '../screens/chat/message_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TabContainer(
        controller: _tabController,
        tabEdge: TabEdge.left,
        tabsStart: 0.1,
        tabsEnd: 0.9,
        tabMaxLength: 100,
        borderRadius: BorderRadius.circular(10),
        tabBorderRadius: BorderRadius.circular(10),
        childPadding: const EdgeInsets.all(10.0),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
        unselectedTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 13.0,
        ),
        colors: [
          Colors.grey.shade200,
          Colors.grey.shade300,
        ],
        tabs: const [
          Icon(Icons.notes),
          Padding(
            padding: EdgeInsets.all(7.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat),
                Text("Chat")
              ],
            ),
          ),
        ],
        children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset("lib/images/clear.png")),
            // const Center(child: Text('Connect Chat', style: TextStyle(
            //   fontSize: 25
            // ),)),
          ],
        ),
          const MessageScreen()
        ],
      ),
    );
  }
}
