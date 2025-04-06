import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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
  bool _isEditing = false;
  
  // Template data
  List<String> _applicationSteps = [
    'Download the Excel template below',
    'Fill in your loan information exactly as shown in the guide',
    'Save the file (do not change the format)',
    'Upload the completed template',
    'Submit your application',
  ];
  
  List<String> _importantNotes = [
    'Do not rename, add, or remove any columns',
    'Do not change the sheet name',
    'All fields are mandatory',
    'Maximum file size: 5MB',
    'Only .xlsx format is accepted',
  ];
  
  List<Map<String, String>> _formatGuide = [
    {'Column': 'Loan ID', 'Data Type': 'Text', 'Example': 'LOAN-2025-001'},
    {'Column': 'Borrower Name', 'Data Type': 'Text', 'Example': 'John Smith'},
    {'Column': 'Borrower ID', 'Data Type': 'Text', 'Example': 'ID12345678'},
    {'Column': 'Lender Name', 'Data Type': 'Text', 'Example': 'First National Bank'},
    {'Column': 'Original Loan Amount', 'Data Type': 'Number', 'Example': '50000'},
    {'Column': 'Current Outstanding', 'Data Type': 'Number', 'Example': '35000'},
    {'Column': 'Loan Start Date', 'Data Type': 'Date (MM/DD/YYYY)', 'Example': '01/15/2023'},
    {'Column': 'Property Address', 'Data Type': 'Text', 'Example': '123 Main St, City'},
    {'Column': 'Disaster Zone', 'Data Type': 'Text', 'Example': 'DZ-2025-003'},
    {'Column': 'Relief Type Requested', 'Data Type': 'Text (FULL/HALF)', 'Example': 'HALF'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplateData();
  }
  
  Future<void> _loadTemplateData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load application steps
    final steps = prefs.getStringList('templateSteps');
    if (steps != null && steps.isNotEmpty) {
      setState(() {
        _applicationSteps = steps;
      });
    }
    
    // Load important notes
    final notes = prefs.getStringList('templateNotes');
    if (notes != null && notes.isNotEmpty) {
      setState(() {
        _importantNotes = notes;
      });
    }
    
    // Load format guide
    final formatJsonList = prefs.getStringList('templateFormat');
    if (formatJsonList != null && formatJsonList.isNotEmpty) {
      setState(() {
        _formatGuide = formatJsonList.map((item) {
          final parts = item.split('|');
          if (parts.length >= 3) {
            return {
              'Column': parts[0],
              'Data Type': parts[1],
              'Example': parts[2],
            };
          }
          return {'Column': '', 'Data Type': '', 'Example': ''};
        }).toList();
      });
    }
  }
  
  Future<void> _saveTemplateData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save application steps
    await prefs.setStringList('templateSteps', _applicationSteps);
    
    // Save important notes
    await prefs.setStringList('templateNotes', _importantNotes);
    
    // Save format guide
    List<String> formatStrings = _formatGuide.map((row) {
      return '${row['Column']}|${row['Data Type']}|${row['Example']}';
    }).toList();
    await prefs.setStringList('templateFormat', formatStrings);
    
    setState(() {
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template instructions saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

 Future<void> _downloadTemplate() async {
  try {
    // Request storage permission
    final status = await Permission.storage.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the download directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      directory = Directory('${directory?.path}/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!await directory!.exists()) {
      await directory.create(recursive: true);
    }

    // Create sample Excel content (in real app, use a proper template)
    const String templateContent = '''
Loan ID,Borrower Name,Borrower ID,Lender Name,Original Loan Amount,Current Outstanding,Loan Start Date,Property Address,Disaster Zone,Relief Type Requested
LOAN-2025-001,John Smith,ID12345678,First National Bank,50000,35000,01/15/2023,123 Main St, City,DZ-2025-003,HALF
''';

    // Save the file
    final filePath = '${directory.path}/Loan_Relief_Template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final File file = File(filePath);
    await file.writeAsString(templateContent);

    // Open the file (optional)
    await OpenFile.open(filePath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template downloaded to: $filePath'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to download template: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
    debugPrint('Download error: $e');
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

    await Future.delayed(const Duration(seconds: 2));

    if (path.extension(_selectedFile!.path).toLowerCase() != '.xlsx') {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Invalid file format. Only Excel (.xlsx) files are accepted';
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isUploading = false;
      _uploadStatus = 'File uploaded successfully! Your application is being processed.';
      _hasError = false;
    });
  }
  
  void _addStep() {
    setState(() {
      _applicationSteps.add('New step');
    });
  }
  
  void _removeStep(int index) {
    if (_applicationSteps.length > 1) {
      setState(() {
        _applicationSteps.removeAt(index);
      });
    }
  }
  
  void _addNote() {
    setState(() {
      _importantNotes.add('New note');
    });
  }
  
  void _removeNote(int index) {
    if (_importantNotes.length > 1) {
      setState(() {
        _importantNotes.removeAt(index);
      });
    }
  }
  
  void _addFormatRow() {
    setState(() {
      _formatGuide.add({
        'Column': 'New Column',
        'Data Type': 'Text',
        'Example': 'Example',
      });
    });
  }
  
  void _removeFormatRow(int index) {
    if (_formatGuide.length > 1) {
      setState(() {
        _formatGuide.removeAt(index);
      });
    }
  }

  void _toggleEditMode() {
    if (_isEditing) {
      _saveTemplateData();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Relief Loan Assistance'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Save changes' : 'Edit template',
          ),
        ],
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
                        
                        // Steps list
                        ...List.generate(_applicationSteps.length, (index) {
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
                                    (index + 1).toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _isEditing
                                      ? TextField(
                                          controller: TextEditingController(text: _applicationSteps[index]),
                                          onChanged: (value) => _applicationSteps[index] = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        )
                                      : Text(
                                          _applicationSteps[index],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                ),
                                if (_isEditing)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeStep(index),
                                  ),
                              ],
                            ),
                          );
                        }),
                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: _addStep,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Step'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                              ),
                            ),
                          ),
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
                        
                        // Format table
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Column')),
                              const DataColumn(label: Text('Data Type')),
                              const DataColumn(label: Text('Example')),
                              if (_isEditing) const DataColumn(label: Text('Actions')),
                            ],
                            rows: List.generate(_formatGuide.length, (index) {
                              final row = _formatGuide[index];
                              return DataRow(cells: [
                                DataCell(
                                  _isEditing
                                      ? TextField(
                                          controller: TextEditingController(text: row['Column']),
                                          onChanged: (value) => row['Column'] = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                        )
                                      : Text(row['Column'] ?? ''),
                                ),
                                DataCell(
                                  _isEditing
                                      ? TextField(
                                          controller: TextEditingController(text: row['Data Type']),
                                          onChanged: (value) => row['Data Type'] = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                        )
                                      : Text(row['Data Type'] ?? ''),
                                ),
                                DataCell(
                                  _isEditing
                                      ? TextField(
                                          controller: TextEditingController(text: row['Example']),
                                          onChanged: (value) => row['Example'] = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                        )
                                      : Text(row['Example'] ?? ''),
                                ),
                                if (_isEditing)
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeFormatRow(index),
                                    ),
                                  ),
                              ]);
                            }),
                          ),
                        ),
                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: _addFormatRow,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Column'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        const Text(
                          'Important Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Notes list
                        ...List.generate(_importantNotes.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('• ', 
                                  style: TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Expanded(
                                  child: _isEditing
                                      ? TextField(
                                          controller: TextEditingController(text: _importantNotes[index]),
                                          onChanged: (value) => _importantNotes[index] = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        )
                                      : Text(
                                          _importantNotes[index],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                ),
                                if (_isEditing)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeNote(index),
                                  ),
                              ],
                            ),
                          );
                        }),
                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: _addNote,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Note'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // File upload area (hide in edit mode)
                if (!_isEditing) ...[
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
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}