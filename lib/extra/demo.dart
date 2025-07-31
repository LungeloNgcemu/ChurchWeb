import 'package:flutter/material.dart';

class Helper extends StatelessWidget {
  const Helper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(
            child: Text("hello"),
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(20.0),
                right: Radius.circular(20.0),
              ),
            ),
            child: const Text(
              "hello,",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text("hello", style: TextStyle())
        ],
      ),
    );
  }
}

class MyNewOne extends StatefulWidget {
  const MyNewOne({super.key});

  @override
  State<MyNewOne> createState() => _MyNewOneState();
}

class _MyNewOneState extends State<MyNewOne> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: const CircleAvatar(
            backgroundImage: AssetImage("assets/images/avatar.png"),
            radius: 20.0,
          ),
        ),
      ],
    );
  }
}
