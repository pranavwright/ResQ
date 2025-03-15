import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class FamilyDataScreen extends StatefulWidget {
  const FamilyDataScreen({Key? key}) : super(key: key);

  @override
  _FamilyDataScreenState createState() => _FamilyDataScreenState();
}

class _FamilyDataScreenState extends State<FamilyDataScreen> {
  List<Map<String, dynamic>> allFamilies = [];
  List<Map<String, dynamic>> filteredFamilies = [];

  final TextEditingController _minIncomeController = TextEditingController();
  final TextEditingController _maxIncomeController = TextEditingController();
  String? _selectedAddress;
  String? _selectedResidence;
  String? _selectedWard;
  bool? _outsideDamagedArea;
  bool? _receivedAllowance;

  String? _selectedName;
  String? _selectedStatus;
  RangeValues _ageRange = const RangeValues(0, 100);
  String? _selectedGender;
  String? _selectedEducation;
  String? _selectedIncomeSource;
  String? _selectedSkill;
  bool? _needsEmploymentAssistance;
  bool? _hasHealthIssue;
  bool? _isBedridden;
  bool? _needsCounselling;
  bool? _needsAssistiveDevices;
  String? _selectedRehabOption;

  final List<String> addresses = ['Address 1', 'Address 2', 'Address 3'];
  final List<String> residences = ['Residence 1', 'Residence 2', 'Residence 3'];
  final List<String> wards = ['Ward 1', 'Ward 2', 'Ward 3', 'Ward 4', 'Ward 5'];
  final List<String> statuses = ['Alive', 'Dead'];
  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> educationSources = [
    'School',
    'College',
    'University',
    'None',
  ];
  final List<String> incomeSources = [
    'Employment',
    'Business',
    'Pension',
    'Aid',
  ];
  final List<String> skills = [
    'Carpentry',
    'Plumbing',
    'Cooking',
    'Medical',
    'IT',
    'Teaching',
  ];
  final List<String> rehabOptions = [
    'Rent',
    "Relative's House",
    'Temporary Shelter',
    'Permanent Housing',
  ];

  @override
  void initState() {
    super.initState();
    _generateMockData();
    filteredFamilies = List.from(allFamilies);
  }

