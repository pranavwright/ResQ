import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:excel/excel.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/family_mock_data.dart';
import 'dart:typed_data';
class FamilyDataDownloadScreen extends StatefulWidget {
  final List<Map<String, String>> families;
  
  const FamilyDataDownloadScreen({super.key, required this.families});

  @override
  _FamilyDataDownloadScreenState createState() => _FamilyDataDownloadScreenState();
}

class _FamilyDataDownloadScreenState extends State<FamilyDataDownloadScreen> {
  final List<Family> allFamilies = generateMockFamilies();
  List<Family> filteredFamilies = [];
  
  // Family-level filters
  String? selectedVillageWard;
  String? selectedHouseNumber;
  String? selectedHouseholdHead;
  RangeValues incomeRange = const RangeValues(0, 50000);
  String? selectedShelterType;
  String? selectedRationCategory;
  String? selectedCaste;
  bool? outsideDamagedAreaFilter;
  bool? receivedAllowanceFilter;
  
  // Individual-level filters
  String? memberNameFilter;
  String? memberAgeFilter;
  RangeValues memberAgeRange = const RangeValues(0, 100);
  String? memberGenderFilter;
  String? memberEducationFilter;
  String? memberEmploymentTypeFilter;
  bool? memberUnemployedDueToDisasterFilter;
  bool? memberHasMedicalNeedsFilter;
  bool? memberIsBedriddenFilter;
  bool? memberNeedsCounsellingFilter;

  @override
  void initState() {
    super.initState();
    filteredFamilies = allFamilies;
  }

  void applyFilters() {
    setState(() {
      filteredFamilies = NeedAssessmentData.filterFamilies(
        allFamilies,
        villageWard: selectedVillageWard,
        houseNumber: selectedHouseNumber,
        householdHead: selectedHouseholdHead,
        minIncome: incomeRange.start,
        maxIncome: incomeRange.end,
        shelterType: selectedShelterType,
        rationCategory: selectedRationCategory,
        caste: selectedCaste,
        outsideDamagedArea: outsideDamagedAreaFilter,
        receivedAllowance: receivedAllowanceFilter,
        memberName: memberNameFilter,
        memberAge: memberAgeFilter,
        minAge: memberAgeRange.start.toInt(),
        maxAge: memberAgeRange.end.toInt(),
        memberGender: memberGenderFilter,
        memberEducation: memberEducationFilter,
        memberEmploymentType: memberEmploymentTypeFilter,
        memberUnemployedDueToDisaster: memberUnemployedDueToDisasterFilter,
        memberHasMedicalNeeds: memberHasMedicalNeedsFilter,
        memberIsBedridden: memberIsBedriddenFilter,
        memberNeedsCounselling: memberNeedsCounsellingFilter,
      );
    });
  }

  void resetFilters() {
    setState(() {
      selectedVillageWard = null;
      selectedHouseNumber = null;
      selectedHouseholdHead = null;
      incomeRange = const RangeValues(0, 50000);
      selectedShelterType = null;
      selectedRationCategory = null;
      selectedCaste = null;
      outsideDamagedAreaFilter = null;
      receivedAllowanceFilter = null;
      
      memberNameFilter = null;
      memberAgeFilter = null;
      memberAgeRange = const RangeValues(0, 100);
      memberGenderFilter = null;
      memberEducationFilter = null;
      memberEmploymentTypeFilter = null;
      memberUnemployedDueToDisasterFilter = null;
      memberHasMedicalNeedsFilter = null;
      memberIsBedriddenFilter = null;
      memberNeedsCounsellingFilter = null;
      
      filteredFamilies = allFamilies;
    });
  }

  Future<void> exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Family Data'];

    // Add headers
    sheet.appendRow([
      TextCellValue('Family ID'),
      TextCellValue('Village/Ward'),
      TextCellValue('House Number'),
      TextCellValue('Head of Household'),
      TextCellValue('Contact No'),
      TextCellValue('Ration Card'),
      TextCellValue('Ration Category'),
      TextCellValue('Caste'),
      TextCellValue('Shelter Type'),
      TextCellValue('Avg Monthly Income'),
      TextCellValue('Primary Income Source'),
      TextCellValue('Livelihood Affected'),
      TextCellValue('Number of Members'),
    ]);

