import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanReliefUploadScreen extends StatefulWidget {
  final bool isSuperAdmin;
  
  const LoanReliefUploadScreen({
    Key? key, 
    this.isSuperAdmin = false
  }) : super(key: key);

  @override
  _LoanReliefUploadScreenState createState() => _LoanReliefUploadScreenState();
}

class _LoanReliefUploadScreenState extends State<LoanReliefUploadScreen> {
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _hasError = false;
  File? _selectedFile;
  bool _isEditing = false;
  
  // Template instructions data
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
  
  // Controllers for editing
  final List<TextEditingController> _stepControllers = [];
  final List<TextEditingController> _noteControllers = [];
  final List<Map<String, TextEditingController>> _formatControllers = [];
  
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
    
    // Load format guide (more complex, stored as JSON)
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
    
    // Initialize controllers
    _initializeControllers();
  }
  
  void _initializeControllers() {
    // Clear existing controllers
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    for (var controller in _noteControllers) {
      controller.dispose();
    }
    for (var controllerMap in _formatControllers) {
      controllerMap.values.forEach((controller) => controller.dispose());
    }
    
    _stepControllers.clear();
    _noteControllers.clear();
    _formatControllers.clear();
    
    // Initialize step controllers
    for (var step in _applicationSteps) {
      _stepControllers.add(TextEditingController(text: step));
    }
    
    // Initialize note controllers
    for (var note in _importantNotes) {
      _noteControllers.add(TextEditingController(text: note));
    }
    
    // Initialize format controllers
    for (var format in _formatGuide) {
      _formatControllers.add({
        'Column': TextEditingController(text: format['Column']),
        'Data Type': TextEditingController(text: format['Data Type']),
        'Example': TextEditingController(text: format['Example']),
      });
    }
  }
  
  Future<void> _saveTemplateData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save application steps
    List<String> updatedSteps = _stepControllers.map((controller) => controller.text).toList();
    await prefs.setStringList('templateSteps', updatedSteps);
    
    // Save important notes
    List<String> updatedNotes = _noteControllers.map((controller) => controller.text).toList();
    await prefs.setStringList('templateNotes', updatedNotes);
    
    // Save format guide
    List<String> formatStrings = _formatControllers.map((controllerMap) {
      return '${controllerMap['Column']!.text}|${controllerMap['Data Type']!.text}|${controllerMap['Example']!.text}';
    }).toList();
    await prefs.setStringList('templateFormat', formatStrings);
    
    // Update state
    setState(() {
      _applicationSteps = updatedSteps;
      _importantNotes = updatedNotes;
      _formatGuide = List.generate(_formatControllers.length, (index) {
        return {
          'Column': _formatControllers[index]['Column']!.text,
          'Data Type': _formatControllers[index]['Data Type']!.text,
          'Example': _formatControllers[index]['Example']!.text,
        };
      });
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
  
  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController(text: 'New step'));
    });
  }
  
  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }
  
  void _addNote() {
    setState(() {
      _noteControllers.add(TextEditingController(text: 'New note'));
    });
  }
  
  void _removeNote(int index) {
    if (_noteControllers.length > 1) {
      setState(() {
        _noteControllers[index].dispose();
        _noteControllers.removeAt(index);
      });
    }
  }
  
  void _addFormatRow() {
    setState(() {
      _formatControllers.add({
        'Column': TextEditingController(text: 'New Column'),
        'Data Type': TextEditingController(text: 'Text'),
        'Example': TextEditingController(text: 'Example'),
      });
    });
  }
  
  void _removeFormatRow(int index) {
    if (_formatControllers.length > 1) {
      setState(() {
        _formatControllers[index].values.forEach((controller) => controller.dispose());
        _formatControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Relief Loan Assistance'),
        backgroundColor: Colors.blue[800],
        actions: widget.isSuperAdmin ? [
          // Admin toggle edit mode button
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveTemplateData();
              } else {
                setState(() {
                  _isEditing = true;
                  _initializeControllers();
                });
              }
            },
            tooltip: _isEditing ? 'Save changes' : 'Edit template instructions',
          ),
        ] : null,
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
                        
                        // Edit mode: steps with text fields
                        if (_isEditing) ...[
                          ...List.generate(_stepControllers.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
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
                                    child: TextField(
                                      controller: _stepControllers[index],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeStep(index),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            );
                          }),
                          ElevatedButton.icon(
                            onPressed: _addStep,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Step'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                            ),
                          ),
                        ]
                        // View mode: display steps
                        else ...[
                          ...List.generate(_applicationSteps.length, (index) {
                            return buildStepItem(index + 1, _applicationSteps[index]);
                          }),
                        ],
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
                        
                        // Format table (editable or view-only)
                        _isEditing ? buildEditableFormatTable() : buildFormatTable(),
                        
                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: _addFormatRow,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Row'),
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
                        
                        // Edit mode: notes with text fields
                        if (_isEditing) ...[
                          ...List.generate(_noteControllers.length, (index) {
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
                                    child: TextField(
                                      controller: _noteControllers[index],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeNote(index),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            );
                          }),
                          ElevatedButton.icon(
                            onPressed: _addNote,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Note'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                            ),
                          ),
                        ]
                        // View mode: display notes
                        else ...[
                          ...List.generate(_importantNotes.length, (index) {
                            return buildBulletPoint(_importantNotes[index]);
                          }),
                        ],
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
        rows: _formatGuide.map((row) {
          return DataRow(cells: [
            DataCell(Text(row['Column'] ?? '')),
            DataCell(Text(row['Data Type'] ?? '')),
            DataCell(Text(row['Example'] ?? '')),
          ]);
        }).toList(),
      ),
    );
  }
  
  Widget buildEditableFormatTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Column')),
          DataColumn(label: Text('Data Type')),
          DataColumn(label: Text('Example')),
          DataColumn(label: Text('Action')),
        ],
        rows: List.generate(_formatControllers.length, (index) {
          return DataRow(cells: [
            DataCell(
              TextField(
                controller: _formatControllers[index]['Column'],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            DataCell(
              TextField(
                controller: _formatControllers[index]['Data Type'],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            DataCell(
              TextField(
                controller: _formatControllers[index]['Example'],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFormatRow(index),
              ),
            ),
          ]);
        }),
      ),
    );
  }
  
  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    for (var controller in _noteControllers) {
      controller.dispose();
    }
    for (var controllerMap in _formatControllers) {
      controllerMap.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }
}

// Example of how to use the widget with superadmin flag
class MainNavigationScreen extends StatelessWidget {
  final bool isSuperAdmin = true; // This would be determined by your auth system
  
  const MainNavigationScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disaster Relief System')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoanReliefUploadScreen(isSuperAdmin: isSuperAdmin),
              ),
            );
          },
          child: const Text('Go to Loan Relief Upload'),
        ),
      ),
    );
  }
}