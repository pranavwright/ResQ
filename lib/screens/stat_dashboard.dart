import 'package:flutter/material.dart';
// Import the house donation form
import 'house_donation_form.dart';

class StatDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistics Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsDepartmentHouseDonationForm(),
              ),
            );
          },
          child: Text('House Donation Registration'),
        ),
      ),
    );
  }
}
