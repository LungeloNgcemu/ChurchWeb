import 'package:flutter/material.dart';
// import 'product_card.dart';
import 'editable_card.dart';

class Haircut extends StatelessWidget {
  const Haircut({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          EditableProductCard(
            tag: Colors.purple,
          ),
    
        ],
      ),
    );
  }
}


class HairWash extends StatelessWidget {
  const HairWash({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          EditableProductCard(
            tag: Colors.green,
          ),
        ],
      ),
    );
  }
}

class Braids extends StatelessWidget {
  const Braids({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          EditableProductCard(
            tag: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class Face extends StatelessWidget {
  const Face({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
         EditableProductCard(
            tag: Colors.pink,
          ),
        ],
      ),
    );
  }
}