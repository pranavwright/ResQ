import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApkService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadApk(String fileName, Uint8List fileBytes) async {
    try {
      // Create a reference to the APK file location
      final Reference ref = _storage.ref().child('apk').child(fileName);
      
      // Upload the file
      final UploadTask uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'application/vnd.android.package-archive'),
      );

      // Get the download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store the metadata in Firestore
      await FirebaseFirestore.instance.collection('app_versions').add({
        'version': fileName.split('-v')[1].split('.apk')[0],
        'downloadUrl': downloadUrl,
        'uploadedAt': DateTime.now(),
        'fileSize': fileBytes.length,
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload APK: $e');
    }
  }
}