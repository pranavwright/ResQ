import 'package:flutter/material.dart';

class FamiliesScreen extends StatelessWidget {
  const FamiliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Families')),
      body: Center(
        child: Text('Families Screen'),
      ),
    );
  }
}
