import 'package:flutter/material.dart';
import 'dart:io' show Platform; // Import to check the OS

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Platform.isAndroid ? Colors.green : Colors.blue, // Android-specific color
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login Screen',
              style: TextStyle(
                fontSize: 20,
                color: Platform.isAndroid ? Colors.green : Colors.red, // Different color for Android
              ),
            ),
            SizedBox(height: 20), // Adds some spacing
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/otp');
              },
              child: Text('Go to OTP'),
            ),
                     SizedBox(height: 20),
            // New Donation Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/public-donation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Distinctive color
              ),
              child: Text('Donate Now'),
            ),
            SizedBox(height: 20),
            // New Donation Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/public-donation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Distinctive color
              ),
              child: Text('Donate Now'),
            ),
            SizedBox(height: 20),
            Text(
              Platform.isAndroid
                  ? 'Running on Android ✅'
                  : 'Not running on Android ❌',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}