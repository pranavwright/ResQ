import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LoanReliefUploadScreen extends StatefulWidget {
  const LoanReliefUploadScreen({Key? key}) : super(key: key);

  @override
  _LoanReliefUploadScreenState createState() => _LoanReliefUploadScreenState();
}

class _LoanReliefUploadScreenState extends State<LoanReliefUploadScreen> {
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _hasError = false;
  File? _selectedFile;

  Future<void> _downloadTemplate() async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // In a real app, you would download the file
      // For demonstration, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template downloaded to Downloads folder'),
          backgroundColor: Colors.green,
        ),
      );
      
      // In a real implementation, you would use:
      // final Uri url = Uri.parse('https://yourserver.com/template.xlsx');
      // if (await canLaunchUrl(url)) {
      //   await launchUrl(url);
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied to download file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _uploadStatus = 'File selected: ${path.basename(_selectedFile!.path)}';
          _hasError = false;
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error selecting file: $e';
        _hasError = true;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _uploadStatus = 'Please select a file first';
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading file...';
      _hasError = false;
    });

    // Simulate file upload
    await Future.delayed(const Duration(seconds: 2));

    // Check file extension to make sure it's xlsx
    if (path.extension(_selectedFile!.path).toLowerCase() != '.xlsx') {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Invalid file format. Only Excel (.xlsx) files are accepted';
        _hasError = true;
      });
      return;
    }

    // In a real app, you would validate and upload the file to your server here
    // For this demo, we'll just simulate a successful upload
    setState(() {
      _isUploading = false;
      _uploadStatus = 'File uploaded successfully! Your application is being processed.';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Relief Loan Assistance'),
        backgroundColor: Colors.blue[800],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload your loan information to request government assistance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Instructions card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to apply for loan relief:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        buildStepItem(1, 'Download the Excel template below'),
                        buildStepItem(2, 'Fill in your loan information exactly as shown in the guide'),
                        buildStepItem(3, 'Save the file (do not change the format)'),
                        buildStepItem(4, 'Upload the completed template'),
                        buildStepItem(5, 'Submit your application'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Download template button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _downloadTemplate,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Excel Template'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Format guide
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required Format Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Your Excel file must follow this exact format:'),
                        const SizedBox(height: 16),
                        buildFormatTable(),
                        const SizedBox(height: 16),
                        const Text(
                          'Important Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        buildBulletPoint('Do not rename, add, or remove any columns'),
                        buildBulletPoint('Do not change the sheet name'),
                        buildBulletPoint('All fields are mandatory'),
                        buildBulletPoint('Maximum file size: 5MB'),
                        buildBulletPoint('Only .xlsx format is accepted'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // File upload area
                GestureDetector(
                  onTap: _pickExcelFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 48,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload Your Completed Excel File',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Tap to select your file'),
                        const SizedBox(height: 16),
                        _selectedFile != null
                            ? Text(
                                'Selected: ${path.basename(_selectedFile!.path)}',
                                style: const TextStyle(color: Colors.blue),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Upload button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadFile,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isUploading ? 'Uploading...' : 'Submit Application'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Status message
                if (_uploadStatus.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _hasError ? Colors.red[50] : Colors.green[50],
                      border: Border(
                        left: BorderSide(
                          color: _hasError ? Colors.red : Colors.green,
                          width: 4,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      _uploadStatus,
                      style: TextStyle(
                        color: _hasError ? Colors.red[700] : Colors.green[700],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStepItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget buildFormatTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Column')),
          DataColumn(label: Text('Data Type')),
          DataColumn(label: Text('Example')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('Loan ID')),
            DataCell(Text('Text')),
            DataCell(Text('LOAN-2025-001')),
          ]),
          DataRow(cells: [
            DataCell(Text('Borrower Name')),
            DataCell(Text('Text')),
            DataCell(Text('John Smith')),
          ]),
          DataRow(cells: [
            DataCell(Text('Borrower ID')),
            DataCell(Text('Text')),
            DataCell(Text('ID12345678')),
          ]),
          DataRow(cells: [
            DataCell(Text('Lender Name')),
            DataCell(Text('Text')),
            DataCell(Text('First National Bank')),
          ]),
          DataRow(cells: [
            DataCell(Text('Original Loan Amount')),
            DataCell(Text('Number')),
            DataCell(Text('50000')),
          ]),
          DataRow(cells: [
            DataCell(Text('Current Outstanding')),
            DataCell(Text('Number')),
            DataCell(Text('35000')),
          ]),
          DataRow(cells: [
            DataCell(Text('Loan Start Date')),
            DataCell(Text('Date (MM/DD/YYYY)')),
            DataCell(Text('01/15/2023')),
          ]),
          DataRow(cells: [
            DataCell(Text('Property Address')),
            DataCell(Text('Text')),
            DataCell(Text('123 Main St, City')),
          ]),
          DataRow(cells: [
            DataCell(Text('Disaster Zone')),
            DataCell(Text('Text')),
            DataCell(Text('DZ-2025-003')),
          ]),
          DataRow(cells: [
            DataCell(Text('Relief Type Requested')),
            DataCell(Text('Text (FULL/HALF)')),
            DataCell(Text('HALF')),
          ]),
        ],
      ),
    );
  }
}