import 'package:flutter/material.dart';
import 'package:master/screens/post/create_post.dart';
import '../componants/buttonChip.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Poster(),
      ),
    );
  }
}

