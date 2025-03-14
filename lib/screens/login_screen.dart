import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: !kIsWeb? Colors.green : Colors.blue, // Android-specific color
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login Screen',
              style: TextStyle(
                fontSize: 20,
                color: !kIsWeb? Colors.green : Colors.red, // Different color for Android
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
                backgroundColor: Colors.orange, 
              ),
              child: Text('Donate Now'),
            ),
            SizedBox(height: 20),
            Text(
              !kIsWeb
                  ? 'Running on Android ✅'
                  : 'Not running on Android ❌',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
                      // ...existing code...
            // ElevatedButton(
            //   onPressed: () => Navigator.pushNamed(context, '/loan-relief'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.grey,  // Different color to distinguish test button
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //   ),
            //   child: Text('Test Loan Relief Screen'),  // Move child outside of styleFrom
            // ),
            // ...existing code...
          ],
        ),
      ),
    );
  }
}