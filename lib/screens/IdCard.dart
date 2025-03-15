import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class IDCardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card View and Download'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Displaying the ID card on screen
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                children: [
                  // Profile Section
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Software Engineer',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  // ID Info
                  Text('Date of Birth: 1990-01-01'),
                  Text('Phone No: +1 234 567 890'),
                  SizedBox(height: 20),
                  Divider(),
                  Text('ID: 123456789'),
                  Text('Issued: 2025-03-01'),
                  Text('Expiry: 2027-03-01'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Button to generate PDF
            ElevatedButton(
              onPressed: () async {
                // Ensure this button triggers the PDF generation and saving
                await _generateAndDownloadPDF(context);
              },
              child: Text('Download ID Card as PDF'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to generate and download the PDF
  Future<void> _generateAndDownloadPDF(BuildContext context) async {
    // Request permission to access external storage (for Android)
    await _requestStoragePermission();

    // Create the PDF document
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                // Name and Role
                pw.Text(
                  'John Doe',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Software Engineer',
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.grey),
                ),
                pw.SizedBox(height: 10),
                // Date of Birth and Phone Number
                pw.Text('Date of Birth: 1990-01-01'),
                pw.Text('Phone No: +1 234 567 890'),
                pw.SizedBox(height: 10),
                // ID Card Information
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('ID: 123456789'),
                pw.Text('Issued: 2025-03-01'),
                pw.Text('Expiry: 2027-03-01'),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF to a file
    final Uint8List bytes = await pdf.save();

    // Get the directory for Downloads (platform-specific)
    Directory directory = await _getDownloadsDirectory();
    String filePath = '${directory.path}/id_card.pdf';

    // Write the PDF to the file
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    // Show message to user and provide file path
    print('PDF saved at $filePath');

    // Optionally, share or open the file
    await Printing.sharePdf(bytes: bytes, filename: 'id_card.pdf');

    // Optionally, notify the user that the file is saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at $filePath')),
    );
  }

  // Request storage permission (for Android)
  Future<void> _requestStoragePermission() async {
    final permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }

  // Get the Downloads directory (platform-specific)
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // For Android, we will use the Downloads folder
      return Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      // For iOS, the document directory is used
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    } else {
      // For other platforms, use app's document directory
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    }
  }
}
