import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resq/utils/http/auth_http.dart';
import 'package:resq/utils/http/token_less_http.dart';
import '../utils/auth/auth_service.dart';
import '../constants/api_constants.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  
  bool _isOtpSent = false;
  String _verificationId = '';
  bool _isLoading = false;
  
  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }
  
  // Send OTP via Firebase
  Future<void> _sendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    
    try {
      // Format phone number with + if not present
      String phoneNumber = phoneController.text.trim();
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber'; // Remove space after country code
      }

      print(phoneNumber);


      await AuthHttp().checkPhoneNumber(phoneNumber: phoneNumber).then((res){
        if(!res['success']){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number not exists')),
          );
         setState(() => _isLoading = true);
         return;
        }
      });

      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android (not always triggered)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Notify API that OTP has been sent
          try {
            final tokenLessHttp = TokenLessHttp();
            await tokenLessHttp.post('/auth/otpSent', {
              'phoneNumber': phoneNumber,
              'timestamp': DateTime.now().toIso8601String(),
              'verificationId' : verificationId
            });
          } catch (e) {
            // Non-critical error, continue with flow
            print('Failed to notify API of OTP sent: $e');
          }
          
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
          _verificationId = verificationId;
        },
        // timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $e')),
      );
    }
  }
  
  // Verify OTP and sign in
  Future<void> _verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Create credential - Using PhoneAuthProvider instead of AuthService
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpController.text.trim(),
      );
      
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed: $e')),
      );
    }
  }
  
  // Sign in with credential and verify with backend
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Get Firebase token
      final firebaseToken = await userCredential.user?.getIdToken();
      
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }
      
      // Verify token with your backend - Use tokenLessHttp since we don't have a JWT yet
      final tokenLessHttp = TokenLessHttp();
      final response = await tokenLessHttp.post('/auth/verifyFirebaseToken', {
        'firebaseToken': firebaseToken, 
      });
      
      // Extract token and roles based on backend response
      final jwtToken = response['jwtToken']; // Changed to match backend response field
      final roles = List<String>.from(response['roles'] ?? []);
      
      // Save authentication state
      await AuthService().login(jwtToken, roles);
      
      // Navigate to appropriate screen
      if (!mounted) return;
      
      // Navigate based on whether user has a profile photo
      final hasPhoto = response['photoUrl'] != null;
      if (hasPhoto) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/app',
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/complete-profile',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOtpSent ? 'Verify OTP' : 'Phone Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading 
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _isOtpSent ? _buildOtpInput() : _buildPhoneInput(),
        ),
      ),
    );
  }
  
  // Phone number input screen
  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        
        // Image.asset(
        //   '../assets/images/resq_logo.jpg',
        //   height: 100,
        //   width: 100,
        // ),
        
        // SizedBox(height: 30),
        
        Text(
          'Enter Phone Number',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '9XXXXXXXXX',
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91 ',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 30),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendOtp,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Send OTP',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        
        SizedBox(height: 40),
      ],
    );
  }
  
  // OTP input screen
  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        
        Text(
          'Enter OTP',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Sent to ${phoneController.text}',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 15),
        
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            counterText: '',
          ),
        ),
        SizedBox(height: 30),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifyOtp,
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
        ),
        
        TextButton(
          onPressed: () {
            setState(() {
              _isOtpSent = false;
              otpController.clear();
            });
          },
          child: Text('Change Phone Number'),
        ),
        
        SizedBox(height: 20),
        
        TextButton.icon(
          onPressed: _sendOtp,
          icon: Icon(Icons.refresh),
          label: Text('Resend OTP'),
        ),
        
        SizedBox(height: 40),
      ],
    );
  }
}