    // Add data rows
    for (final family in filteredFamilies) {
      final data = family.data;
      if (data != null) {
        sheet.appendRow([
          TextCellValue(family.id),
          TextCellValue(data.villageWard),
          TextCellValue(data.houseNumber),
          TextCellValue(data.householdHead),
          TextCellValue(data.contactNo),
          TextCellValue(data.rationCardNo),
          TextCellValue(data.rationCategory),
          TextCellValue(data.caste),
          TextCellValue(data.shelterType),
          TextCellValue(data.avgMonthlyFamilyIncome.toString()),
          TextCellValue(data.primaryIncomeSource),
          TextCellValue(data.livelihoodAffected),
          TextCellValue(data.numMembers.toString()),
        ]);
      }
    }

    // Save the file
    final bytes = excel.save();
    if (bytes != null) {
      await FileSaver.instance.saveFile(
        name: 'family_data',
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully!')),
      );
    }
  }

  void _showFamilyDetails(Family family) {
    final data = family.data;
    if (data == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Family ${family.id} Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Head of Household:', data.householdHead),
                _buildDetailRow('Village/Ward:', data.villageWard),
                _buildDetailRow('House Number:', data.houseNumber),
                _buildDetailRow('Contact No:', data.contactNo),
                _buildDetailRow('Ration Card:', data.rationCardNo),
                _buildDetailRow('Ration Category:', data.rationCategory),
                _buildDetailRow('Caste:', data.caste),
                _buildDetailRow('Shelter Type:', data.shelterType),
                _buildDetailRow('Avg Monthly Income:', '₹${data.avgMonthlyFamilyIncome.toStringAsFixed(0)}'),
                _buildDetailRow('Primary Income Source:', data.primaryIncomeSource),
                _buildDetailRow('Livelihood Affected:', data.livelihoodAffected),
                _buildDetailRow('Number of Members:', data.numMembers.toString()),
                
                const SizedBox(height: 16),
                const Text('Family Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...data.members.map((member) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${member.name} (${member.age} years, ${member.gender})', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      _buildDetailRow('Relationship:', member.relationship),
                      _buildDetailRow('Education:', member.education),
                      _buildDetailRow('Employment:', member.employmentType),
                      if (member.specialMedicalRequirements?.isNotEmpty ?? false)
                        _buildDetailRow('Medical Needs:', member.specialMedicalRequirements!),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villageWards = NeedAssessmentData.getDistinctValues(allFamilies, 'villageWard');
    final shelterTypes = NeedAssessmentData.getDistinctValues(allFamilies, 'shelterType');
    final rationCategories = NeedAssessmentData.getDistinctValues(allFamilies, 'rationCategory');
    final castes = NeedAssessmentData.getDistinctValues(allFamilies, 'caste');
    final genders = NeedAssessmentData.getDistinctValues(allFamilies, 'gender');
    final educationLevels = NeedAssessmentData.getDistinctValues(allFamilies, 'education');
    final employmentTypes = NeedAssessmentData.getDistinctValues(allFamilies, 'employmentType');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Data Download'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportToExcel,
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family-level filters
              const Text('Family-Level Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildFilterDropdown('Village/Ward', villageWards, selectedVillageWard, (value) {
                setState(() {
                  selectedVillageWard = value;
                });
              }),
              _buildFilterTextField('House Number', (value) {
                setState(() {
                  selectedHouseNumber = value;
                });
              }),
              _buildFilterTextField('Head of Household', (value) {
                setState(() {
                  selectedHouseholdHead = value;
                });
              }),
              _buildRangeSlider(
                'Monthly Income Range: ₹${incomeRange.start.round()} - ₹${incomeRange.end.round()}',
                incomeRange,
                0,
                50000,
                (values) {
                  setState(() {
                    incomeRange = values;
                  });
                },
              ),
              _buildFilterDropdown('Shelter Type', shelterTypes, selectedShelterType, (value) {
                setState(() {
                  selectedShelterType = value;
                });
              }),
              _buildFilterDropdown('Ration Category', rationCategories, selectedRationCategory, (value) {
                setState(() {
                  selectedRationCategory = value;
                });
              }),
              _buildFilterDropdown('Caste', castes, selectedCaste, (value) {
                setState(() {
                  selectedCaste = value;
                });
              }),
              _buildCheckboxRow('Outside Damaged Area', outsideDamagedAreaFilter, (value) {
                setState(() {
                  outsideDamagedAreaFilter = value;
                });
              }),
              _buildCheckboxRow('Received Allowance', receivedAllowanceFilter, (value) {
                setState(() {
                  receivedAllowanceFilter = value;
                });
              }),

              const SizedBox(height: 20),
              
              // Individual-level filters
              const Text('Individual-Level Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildFilterTextField('Member Name', (value) {
                setState(() {
                  memberNameFilter = value;
                });
              }),
              _buildRangeSlider(
                'Age Range: ${memberAgeRange.start.round()} - ${memberAgeRange.end.round()} years',
                memberAgeRange,
                0,
                100,
                (values) {
                  setState(() {
                    memberAgeRange = values;
                  });
                },
              ),
              _buildFilterDropdown('Gender', genders, memberGenderFilter, (value) {
                setState(() {
                  memberGenderFilter = value;
                });
              }),
              _buildFilterDropdown('Education Level', educationLevels, memberEducationFilter, (value) {
                setState(() {
                  memberEducationFilter = value;
                });
              }),
              _buildFilterDropdown('Employment Type', employmentTypes, memberEmploymentTypeFilter, (value) {
                setState(() {
                  memberEmploymentTypeFilter = value;
                });
              }),
              _buildCheckboxRow('Unemployed Due to Disaster', memberUnemployedDueToDisasterFilter, (value) {
                setState(() {
                  memberUnemployedDueToDisasterFilter = value;
                });
              }),
              _buildCheckboxRow('Has Medical Needs', memberHasMedicalNeedsFilter, (value) {
                setState(() {
                  memberHasMedicalNeedsFilter = value;
                });
              }),
              _buildCheckboxRow('Is Bedridden', memberIsBedriddenFilter, (value) {
                setState(() {
                  memberIsBedriddenFilter = value;
                });
              }),
              _buildCheckboxRow('Needs Counselling', memberNeedsCounsellingFilter, (value) {
                setState(() {
                  memberNeedsCounsellingFilter = value;
                });
              }),

              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                  ElevatedButton(
                    onPressed: resetFilters,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              // Results count
              Text(
                'Showing ${filteredFamilies.length} of ${allFamilies.length} families',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),
              
              // Data table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
  columns: const [
    DataColumn(label: Text('Family ID')),
    DataColumn(label: Text('Head')),
    DataColumn(label: Text('Village/Ward')),
    DataColumn(label: Text('House No')),
    DataColumn(label: Text('Income (₹)')),
    DataColumn(label: Text('Members')),
    DataColumn(label: Text('Shelter')),
    DataColumn(label: Text('Ration Card')),
  ],
  rows: filteredFamilies.map((family) {
    final data = family.data;
    return DataRow(
      onSelectChanged: (_) => _showFamilyDetails(family),
      cells: [
        DataCell(Text(family.id)),
        DataCell(Text(data?.householdHead ?? 'N/A')),
        DataCell(Text(data?.villageWard ?? 'N/A')),
        DataCell(Text(data?.houseNumber ?? 'N/A')),
        DataCell(Text(data?.avgMonthlyFamilyIncome.toStringAsFixed(0) ?? 'N/A')),
        DataCell(Text(data != null ? data.members.length.toString() : '0')), // Updated this line
        DataCell(Text(data?.shelterType ?? 'N/A')),
        DataCell(Text(data?.rationCardNo ?? 'N/A')),
      ],
    );
  }).toList(),
),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: selectedValue,
        items: [
          const DropdownMenuItem(value: null, child: Text('All')),
          ...options.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilterTextField(String label, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRangeSlider(String label, RangeValues values, double min, double max, ValueChanged<RangeValues> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: 10,
            labels: RangeLabels(
              values.start.round().toString(),
              values.end.round().toString(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool? value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: value ?? false,
            onChanged: (val) {
              onChanged(val);
            },
            tristate: true,
          ),
          Text(label),
        ],
      ),
    );
  }
}