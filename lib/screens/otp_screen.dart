import 'package:flutter/material.dart';
import 'package:resq/utils/http/auth_http.dart';
import '../utils/auth/auth_service.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  // Mock function to simulate API call - replace with actual API call
  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    const token = 'ertg';
    var res = await AuthHttp().verifyFirebaseToken(token: token);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // OTP input field
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                counterText: '',
              ),
            ),
            SizedBox(height: 30),
            // Button to verify OTP
            ElevatedButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(child: CircularProgressIndicator()),
                );

                try {
                  final response = await verifyOtp(otpController.text);

                  final token = response['token'];
                  final roles = List<String>.from(response['roles']);

                  Navigator.pop(context);
                  await AuthService().login(token, roles);
                  String targetRoute = '/app';

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    targetRoute,
                    (route) => false,
                  );
                } catch (e) {
                  // Close loading dialog
                  Navigator.pop(context);

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('OTP verification failed: ${e.toString()}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Verify & Continue', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
