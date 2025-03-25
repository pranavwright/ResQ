import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart' show OpenFile;

class FamilyDataDownloadScreen extends StatefulWidget {
  @override
  _FamilyDataDownloadScreenState createState() => _FamilyDataDownloadScreenState();
}

class _FamilyDataDownloadScreenState extends State<FamilyDataDownloadScreen> {
  // Family filters
  final TextEditingController _minIncomeController = TextEditingController();
  final TextEditingController _maxIncomeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _currentResidenceController = TextEditingController();
  final TextEditingController _wardNumberController = TextEditingController();
  bool _outsideDamagedArea = false;
  bool _receivedAllowance = false;

  // Individual filters
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _status = 'All';
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  String _gender = 'All';
  String _education = 'All';
  String _incomeSource = 'All';
  final TextEditingController _skillsController = TextEditingController();
  bool _needsEmployment = false;
  bool _needsAssistance = false;
  bool _hasHealthIssue = false;
  bool _isBedridden = false;
  bool _needsCounselling = false;
  String _preferredRehabilitation = 'All';

  List<Family> families = [];
  List<Family> filteredFamilies = [];
  FamilyDataSource? familyDataSource;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    filteredFamilies = List.from(families);
    familyDataSource = FamilyDataSource(families: filteredFamilies);
  }

  @override
  void dispose() {
    _minIncomeController.dispose();
    _maxIncomeController.dispose();
    _addressController.dispose();
    _currentResidenceController.dispose();
    _wardNumberController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    // Comprehensive mock data
    families = [
      Family(
        id: 'F001',
        minIncome: 10000,
        maxIncome: 15000,
        address: '123 Main St, Disaster Zone A',
        currentResidence: 'Temporary Shelter A',
        wardNumber: '5',
        outsideDamagedArea: true,
        receivedAllowance: true,
        members: [
          FamilyMember(
            name: 'John Doe',
            age: 35,
            status: 'Alive',
            gender: 'Male',
            education: 'High School',
            incomeSource: 'Construction',
            skills: 'Carpentry, Masonry',
            needsEmployment: true,
            needsAssistance: false,
            hasHealthIssue: false,
            isBedridden: false,
            needsCounselling: true,
            preferredRehabilitation: 'Temporary',
          ),
          FamilyMember(
            name: 'Jane Doe',
            age: 32,
            status: 'Alive',
            gender: 'Female',
            education: 'College',
            incomeSource: 'Teaching',
            skills: 'Teaching, First Aid',
            needsEmployment: false,
            needsAssistance: true,
            hasHealthIssue: true,
            isBedridden: false,
            needsCounselling: false,
            preferredRehabilitation: 'Rent',
          ),
          FamilyMember(
            name: 'Baby Doe',
            age: 2,
            status: 'Alive',
            gender: 'Other',
            education: 'None',
            incomeSource: 'None',
            skills: '',
            needsEmployment: false,
            needsAssistance: true,
            hasHealthIssue: false,
            isBedridden: false,
            needsCounselling: false,
            preferredRehabilitation: 'Government',
          ),
        ],
      ),
      Family(
        id: 'F002',
        minIncome: 8000,
        maxIncome: 12000,
        address: '456 Oak Ave, Disaster Zone B',
        currentResidence: 'With Relatives',
        wardNumber: '3',
        outsideDamagedArea: false,
        receivedAllowance: false,
        members: [
          FamilyMember(
            name: 'Robert Smith',
            age: 45,
            status: 'Alive',
            gender: 'Male',
            education: 'Primary',
            incomeSource: 'Agriculture',
            skills: 'Farming, Animal Husbandry',
            needsEmployment: true,
            needsAssistance: false,
            hasHealthIssue: true,
            isBedridden: false,
            needsCounselling: true,
            preferredRehabilitation: 'Friends House',
          ),
          FamilyMember(
            name: 'Maria Smith',
            age: 40,
            status: 'Alive',
            gender: 'Female',
            education: 'High School',
            incomeSource: 'Daily Wage',
            skills: 'Cleaning, Cooking',
            needsEmployment: true,
            needsAssistance: true,
            hasHealthIssue: false,
            isBedridden: false,
            needsCounselling: false,
            preferredRehabilitation: 'Temporary',
          ),
        ],
      ),
      Family(
        id: 'F003',
        minIncome: 20000,
        maxIncome: 25000,
        address: '789 Pine Rd, Disaster Zone A',
        currentResidence: 'Rented Apartment',
        wardNumber: '5',
        outsideDamagedArea: true,
        receivedAllowance: true,
        members: [
          FamilyMember(
            name: 'David Johnson',
            age: 50,
            status: 'Alive',
            gender: 'Male',
            education: 'University',
            incomeSource: 'Business',
            skills: 'Management, Accounting',
            needsEmployment: false,
            needsAssistance: false,
            hasHealthIssue: false,
            isBedridden: false,
            needsCounselling: false,
            preferredRehabilitation: 'Rent',
          ),
          FamilyMember(
            name: 'Sarah Johnson',
            age: 48,
            status: 'Dead',
            gender: 'Female',
            education: 'College',
            incomeSource: 'None',
            skills: 'Teaching, Nursing',
            needsEmployment: false,
            needsAssistance: false,
            hasHealthIssue: true,
            isBedridden: true,
            needsCounselling: true,
            preferredRehabilitation: 'Government',
          ),
        ],
      ),
      Family(
        id: 'F004',
        minIncome: 5000,
        maxIncome: 7000,
        address: '321 Elm St, Disaster Zone C',
        currentResidence: 'Temporary Shelter B',
        wardNumber: '2',
        outsideDamagedArea: false,
        receivedAllowance: true,
        members: [
          FamilyMember(
            name: 'Michael Brown',
            age: 60,
            status: 'Alive',
            gender: 'Male',
            education: 'Primary',
            incomeSource: 'Daily Wage',
            skills: 'Labor, Driving',
            needsEmployment: true,
            needsAssistance: true,
            hasHealthIssue: true,
            isBedridden: false,
            needsCounselling: true,
            preferredRehabilitation: 'Government',
          ),
          FamilyMember(
            name: 'Emily Brown',
            age: 55,
            status: 'Alive',
            gender: 'Female',
            education: 'None',
            incomeSource: 'None',
            skills: 'Cooking, Sewing',
            needsEmployment: false,
            needsAssistance: true,
            hasHealthIssue: true,
            isBedridden: true,
            needsCounselling: true,
            preferredRehabilitation: 'Government',
          ),
        ],
      ),
    ];
  }

  void _resetFilters() {
    setState(() {
      // Reset family filters
      _minIncomeController.clear();
      _maxIncomeController.clear();
      _addressController.clear();
      _currentResidenceController.clear();
      _wardNumberController.clear();
      _outsideDamagedArea = false;
      _receivedAllowance = false;

      // Reset individual filters
      _nameController.clear();
      _ageController.clear();
      _status = 'All';
      _minAgeController.clear();
      _maxAgeController.clear();
      _gender = 'All';
      _education = 'All';
      _incomeSource = 'All';
      _skillsController.clear();
      _needsEmployment = false;
      _needsAssistance = false;
      _hasHealthIssue = false;
      _isBedridden = false;
      _needsCounselling = false;
      _preferredRehabilitation = 'All';

      // Reset filtered data
      filteredFamilies = List.from(families);
      familyDataSource = FamilyDataSource(families: filteredFamilies);
    });
  }

  void _applyFilters() {
    setState(() {
      filteredFamilies = families.where((family) {
        // Apply family filters
        if (_minIncomeController.text.isNotEmpty && 
            family.minIncome < int.parse(_minIncomeController.text)) {
          return false;
        }
        if (_maxIncomeController.text.isNotEmpty && 
            family.maxIncome > int.parse(_maxIncomeController.text)) {
          return false;
        }
        if (_addressController.text.isNotEmpty && 
            !family.address.toLowerCase().contains(_addressController.text.toLowerCase())) {
          return false;
        }
        if (_currentResidenceController.text.isNotEmpty && 
            !family.currentResidence.toLowerCase().contains(_currentResidenceController.text.toLowerCase())) {
          return false;
        }
        if (_wardNumberController.text.isNotEmpty && 
            family.wardNumber != _wardNumberController.text) {
          return false;
        }
        if (_outsideDamagedArea && !family.outsideDamagedArea) {
          return false;
        }
        if (_receivedAllowance && !family.receivedAllowance) {
          return false;
        }

        // Apply individual filters
        bool hasMatchingMember = family.members.any((member) {
          if (_nameController.text.isNotEmpty && 
              !member.name.toLowerCase().contains(_nameController.text.toLowerCase())) {
            return false;
          }
          if (_ageController.text.isNotEmpty && 
              member.age != int.parse(_ageController.text)) {
            return false;
          }
          if (_status != 'All' && member.status != _status) {
            return false;
          }
          if (_minAgeController.text.isNotEmpty && 
              member.age < int.parse(_minAgeController.text)) {
            return false;
          }
          if (_maxAgeController.text.isNotEmpty && 
              member.age > int.parse(_maxAgeController.text)) {
            return false;
          }
          if (_gender != 'All' && member.gender != _gender) {
            return false;
          }
          if (_education != 'All' && member.education != _education) {
            return false;
          }
          if (_incomeSource != 'All' && member.incomeSource != _incomeSource) {
            return false;
          }
          if (_skillsController.text.isNotEmpty && 
              !member.skills.toLowerCase().contains(_skillsController.text.toLowerCase())) {
            return false;
          }
          if (_needsEmployment && !member.needsEmployment) {
            return false;
          }
          if (_needsAssistance && !member.needsAssistance) {
            return false;
          }
          if (_hasHealthIssue && !member.hasHealthIssue) {
            return false;
          }
          if (_isBedridden && !member.isBedridden) {
            return false;
          }
          if (_needsCounselling && !member.needsCounselling) {
            return false;
          }
          if (_preferredRehabilitation != 'All' && 
              member.preferredRehabilitation != _preferredRehabilitation) {
            return false;
          }
          return true;
        });

        return hasMatchingMember;
      }).toList();

      familyDataSource = FamilyDataSource(families: filteredFamilies);
    });
  }

  Future<void> _exportToExcel() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Add headers
    sheet.getRangeByIndex(1, 1).setText('Family ID');
    sheet.getRangeByIndex(1, 2).setText('Min Income');
    sheet.getRangeByIndex(1, 3).setText('Max Income');
    sheet.getRangeByIndex(1, 4).setText('Address');
    sheet.getRangeByIndex(1, 5).setText('Current Residence');
    sheet.getRangeByIndex(1, 6).setText('Ward Number');
    sheet.getRangeByIndex(1, 7).setText('Outside Damaged Area');
    sheet.getRangeByIndex(1, 8).setText('Received Allowance');
    sheet.getRangeByIndex(1, 9).setText('Member Name');
    sheet.getRangeByIndex(1, 10).setText('Age');
    sheet.getRangeByIndex(1, 11).setText('Status');
    sheet.getRangeByIndex(1, 12).setText('Gender');
    sheet.getRangeByIndex(1, 13).setText('Education');
    sheet.getRangeByIndex(1, 14).setText('Income Source');
    sheet.getRangeByIndex(1, 15).setText('Skills');
    sheet.getRangeByIndex(1, 16).setText('Needs Employment');
    sheet.getRangeByIndex(1, 17).setText('Needs Assistance');
    sheet.getRangeByIndex(1, 18).setText('Has Health Issue');
    sheet.getRangeByIndex(1, 19).setText('Is Bedridden');
    sheet.getRangeByIndex(1, 20).setText('Needs Counselling');
    sheet.getRangeByIndex(1, 21).setText('Preferred Rehabilitation');

    // Add data
    int row = 2;
    for (var family in filteredFamilies) {
      for (var member in family.members) {
        sheet.getRangeByIndex(row, 1).setText(family.id);
        sheet.getRangeByIndex(row, 2).setNumber(family.minIncome.toDouble());
        sheet.getRangeByIndex(row, 3).setNumber(family.maxIncome.toDouble());
        sheet.getRangeByIndex(row, 4).setText(family.address);
        sheet.getRangeByIndex(row, 5).setText(family.currentResidence);
        sheet.getRangeByIndex(row, 6).setText(family.wardNumber);
        sheet.getRangeByIndex(row, 7).setText(family.outsideDamagedArea ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 8).setText(family.receivedAllowance ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 9).setText(member.name);
        sheet.getRangeByIndex(row, 10).setNumber(member.age.toDouble());
        sheet.getRangeByIndex(row, 11).setText(member.status);
        sheet.getRangeByIndex(row, 12).setText(member.gender);
        sheet.getRangeByIndex(row, 13).setText(member.education);
        sheet.getRangeByIndex(row, 14).setText(member.incomeSource);
        sheet.getRangeByIndex(row, 15).setText(member.skills);
        sheet.getRangeByIndex(row, 16).setText(member.needsEmployment ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 17).setText(member.needsAssistance ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 18).setText(member.hasHealthIssue ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 19).setText(member.isBedridden ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 20).setText(member.needsCounselling ? 'Yes' : 'No');
        sheet.getRangeByIndex(row, 21).setText(member.preferredRehabilitation);
        row++;
      }
    }

    // Save and launch the file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/FamilyData_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Data Download'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportToExcel,
            tooltip: 'Download as Excel',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection(),
              SizedBox(height: 20),
              _buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text('Reset All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Family Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minIncomeController,
                    decoration: InputDecoration(
                      labelText: 'Min Income',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxIncomeController,
                    decoration: InputDecoration(
                      labelText: 'Max Income',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _currentResidenceController,
              decoration: InputDecoration(
                labelText: 'Current Residence',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Ward Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Outside Damaged Area'),
                    value: _outsideDamagedArea,
                    onChanged: (value) {
                      setState(() {
                        _outsideDamagedArea = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Received Allowance'),
                    value: _receivedAllowance,
                    onChanged: (value) {
                      setState(() {
                        _receivedAllowance = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
            Divider(),
            Text('Individual Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'Alive', 'Dead'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? 'All';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAgeController,
                    decoration: InputDecoration(
                      labelText: 'Min Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxAgeController,
                    decoration: InputDecoration(
                      labelText: 'Max Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value ?? 'All';
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _education,
                    decoration: InputDecoration(
                      labelText: 'Education',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'None', 'Primary', 'High School', 'College', 'University'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _education = value ?? 'All';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _incomeSource,
              decoration: InputDecoration(
                labelText: 'Income Source',
                border: OutlineInputBorder(),
              ),
              items: ['All', 'Agriculture', 'Construction', 'Teaching', 'Business', 'Daily Wage', 'None'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _incomeSource = value ?? 'All';
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _skillsController,
              decoration: InputDecoration(
                labelText: 'Skills',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilterChip(
                  label: Text('Needs Employment'),
                  selected: _needsEmployment,
                  onSelected: (bool selected) {
                    setState(() {
                      _needsEmployment = selected;
                    });
                  },
                ),
                FilterChip(
                  label: Text('Needs Assistance'),
                  selected: _needsAssistance,
                  onSelected: (bool selected) {
                    setState(() {
                      _needsAssistance = selected;
                    });
                  },
                ),
                FilterChip(
                  label: Text('Has Health Issue'),
                  selected: _hasHealthIssue,
                  onSelected: (bool selected) {
                    setState(() {
                      _hasHealthIssue = selected;
                    });
                  },
                ),
                FilterChip(
                  label: Text('Is Bedridden'),
                  selected: _isBedridden,
                  onSelected: (bool selected) {
                    setState(() {
                      _isBedridden = selected;
                    });
                  },
                ),
                FilterChip(
                  label: Text('Needs Counselling'),
                  selected: _needsCounselling,
                  onSelected: (bool selected) {
                    setState(() {
                      _needsCounselling = selected;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _preferredRehabilitation,
              decoration: InputDecoration(
                labelText: 'Preferred Rehabilitation',
                border: OutlineInputBorder(),
              ),
              items: ['All', 'Government', 'Friends House', 'Temporary', 'Rent'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _preferredRehabilitation = value ?? 'All';
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetFilters,
                  child: Text('Reset Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Filtered Families: ${filteredFamilies.length}', 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SfDataGrid(
                source: familyDataSource!,
                columnWidthMode: ColumnWidthMode.fill,
                columns: [
                  GridColumn(
                    columnName: 'id',
                    label: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Family ID'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'income',
                    label: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Income Range'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'address',
                    label: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Address'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'residence',
                    label: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Current Residence'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'members',
                    label: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Members Count'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Family {
  final String id;
  final int minIncome;
  final int maxIncome;
  final String address;
  final String currentResidence;
  final String wardNumber;
  final bool outsideDamagedArea;
  final bool receivedAllowance;
  final List<FamilyMember> members;

  Family({
    required this.id,
    required this.minIncome,
    required this.maxIncome,
    required this.address,
    required this.currentResidence,
    required this.wardNumber,
    required this.outsideDamagedArea,
    required this.receivedAllowance,
    required this.members,
  });
}

class FamilyMember {
  final String name;
  final int age;
  final String status;
  final String gender;
  final String education;
  final String incomeSource;
  final String skills;
  final bool needsEmployment;
  final bool needsAssistance;
  final bool hasHealthIssue;
  final bool isBedridden;
  final bool needsCounselling;
  final String preferredRehabilitation;

  FamilyMember({
    required this.name,
    required this.age,
    required this.status,
    required this.gender,
    required this.education,
    required this.incomeSource,
    required this.skills,
    required this.needsEmployment,
    required this.needsAssistance,
    required this.hasHealthIssue,
    required this.isBedridden,
    required this.needsCounselling,
    required this.preferredRehabilitation,
  });
}

class FamilyDataSource extends DataGridSource {
  FamilyDataSource({required List<Family> families}) {
    _families = families;
    buildDataGridRows();
  }

  List<Family> _families = [];
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(dataGridCell.value.toString()),
      );
    }).toList());
  }

  void buildDataGridRows() {
    _dataGridRows = _families.map<DataGridRow>((family) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: family.id),
        DataGridCell<String>(
            columnName: 'income',
            value: '${family.minIncome} - ${family.maxIncome}'),
        DataGridCell<String>(columnName: 'address', value: family.address),
        DataGridCell<String>(
            columnName: 'residence', value: family.currentResidence),
        DataGridCell<String>(
            columnName: 'members', value: '${family.members.length}'),
      ]);
    }).toList();
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
