import 'package:flutter/material.dart';

class RoleNoticeBoard extends StatelessWidget {
  const RoleNoticeBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notice Board')),
      body: Center(
        child: Text('Role Notice Board Screen'),
      ),
    );
  }
}
