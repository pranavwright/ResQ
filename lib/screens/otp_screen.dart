import 'package:flutter/material.dart';
import '../utlis/auth/auth_service.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  // Mock function to simulate API call - replace with actual API call
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    // This is just a mock - replace with actual API call
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    // Mock response
    return {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Sample token
      'roles': ['superadmin', 'familysurvey', 'roomsurvey'] // Sample roles
    };
  }

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      // Wrap the body content with SingleChildScrollView to make it scrollable
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Added space at the top
              SizedBox(height: 40),
              
              // Phone number section
              Text(
                'Enter Phone Number',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              // Phone number input field
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // OTP section
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
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
                  // Validate phone number first
                  if (phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter your phone number')),
                    );
                    return;
                  }
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    // Call API to verify OTP with phone number
                    final response = await verifyOtp(phoneController.text, otpController.text);
                    
                    // Extract token and roles
                    final token = response['token'];
                    final roles = List<String>.from(response['roles']);
                    
                    // Login with token and roles
                    await AuthService().login(token, roles);
                    
                    // Close loading dialog
                    Navigator.pop(context);
                    
                    // Navigate to appropriate dashboard based on roles
                    String targetRoute = '/app'; // Default route
                    
                    // Navigate to the appropriate dashboard
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
                      SnackBar(content: Text('Verification failed: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Verify & Continue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              
              // Added bottom padding for better keyboard appearance
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
