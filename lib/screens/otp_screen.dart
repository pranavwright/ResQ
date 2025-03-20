import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resq/utils/http/auth_http.dart';
import 'package:resq/utils/http/token_less_http.dart';
import '../utils/auth/auth_service.dart';

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

  Future<void> _sendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String phoneNumber = phoneController.text.trim();
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber';
      }

      print(phoneNumber);

      await AuthHttp().checkPhoneNumber(phoneNumber: phoneNumber).then((res) {
        if (!res['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number does not exist')),
          );
          setState(() => _isLoading = false);
          return;
        }
      });

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          try {
            final tokenLessHttp = TokenLessHttp();
            await tokenLessHttp.post('/auth/otpSent', {
              'phoneNumber': phoneNumber,
              'timestamp': DateTime.now().toIso8601String(),
              'verificationId': verificationId,
            });
          } catch (e) {
            print('Failed to notify API of OTP sent: $e');
          }

          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
    }
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpController.text.trim(),
      );

      await _signInWithCredential(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP verification failed: $e')));
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);

      final firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }

      final tokenLessHttp = TokenLessHttp();
      final response = await tokenLessHttp.post('/auth/verifyFirebaseToken', {
        'firebaseToken': firebaseToken,
      });

      if (response['jwtToken'] == null) {
        throw Exception('Invalid response from server: JWT token is missing');
      }

      final jwtToken = response['jwtToken'];
      final roleData = response['roles'] ?? [];
      final disasterId = roleData.isNotEmpty ? roleData[0]['disasterId'] : null;
      final role = roleData.isNotEmpty ? roleData[0]['roles'] : [];

      if(role.isEmpty || disasterId == null) {
        throw Exception('Invalid response from server: Roles or disaster ID is missing');
      }

      List<String> roles = List<String>.from(role.map((role) => role.toString()));

      print("Saving auth state with token: $jwtToken and roles: $roles");

      await AuthService().login(jwtToken, roles, disasterId);
      await AuthService().loadAuthState();
      final savedToken = await AuthService().getToken();
      print("Saved token: $savedToken");

      // if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/profile-setup',
        (route) => false,
      );
    } catch (e) {
      print("Authentication error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication failed: $e')));
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
        automaticallyImplyLeading: false,
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
              : _isOtpSent
                  ? _buildOtpInput()
                  : _buildPhoneInput(),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
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
                  Text('+91 ', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Container(height: 24, width: 1, color: Colors.grey),
                ],
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            child: Text('Send OTP', style: TextStyle(fontSize: 18)),
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

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
          decoration: InputDecoration(hintText: '000000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            child: Text('Verify & Continue', style: TextStyle(fontSize: 18)),
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