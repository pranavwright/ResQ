import 'package:flutter/material.dart';
// Import the house donation form
import 'house_donation_form.dart';

class StatDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // await AuthService().logout(); // Call your logout method
              Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
            },
          ),
        ],
      ),
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
