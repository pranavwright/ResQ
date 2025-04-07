import 'dart:convert'; // For Base64 encoding
import 'dart:io'; // For File handling
import 'dart:typed_data'; // For handling bytes
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class Identity extends StatefulWidget {
  const Identity({super.key});

  @override
  _IdentityState createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
  String name = 'Loading...';
  String email = 'Loading...';
  String imageUrl = 'https://storage.googleapis.com/resq_user_images/USR-20250321093705880Z-22F6.jpg';
  String userId = '';
  List<Map<String, dynamic>> roles = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await TokenHttp().get('/auth/getUser');
      if (response != null) {
        setState(() {
          name = response['name'] ?? 'Not provided';
          email = response['emailId'] ?? response['email'] ?? 'Not provided';
          imageUrl = response['photoUrl'] ?? imageUrl;
          userId = response['_id'] ?? '';
          roles = List<Map<String, dynamic>>.from(response['roles'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  // Function to convert image to Base64 and upload it
  Future<void> _uploadImage(dynamic imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (kIsWeb) {
        // Convert web image to Base64
        final base64String = base64Encode(_webImage!);
        final Map<String, dynamic> data = {
          'photo': base64String,
        };

        // Send Base64 string to server
        final response = await TokenHttp().post('/auth/uploadProfilePicture', data);

        if (response != null && response['photoUrl'] != null) {
          setState(() {
            imageUrl = response['photoUrl'];
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated successfully')),
            );
            _fetchUserData();
          });
        }
      } else {
        // For local file, convert image to Base64
        final bytes = await _imageFile!.readAsBytes();
        final base64String = base64Encode(bytes);
        final Map<String, dynamic> data = {
          'photo': base64String,
        };

        // Send Base64 string to server
        final response = await TokenHttp().post('/auth/uploadProfilePicture', data);

        if (response != null && response['photoUrl'] != null) {
          setState(() {
            imageUrl = response['photoUrl'];
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated successfully')),
            );
          });
          _fetchUserData();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Function to pick image from camera or gallery
  Future<void> _pickImage() async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Image Source'),
        children: <Widget>[
          if (!kIsWeb)
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
              },
              child: const Text('Take a Photo'),
            ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
            },
            child: const Text('Choose from Gallery'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      try {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
          await _uploadImage(MultipartFile.fromBytes(
            bytes,
            filename: path.basename(pickedFile.path),
          ));
        } else {
          final file = File(pickedFile.path);
          setState(() {
            _imageFile = file;
          });
          await _uploadImage(file);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

  // Function to update user profile data (name/email)
  Future<void> _updateProfile(String field, String value) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Prepare the update data
      final Map<String, dynamic> updateData = {field: value};
      
      if (field == 'name') {
        final response = await TokenHttp().post('/auth/updateUser', updateData);

        if (response != null && response['success'] == true) {
          setState(() {
            name = value;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name updated successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _fetchUserData();
        }
      } else if (field == 'email') {
        final response = await TokenHttp().post('/auth/updateUser', updateData);

        if (response != null && response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email updated successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _fetchUserData();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $field: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show edit dialog for name/email
  void _showEditDialog(String field) {
    if (field == 'name') {
      nameController.text = name;
    } else if (field == 'email') {
      emailController.text = email;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: field == 'name' ? nameController : emailController,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final newValue = field == 'name' 
                    ? nameController.text 
                    : emailController.text;
                Navigator.of(context).pop();
                await _updateProfile(field, newValue);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Function to get image provider
  ImageProvider _getImageProvider() {
    if (kIsWeb) {
      if (_webImage != null) return MemoryImage(_webImage!);
      return NetworkImage(imageUrl);
    } else {
      if (_imageFile != null) return FileImage(_imageFile!);
      return NetworkImage(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Profile Picture
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blue.shade300,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _isUploading
                                        ? const Center(child: CircularProgressIndicator())
                                        : Image(
                                            image: _getImageProvider(),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.blue,
                                              );
                                            },
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _isUploading ? null : _pickImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Name Field
                            ListTile(
                              title: Text(
                                'Name',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              subtitle: Text(name),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog('name'),
                              ),
                            ),
                            const Divider(),

                            // Email Field
                            ListTile(
                              title: Text(
                                'Email',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              subtitle: Text(email),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog('email'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                  
                  ],
                ),
              ),
            ),
    );
  }
}
