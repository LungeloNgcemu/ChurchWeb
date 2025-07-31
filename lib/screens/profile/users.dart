import 'package:flutter/material.dart';
import '../../cards/user_card.dart';

class UsersBody extends StatefulWidget {
  const UsersBody({super.key});

  @override
  State<UsersBody> createState() => _UsersBodyState();
}

class _UsersBodyState extends State<UsersBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0, left: 8.0, top: 8.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    height: 50.0,
                    width: 50.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Users',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 600,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: const [
                  UserCard(),
                  UserCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


