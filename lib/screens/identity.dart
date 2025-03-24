import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Identity extends StatefulWidget {
  const Identity({super.key});

  @override
  _IdentityState createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
  String name = 'John Doe';
  String phone = '9876543210';
  String email = 'abhay@gmail.com';
  String imageUrl = 'https://storage.cloud.google.com/resq_user_images/ADMIN-YYYYMMDDHHMMSS-WR.jpg';

  // Controllers for the fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Initialize ImagePicker
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;  // Store the selected image

  // Method to show the edit dialog for name and email
  void _showEditDialog() {
    nameController.text = name;
    emailController.text = email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name and Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField for Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10.0),
              // TextField for Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  name = nameController.text;
                  email = emailController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to pick an image from gallery or camera
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

    // If an image is picked, update the state
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);  // Store the image as a File
        imageUrl = pickedFile.path;  // Update the image URL with local file path
      });
    }
  }

  // Method to download the image
  Future<void> _downloadImage() async {
    // Check for storage permissions
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        Dio dio = Dio();

        // Get the Downloads folder path using path_provider
        Directory? downloadsDirectory = await getExternalStorageDirectory();
        String savePath = "${downloadsDirectory!.path}/identity_card_image.jpg";

        // Make the download and save the image to the download folder
        await dio.download(imageUrl, savePath);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded to $savePath')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading image: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Resq'),
        centerTitle: true,
        actions: [
          // Edit Icon Button in the AppBar
          IconButton(
            onPressed: _showEditDialog, // Trigger the edit dialog for name and email
            icon: const Icon(Icons.edit, size: 30.0, color: Colors.white),  // Pencil icon
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Card Widget with the Profile Information
                Container(
                  width: 350.0, // You can adjust the width here
                  height: 600.0, // Adjust the height here
                  child: Card(
                    elevation: 15.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        // Card Title and Logo in Row
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                          ),
                          child: Row(
                            children: [
                              // Logo Image on the Left
                              Image.asset(
                                'assets/images/logo.jpg', // Replace with your logo image asset path
                                height: 40.0,  // Adjust the logo size
                                width: 40.0,
                              ),
                              const SizedBox(width: 10.0),
                              // Title Text on the Right
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

                        // Profile Picture with Add (+) Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,  // Open camera/gallery when clicked
                              child: CircleAvatar(
                                radius: 50.0,
                                backgroundImage: _imageFile == null
                                    ? NetworkImage(imageUrl)
                                    : FileImage(_imageFile!) as ImageProvider,
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
                                    border: Border.all(color: Colors.white, width: 2),
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

                        // Name
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Phone
                        Text(
                          'Phone: $phone',  // Display phone
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Email
                        Text(
                          'Email: $email',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                // Download Button outside the Card
                ElevatedButton(
                  onPressed: _downloadImage,  // Trigger the download action
                  child: const Text('Download Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identity Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Identity(),
    );
  }
}
