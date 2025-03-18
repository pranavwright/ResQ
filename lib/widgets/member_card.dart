import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final int index;

  MemberCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member #$index',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Relationship to Household Head'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Gender'),
            ),
          ],
        ),
      ),
    );
  }
}