  void _generateMockData() {
    for (int i = 0; i < 20; i++) {
      final family = {
        'id': 'FAM${100 + i}',
        'address': addresses[i % addresses.length],
        'currentResidence': residences[i % residences.length],
        'wardNumber': wards[i % wards.length],
        'outsideDamagedArea': i % 2 == 0,
        'receivedAllowance': i % 3 == 0,
        'totalIncome': 5000 + (i * 1000),
        'individuals': <Map<String, dynamic>>[],
      };

      final memberCount = 2 + (i % 4);
      for (int j = 0; j < memberCount; j++) {
        (family['individuals'] as List<Map<String, dynamic>>).add({
          'name': 'Person ${i}-${j}',
          'status': statuses[j % statuses.length],
          'age': 20 + (i + j) % 60,
          'gender': genders[j % genders.length],
          'educationSource': educationSources[j % educationSources.length],
          'incomeSource': incomeSources[j % incomeSources.length],
          'skills': skills[(i + j) % skills.length],
          'needsEmploymentAssistance': j % 3 == 0,
          'hasHealthIssue': j % 4 == 0,
          'isBedridden': j % 7 == 0,
          'needsCounselling': j % 5 == 0,
          'needsAssistiveDevices': j % 6 == 0,
          'preferredRehabOption': rehabOptions[j % rehabOptions.length],
        });
      }

      allFamilies.add(family);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredFamilies = allFamilies.where((family) {
        final int totalIncome = family['totalIncome'] as int;
        final minIncome = _minIncomeController.text.isEmpty
            ? 0
            : int.parse(_minIncomeController.text);
        final maxIncome = _maxIncomeController.text.isEmpty
            ? double.infinity.toInt()
            : int.parse(_maxIncomeController.text);

        bool matchesFamily = true;
        if (totalIncome < minIncome || totalIncome > maxIncome) {
          matchesFamily = false;
        }
        if (_selectedAddress != null && family['address'] != _selectedAddress) {
          matchesFamily = false;
        }
        if (_selectedResidence != null &&
            family['currentResidence'] != _selectedResidence) {
          matchesFamily = false;
        }
        if (_selectedWard != null && family['wardNumber'] != _selectedWard) {
          matchesFamily = false;
        }
        if (_outsideDamagedArea != null &&
            family['outsideDamagedArea'] != _outsideDamagedArea) {
          matchesFamily = false;
        }
        if (_receivedAllowance != null &&
            family['receivedAllowance'] != _receivedAllowance) {
          matchesFamily = false;
        }

        if (!matchesFamily) {
          return false;
        }

        List<Map<String, dynamic>> individuals =
            List<Map<String, dynamic>>.from(family['individuals']);
        bool hasMatchingIndividual = false;

        for (var individual in individuals) {
          bool matchesIndividual = true;

          if (_selectedName != null &&
              !individual['name']
                  .toString()
                  .toLowerCase()
                  .contains(_selectedName!.toLowerCase())) {
            matchesIndividual = false;
          }
          if (_selectedStatus != null &&
              individual['status'] != _selectedStatus) {
            matchesIndividual = false;
          }

          final int age = individual['age'] as int;
          if (age < _ageRange.start || age > _ageRange.end) {
            matchesIndividual = false;
          }
          if (_selectedGender != null && individual['gender'] != _selectedGender) {
            matchesIndividual = false;
          }
          if (_selectedEducation != null &&
              individual['educationSource'] != _selectedEducation) {
            matchesIndividual = false;
          }
          if (_selectedIncomeSource != null &&
              individual['incomeSource'] != _selectedIncomeSource) {
            matchesIndividual = false;
          }
          if (_selectedSkill != null && individual['skills'] != _selectedSkill) {
            matchesIndividual = false;
          }
          if (_needsEmploymentAssistance != null &&
              individual['needsEmploymentAssistance'] !=
                  _needsEmploymentAssistance) {
            matchesIndividual = false;
          }
          if (_hasHealthIssue != null &&
              individual['hasHealthIssue'] != _hasHealthIssue) {
            matchesIndividual = false;
          }
          if (_isBedridden != null && individual['isBedridden'] != _isBedridden) {
            matchesIndividual = false;
          }
          if (_needsCounselling != null &&
              individual['needsCounselling'] != _needsCounselling) {
            matchesIndividual = false;
          }
          if (_needsAssistiveDevices != null &&
              individual['needsAssistiveDevices'] != _needsAssistiveDevices) {
            matchesIndividual = false;
          }
          if (_selectedRehabOption != null &&
              individual['preferredRehabOption'] != _selectedRehabOption) {
            matchesIndividual = false;
          }

          if (matchesIndividual) {
            hasMatchingIndividual = true;
            break;
          }
        }

        return hasMatchingIndividual;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _minIncomeController.clear();
      _maxIncomeController.clear();
      _selectedAddress = null;
      _selectedResidence = null;
      _selectedWard = null;
      _outsideDamagedArea = null;
      _receivedAllowance = null;

      _selectedName = null;
      _selectedStatus = null;
      _ageRange = const RangeValues(0, 100);
      _selectedGender = null;
      _selectedEducation = null;
      _selectedIncomeSource = null;
      _selectedSkill = null;
      _needsEmploymentAssistance = null;
      _hasHealthIssue = null;
      _isBedridden = null;
      _needsCounselling = null;
      _needsAssistiveDevices = null;
      _selectedRehabOption = null;

      filteredFamilies = List.from(allFamilies);
    });
  }

  Future<void> _generateAndDownloadExcel() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download files'),
          ),
        );
        return;
      }

      final excel = Excel.createExcel();
      final Sheet sheet = excel['Families Data'];

      final List<String> headerStrings = [
        'Family ID',
        'Address',
        'Current Residence',
        'Ward Number',
        'Outside Damaged Area',
        'Received Allowance',
        'Total Income',
        'Member Name',
        'Status',
        'Age',
        'Gender',
        'Education Source',
        'Income Source',
        'Skills',
        'Needs Employment Assistance',
        'Has Health Issue',
        'Is Bedridden',
        'Needs Counselling',
        'Needs Assistive Devices',
        'Preferred Rehab Option',
      ];
      
      final List<CellValue?> headers = headerStrings.map((header) => TextCellValue(header)).toList();
      sheet.appendRow(headers);

      for (var family in filteredFamilies) {
        for (var individual in family['individuals']) {
          final List<dynamic> rowData = [
            family['id'],
            family['address'],
            family['currentResidence'],
            family['wardNumber'],
            family['outsideDamagedArea'] ? 'Yes' : 'No',
            family['receivedAllowance'] ? 'Yes' : 'No',
            family['totalIncome'],
            individual['name'],
            individual['status'],
            individual['age'],
            individual['gender'],
            individual['educationSource'],
            individual['incomeSource'],
            individual['skills'],
            individual['needsEmploymentAssistance'] ? 'Yes' : 'No',
            individual['hasHealthIssue'] ? 'Yes' : 'No',
            individual['isBedridden'] ? 'Yes' : 'No',
            individual['needsCounselling'] ? 'Yes' : 'No',
            individual['needsAssistiveDevices'] ? 'Yes' : 'No',
            individual['preferredRehabOption'],
          ];
          // Convert each value to TextCellValue or other appropriate CellValue type
          final List<CellValue?> row = rowData.map((value) {
            if (value is int) {
              return IntCellValue(value);
            } else if (value is double) {
              return DoubleCellValue(value);
            } else if (value is bool) {
              return TextCellValue(value ? 'Yes' : 'No');
            } else {
              return TextCellValue(value.toString());
            }
          }).toList();
          sheet.appendRow(row);
        }
      }

      final directory =
          await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/family_data_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        final File file = File(filePath);
        await file.writeAsBytes(excelBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file downloaded to: $filePath')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating Excel file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generateAndDownloadExcel,
            tooltip: 'Download as Excel',
          ),
        ],
      ),

      // Removed the Expanded from the column's child and only keep a single scroll view for the entire screen.
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              title: const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Family Filters',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minIncomeController,
                              decoration: const InputDecoration(
                                labelText: 'Min Income',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _maxIncomeController,
                              decoration: const InputDecoration(
                                labelText: 'Max Income',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedAddress,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddress = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...addresses.map((address) {
                                  return DropdownMenuItem<String>(
                                    value: address,
                                    child: Text(address),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Current Residence',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedResidence,
                              onChanged: (value) {
                                setState(() {
                                  _selectedResidence = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...residences.map((residence) {
                                  return DropdownMenuItem<String>(
                                    value: residence,
                                    child: Text(residence),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Ward Number',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedWard,
                              onChanged: (value) {
                                setState(() {
                                  _selectedWard = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...wards.map((ward) {
                                  return DropdownMenuItem<String>(
                                    value: ward,
                                    child: Text(ward),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Outside Damaged Area',
                                border: OutlineInputBorder(),
                              ),
                              value: _outsideDamagedArea,
                              onChanged: (value) {
                                setState(() {
                                  _outsideDamagedArea = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Received Allowance',
                                border: OutlineInputBorder(),
                              ),
                              value: _receivedAllowance,
                              onChanged: (value) {
                                setState(() {
                                  _receivedAllowance = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Individual Filters',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search by Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedName = value.isEmpty ? null : value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedStatus,
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...statuses.map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...genders.map((gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
                          ),
                          RangeSlider(
                            values: _ageRange,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            labels: RangeLabels(
                              _ageRange.start.round().toString(),
                              _ageRange.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _ageRange = values;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Education Source',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedEducation,
                              onChanged: (value) {
                                setState(() {
                                  _selectedEducation = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...educationSources.map((source) {
                                  return DropdownMenuItem<String>(
                                    value: source,
                                    child: Text(source),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Income Source',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedIncomeSource,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIncomeSource = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...incomeSources.map((source) {
                                  return DropdownMenuItem<String>(
                                    value: source,
                                    child: Text(source),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Skills',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedSkill,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSkill = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...skills.map((skill) {
                                  return DropdownMenuItem<String>(
                                    value: skill,
                                    child: Text(skill),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Needs Employment Assistance',
                                border: OutlineInputBorder(),
                              ),
                              value: _needsEmploymentAssistance,
                              onChanged: (value) {
                                setState(() {
                                  _needsEmploymentAssistance = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Has Health Issue',
                                border: OutlineInputBorder(),
                              ),
                              value: _hasHealthIssue,
                              onChanged: (value) {
                                setState(() {
                                  _hasHealthIssue = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Is Bedridden',
                                border: OutlineInputBorder(),
                              ),
                              value: _isBedridden,
                              onChanged: (value) {
                                setState(() {
                                  _isBedridden = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Needs Counselling',
                                border: OutlineInputBorder(),
                              ),
                              value: _needsCounselling,
                              onChanged: (value) {
                                setState(() {
                                  _needsCounselling = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              decoration: const InputDecoration(
                                labelText: 'Needs Assistive Devices',
                                border: OutlineInputBorder(),
                              ),
                              value: _needsAssistiveDevices,
                              onChanged: (value) {
                                setState(() {
                                  _needsAssistiveDevices = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<bool?>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: true,
                                  child: Text('Yes'),
                                ),
                                DropdownMenuItem<bool?>(
                                  value: false,
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Preferred Rehab Option',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedRehabOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRehabOption = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ...rehabOptions.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _resetFilters,
                            child: const Text('Reset Filters'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _applyFilters,
                            child: const Text('Apply Filters'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredFamilies.length} families found',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download Excel'),
                    onPressed: _generateAndDownloadExcel,
                  ),
                ],
              ),
            ),
            // Removed Expanded; just use a SingleChildScrollView horizontally for the DataTable.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Family ID')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Ward')),
                  DataColumn(label: Text('Income')),
                  DataColumn(label: Text('Member')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Gender')),
                  DataColumn(label: Text('Education')),
                  DataColumn(label: Text('Income Source')),
                  DataColumn(label: Text('Skills')),
                  DataColumn(label: Text('Health Issues')),
                  DataColumn(label: Text('Rehab Option')),
                ],
                rows: _buildDataTableRows(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildDataTableRows() {
    final List<DataRow> rows = [];
    for (var family in filteredFamilies) {
      bool isFirstMember = true;
      for (var individual in family['individuals']) {
        rows.add(
          DataRow(
            cells: [
              DataCell(Text(isFirstMember ? family['id'] : '')),
              DataCell(Text(isFirstMember ? family['address'] : '')),
              DataCell(Text(isFirstMember ? family['wardNumber'] : '')),
              DataCell(
                Text(isFirstMember ? family['totalIncome'].toString() : ''),
              ),
              DataCell(Text(individual['name'])),
              DataCell(Text(individual['status'])),
              DataCell(Text(individual['age'].toString())),
              DataCell(Text(individual['gender'])),
              DataCell(Text(individual['educationSource'])),
              DataCell(Text(individual['incomeSource'])),
              DataCell(Text(individual['skills'])),
              DataCell(Text(individual['hasHealthIssue'] ? 'Yes' : 'No')),
              DataCell(Text(individual['preferredRehabOption'])),
            ],
          ),
        );
        isFirstMember = false;
      }
    }
    return rows;
  }

  @override
  void dispose() {
    _minIncomeController.dispose();
    _maxIncomeController.dispose();
    super.dispose();
  }
}

class PostDisasterApp extends StatelessWidget {
  const PostDisasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Disaster Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FamilyDataScreen(),
    );
  }
}
