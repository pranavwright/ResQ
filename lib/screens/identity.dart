import 'dart:io';
import 'dart:typed_data';
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

  Future<void> _uploadImage(dynamic imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final response = await TokenHttp().putWithFileUpload(
        endpoint: '/auth/updateProfilePicture',
        file: imageFile,
        fieldName: 'profilePicture',
      );

      if (response != null && response['photoUrl'] != null) {
        setState(() {
          imageUrl = response['photoUrl'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        });
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

  ImageProvider _getImageProvider() {
    if (kIsWeb) {
      if (_webImage != null) return MemoryImage(_webImage!);
      return NetworkImage(imageUrl);
    } else {
      if (_imageFile != null) return FileImage(_imageFile!);
      return NetworkImage(imageUrl);
    }
  }

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
            decoration: InputDecoration(labelText: field),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final response = await TokenHttp().post('/auth/updateUser', {
                    field: field == 'name' ? nameController.text : emailController.text,
                  });

                  if (response != null && response['success'] == true) {
                    setState(() {
                      if (field == 'name') {
                        name = nameController.text;
                      } else {
                        email = emailController.text;
                      }
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update $field: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Resq ID Card'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        width: 350.0,
                        constraints: BoxConstraints(
                          minHeight: 500.0,
                        ),
                        child: Card(
                          elevation: 15.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/logo.jpg',
                                        height: 40.0,
                                        width: 40.0,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.volunteer_activism,
                                            size: 40.0,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 10.0),
                                      const Text(
                                        'Identity Card',
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50.0,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: _getImageProvider(),
                                      child: _isUploading
                                          ? const CircularProgressIndicator()
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _isUploading ? null : _pickImage,
                                        child: Container(
                                          width: 25.0,
                                          height: 25.0,
                                          decoration: BoxDecoration(
                                            color: Colors.blue, // Blue background color
                                            shape: BoxShape.circle, // Circular shape
                                            border: Border.all(
                                              color: Colors.white, // White border to make the icon pop
                                              width: 2.0,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add, // Plus icon
                                            color: Colors.white, // White color for the icon
                                            size: 18.0, // Icon size
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                GestureDetector(
                                  onTap: () => _showEditDialog('name'),
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                GestureDetector(
                                  onTap: () => _showEditDialog('email'),
                                  child: Text(
                                    'Email: $email',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
