import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resq/utils/http/token_http.dart';
import 'package:resq/widgets/pdf_generation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

class Identity extends StatefulWidget {
  const Identity({super.key});

  @override
  _IdentityState createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
  String name = 'Loading...';
  String phone = 'Loading...';
  String email = 'Loading...';
  String imageUrl = '';
  String userId = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = true;
  bool _isRequestingPermission = false;
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await TokenHttp().get('/auth/getUser');
      print(response);
      if (response != null) {
        setState(() {
          name = response['name'] ?? 'Not provided';
          phone = response['phone'] ?? 'Not provided';
          email = response['email'] ?? 'Not provided';
          userId = response['_id'] ?? '';
          imageUrl = response['profilePicture'] ?? '';
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

  void _showEditDialog() {
    nameController.text = name;
    emailController.text = email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final response = await TokenHttp().post('/auth/updateUser', {
                    'name': nameController.text,
                    'email': emailController.text,
                  });
                  
                  if (response != null && response['success'] == true) {
                    setState(() {
                      name = nameController.text;
                      email = emailController.text;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $e')),
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

  Future<void> _pickImage() async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Image Source'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async {
              final image = await _picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, image);
            },
            child: const Text('Take a Photo'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              final image = await _picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, image);
            },
            child: const Text('Pick from Gallery'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      try {
        setState(() {
          _isLoading = true;
        });

        final response = await TokenHttp().putWithFileUpload(
          endpoint: '/auth/updateUser',
          file: File(pickedFile.path),
          fieldName: 'photoUrl',
        );

        if (response != null && response['imageUrl'] != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            imageUrl = response['imageUrl'];
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<void> _shareIDCard() async {
    try {
      setState(() {
        _isRequestingPermission = true;
      });

      if (!kIsWeb) {
        PermissionStatus status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission required')),
            );
          }
          return;
        }
      }

      await PdfService.createAndPreviewPdf(_cardKey, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Resq ID Card'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit, size: 30.0, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _cardKey,
                        child: Container(
                          width: 350.0,
                          height: 600.0,
                          child: Card(
                            elevation: 15.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20.0),
                                    ),
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
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: _imageFile != null
                                            ? FileImage(_imageFile!)
                                            : imageUrl.isNotEmpty
                                                ? NetworkImage(imageUrl)
                                                : const AssetImage('assets/images/default_profile.png')
                                                    as ImageProvider,
                                        onBackgroundImageError: (exception, stackTrace) {
                                          print('Image error: $exception');
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'Phone: $phone',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'Email: $email',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'User ID: ${userId.isEmpty ? 'N/A' : userId.substring(0, math.min(8, userId.length))}${userId.length > 8 ? '...' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton.icon(
                        onPressed: _isRequestingPermission ? null : _shareIDCard,
                        icon: _isRequestingPermission
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf),
                        label: Text(
                          _isRequestingPermission ? 'Processing...' : 'Save as PDF',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
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