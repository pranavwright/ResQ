import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utlis/auth/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String token;
  final List<String> roles;

  const ProfileSetupScreen({
    Key? key,
    required this.token,
    required this.roles,
  }) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Here you would normally upload the image to your server
      // and update the user profile with the email
      
      // Mock API call for uploading profile picture
      await Future.delayed(Duration(seconds: 1));
      
      // Save user profile data locally
      await AuthService().saveUserProfile(
        email: _emailController.text,
        profileImagePath: _profileImage!.path,
      );
      
      // Mark profile as completed
      await AuthService().markProfileCompleted();
      
      // Navigate to the appropriate dashboard
      Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Set Up Your Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Please complete your profile to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                
                // Profile Picture Selection
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: _profileImage == null
                      ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey[800])
                      : null,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tap to select profile picture',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                
                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                
                // Save Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save & Continue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}