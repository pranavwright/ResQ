import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:excel/excel.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'dart:typed_data';

import 'package:resq/utils/http/token_http.dart';

class FamilyDataDownloadScreen extends StatefulWidget {
  const FamilyDataDownloadScreen({super.key, required this.families});
  final List<Map<String, String>> families;

  @override
  _FamilyDataDownloadScreenState createState() =>
      _FamilyDataDownloadScreenState();
}

class _FamilyDataDownloadScreenState extends State<FamilyDataDownloadScreen> {
  List<Family> allFamilies = [];
  List<Family> filteredFamilies = [];

  String _aiPrompt = '';
  bool _showPromptDialog = false;
  // Track if "Select None" is active

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
  bool _isLoading = false;

  // Track visibility of columns
  Map<String, bool> columnVisibility = {};
  @override
  void initState() {
    super.initState();
    _fetchFamilies();

    // Initialize columnVisibility for all headers
    final allHeaders = [..._getFamilyDataHeaders(), ..._getMemberDataHeaders()];
    columnVisibility = {
      for (var header in allHeaders) header: true, // Default all to visible
    };
  }

  Future<void> _fetchFamilies() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await TokenHttp().get(
        '/families/getAllFamilies?disasterId=${AuthService().getDisasterId()}',
      );

      if (response != null && response['list'] is List) {
        List<Family> loadedFamilies = [];

        for (var familyJson in response['list']) {
          try {
            final family = NeedAssessmentData.fromJson(familyJson);
            loadedFamilies.add(
              Family(
                data: family,
                id: familyJson['id'] ?? familyJson['_id'] ?? '',
              ),
            );
          } catch (parseError) {
            print("Error parsing family data: $parseError");
          }
        }

        setState(() {
          allFamilies = loadedFamilies;
          filteredFamilies = loadedFamilies;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showConfirmationDialog(String prompt) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm AI Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You entered the following prompt:'),
              const SizedBox(height: 10),
              Text(prompt, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text(
                'The AI will now filter the data according to your request.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Here you would typically send the prompt to your AI service
                // and apply the filters it returns
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Processing AI request...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showPromptDialog = true; // Reopen the prompt dialog
                });
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void applyFilters() {
    setState(() {
      filteredFamilies = NeedAssessmentData.filterFamilies(allFamilies, {
        'villageWard': selectedVillageWard,
        'houseNumber': selectedHouseNumber,
        'householdHead': selectedHouseholdHead,
        'avgMonthlyFamilyIncome': {
          'min': incomeRange.start,
          'max': incomeRange.end,
        },
        'shelterType': selectedShelterType,
        'rationCategory': selectedRationCategory,
        'caste': selectedCaste,
        'outsideDamagedArea': outsideDamagedAreaFilter,
        'receivedAllowance': receivedAllowanceFilter,
        'memberName': memberNameFilter,
        'memberAge': {
          'min': memberAgeRange.start.toInt(),
          'max': memberAgeRange.end.toInt(),
        },
        'memberGender': memberGenderFilter,
        'memberEducation': memberEducationFilter,
        'memberEmploymentType': memberEmploymentTypeFilter,
        'memberUnemployedDueToDisaster': memberUnemployedDueToDisasterFilter,
        'memberHasMedicalNeeds': memberHasMedicalNeedsFilter,
        'memberIsBedridden': memberIsBedriddenFilter,
        'memberNeedsCounselling': memberNeedsCounsellingFilter,
      });
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
    final familySheet = excel['Family Data'];
    final individualSheet = excel['Individual Data'];

    // Get all headers and filter by visibility
    List<String> familyHeaders =
        _getFamilyDataHeaders()
            .where((header) => columnVisibility[header] ?? true)
            .toList();

    List<String> memberHeaders =
        _getMemberDataHeaders()
            .where((header) => columnVisibility[header] ?? true)
            .toList();

    // Add headers to the Family Data sheet
    familySheet.appendRow(
      familyHeaders.map((header) => TextCellValue(header)).toList(),
    );

    // Add family data rows
    for (var family in filteredFamilies) {
      final data = family.data;
      if (data != null) {
        List<TextCellValue> rowData = [];
        for (var header in familyHeaders) {
          String? value = _getFamilyDataValue(data, header);
          rowData.add(TextCellValue(value ?? 'N/A'));
        }
        familySheet.appendRow(rowData);
      }
    }

    // For Individual Data sheet, add combined headers
    List<String> combinedHeaders = [
      ...familyHeaders.map((h) => "Family $h"),
      ...memberHeaders,
    ];
    individualSheet.appendRow(
      combinedHeaders.map((header) => TextCellValue(header)).toList(),
    );

    // Add individual data rows
    for (var family in filteredFamilies) {
      final data = family.data;
      if (data != null) {
        for (var member in data.members ?? []) {
          List<TextCellValue> rowData = [];

          // Add family data first
          for (var header in familyHeaders) {
            String? value = _getFamilyDataValue(data, header);
            rowData.add(TextCellValue(value ?? 'N/A'));
          }

          // Then add member data
          for (var header in memberHeaders) {
            String? value = _getMemberDataValue(member, header);
            rowData.add(TextCellValue(value ?? 'N/A'));
          }

          individualSheet.appendRow(rowData);
        }
      }
    }

    // Save the file
    final bytes = excel.save();
    if (bytes != null) {
      await FileSaver.instance.saveFile(
        name: 'need_assessment_data',
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully!')),
      );
    }
  }

  // Helper Methods for Excel Export
  List<String> _getFamilyDataHeaders() {
    return [
      'Family ID',
      'Village/Ward',
      'House Number',
      'Head of Household',
      // 'Unique Household ID',
      'Address',
      'Contact No',
      'Ration Card No',
      'Ration Category',
      'Caste',
      'Other Caste',
      'Num Children Anganwadi',
      'Anganwadi Status',
      'Children Malnutrition Status',
      'Num Pregnant Women',
      'Num Lactating Mothers',
      'Food Assistance Sufficient',
      'Food Assistance Need Duration',
      'Govt Nutrition Disruption',
      'Health Insurance Status',
      'Health Insurance Details',
      'Shelter Type',
      'Other Shelter Type',
      'Residential Land Area',
      'Accommodation Status',
      'Other Accommodation',
      'Vehicle Possession',
      'Vehicle Type',
      'Other Vehicle Type',
      'Vehicle Loss',
      'Vehicle Loss Type',
      'Other Vehicle Loss Type',
      'Avg Monthly Family Income',
      'Primary Income Source',
      'Livelihood Affected',
      'Employment Loss',
      'Business Loss',
      'Daily Wage Loss',
      'Breadwinner Loss',
      'Animal Loss',
      'Agricultural Land Loss',
      'Other Livelihood Loss',
      'Other Livelihood Loss Details',
      'Agricultural Land Loss Area',
      'Stored Crops Loss',
      'Crop Type',
      'Equipment Loss',
      'Equipment Loss Details',
      'Animal Husbandry Loss',
      'Animal Husbandry Loss Details',
      'Shed Loss',
      'Shed Loss Details',
      'Equipment Tools Loss',
      'Equipment Tools Loss Details',
      'Livelihood Insurance',
      'Livelihood Insurance Details',
      'Pension Beneficiary',
      'Pension Type',
      'Other Pension Type',
      'MGNREGA Beneficiary',
      'MGNREGA Details',
      'Legal Documents Lost',
      'Aadhar Card Loss',
      'Government ID Loss',
      'Passport Loss',
      'Employment Card Loss',
      'PAN Card Loss',
      'Insurance Card Loss',
      'Driving License Loss',
      'ATM Card Loss',
      'Ration Card Loss Doc',
      'Land Document Loss',
      'Property Document Loss',
      'Birth Certificate Loss',
      'Marriage Certificate Loss',
      'Educational Document Loss',
      'Other Document Loss',
      'Other Document Loss Details',
      'Loan Repayment Pending',
      'Special Category',
      'Other Special Category',
      'Kudumbashree Member',
      'Kudumbashree NHG Name',
      'Kudumbashree Internal Loan',
      'Kudumbashree Internal Loan Amount',
      'Kudumbashree Linkage Loan',
      'Kudumbashree Linkage Loan Amount',
      'Kudumbashree Microenterprise Loan',
      'Kudumbashree Microenterprise Loan Amount',
      'Additional Support Required',
      'Food Security Additional Info',
      'Primary Occupation',
      'Secondary Occupation',
      'Outside Damaged Area',
      'Received Allowance',
    ];
  }

  List<String> _getMemberDataHeaders() {
    return [
      'Member Name',
      'Member Age',
      'Member Gender',
      'Member Relationship',
      'Member Marital Status',
      'Member L/D/M',
      'Member Aadhar No',
      'Member Grievously Injured',
      'Member Bedridden Palliative',
      'Member PWDs',
      'Member Psycho Social Assistance',
      'Member Nursing Home Assistance',
      'Member Assistive Devices',
      'Member Special Medical Requirements',
      'Member Education',
      'Member Previous Status',
      'Member Employment Type',
      'Member Salary',
      'Member Unemployed Due To Disaster',
      'Member Class Name',
      'Member School/Institute Name',
      'Member Are Dropout',
      'Member Preferred Mode Of Education',
      'Member Types Of Assistance Transport',
      'Member Types Of Assistance Digital Device',
      'Member Types Of Assistance Study Materials',
      'Member Types Of Assistance Any Other Specific Requirement',
      'Member Present Skill Set',
      'Member Type Of Livelihood Assistance Required',
      'Member Type Of Skilling Assistance Required',
      'Member Other Relationship',
      'Member Other Gender',
    ];
  }

  String? _getFamilyDataValue(NeedAssessmentData data, String header) {
    switch (header) {
      case 'Family ID':
        return data.uniqueHouseholdId; // Handled in the loop.
      case 'Village/Ward':
        return data.villageWard;
      case 'House Number':
        return data.houseNumber;
      case 'Head of Household':
        return data.householdHead;
      case 'Unique Household ID':
        return data.uniqueHouseholdId;
      case 'Address':
        return data.address;
      case 'Contact No':
        return data.contactNo;
      case 'Ration Card No':
        return data.rationCardNo;
      case 'Ration Category':
        return data.rationCategory;
      case 'Caste':
        return data.caste;
      case 'Other Caste':
        return data.otherCaste;
      case 'Num Children Anganwadi':
        return data.numChildrenAnganwadi.toString();
      case 'Anganwadi Status':
        return data.anganwadiStatus;
      case 'Children Malnutrition Status':
        return data.childrenMalnutritionStatus;
      case 'Num Pregnant Women':
        return data.numPregnantWomen.toString();
      case 'Num Lactating Mothers':
        return data.numLactatingMothers.toString();
      case 'Food Assistance Sufficient':
        return data.foodAssistanceSufficient;
      case 'Food Assistance Need Duration':
        return data.foodAssistanceNeedDuration;
      case 'Govt Nutrition Disruption':
        return data.govtNutritionDisruption;
      case 'Health Insurance Status':
        return data.healthInsuranceStatus;
      case 'Health Insurance Details':
        return data.healthInsuranceDetails;
      case 'Shelter Type':
        return data.shelterType;
      case 'Other Shelter Type':
        return data.otherShelterType;
      case 'Residential Land Area':
        return data.residentialLandArea;

      case 'Vehicle Possession':
        return data.vehiclePossession;
      case 'Vehicle Type':
        return data.vehicleType;
      case 'Other Vehicle Type':
        return data.otherVehicleType;
      case 'Vehicle Loss':
        return data.vehicleLoss;
      case 'Vehicle Loss Type':
        return data.vehicleLossType;
      case 'Other Vehicle Loss Type':
        return data.otherVehicleLossType;
      case 'Avg Monthly Family Income':
        return data.avgMonthlyFamilyIncome.toString();
      case 'Primary Income Source':
        return data.primaryIncomeSource;
      case 'Livelihood Affected':
        return data.livelihoodAffected;
      case 'Employment Loss':
        return data.employmentLoss;
      case 'Business Loss':
        return data.businessLoss;
      case 'Daily Wage Loss':
        return data.dailyWageLoss;
      case 'Breadwinner Loss':
        return data.breadwinnerLoss;
      case 'Animal Loss':
        return data.animalLoss.toString();
      case 'Agricultural Land Loss':
        return data.agriculturalLandLoss;
      case 'Other Livelihood Loss':
        return data.otherLivelihoodLoss;
      case 'Other Livelihood Loss Details':
        return data.otherLivelihoodLossDetails;
      case 'Agricultural Land Loss Area':
        return data.agriculturalLandLossArea;
      case 'Stored Crops Loss':
        return data.storedCropsLoss;
      case 'Crop Type':
        return data.cropType;
      case 'Equipment Loss':
        return data.equipmentLoss;
      case 'Equipment Loss Details':
        return data.equipmentLossDetails;
      case 'Animal Husbandry Loss':
        return data.animalHusbandryLoss;
      case 'Animal Husbandry Loss Details':
        return data.animalHusbandryLossDetails;
      case 'Shed Loss':
        return data.shedLoss;
      case 'Shed Loss Details':
        return data.shedLossDetails;
      case 'Equipment Tools Loss':
        return data.equipmentToolsLoss;
      case 'Equipment Tools Loss Details':
        return data.equipmentToolsLossDetails;
      case 'Livelihood Insurance':
        return data.livelihoodInsurance;
      case 'Livelihood Insurance Details':
        return data.livelihoodInsuranceDetails;
      case 'Pension Beneficiary':
        return data.pensionBeneficiary;
      case 'Pension Type':
        return data.pensionType;
      case 'Other Pension Type':
        return data.otherPensionType;
      case 'MGNREGA Beneficiary':
        return data.mgnregaBeneficiary;
      case 'MGNREGA Details':
        return data.mgnregaDetails;
      case 'Legal Documents Lost':
        return data.legalDocumentsLost;
      case 'Aadhar Card Loss':
        return data.aadharCardLoss;
      case 'Government ID Loss':
        return data.governmentIDLoss;
      case 'Passport Loss':
        return data.passportLoss;
      case 'Employment Card Loss':
        return data.employmentCardLoss;
      case 'PAN Card Loss':
        return data.panCardLoss;
      case 'Insurance Card Loss':
        return data.insuranceCardLoss;
      case 'Driving License Loss':
        return data.drivingLicenseLoss;
      case 'ATM Card Loss':
        return data.atmCardLoss;
      case 'Ration Card Loss Doc':
        return data.rationCardLossDoc;
      case 'Land Document Loss':
        return data.landDocumentLoss;
      case 'Property Document Loss':
        return data.propertyDocumentLoss;
      case 'Birth Certificate Loss':
        return data.birthCertificateLoss;
      case 'Marriage Certificate Loss':
        return data.marriageCertificateLoss;
      case 'Educational Document Loss':
        return data.educationalDocumentLoss;
      case 'Other Document Loss':
        return data.otherDocumentLoss;
      case 'Other Document Loss Details':
        return data.otherDocumentLossDetails;
      case 'Loan Repayment Pending':
        return data.loanRepaymentPending;
      case 'Special Category':
        return data.specialCategory;
      case 'Other Special Category':
        return data.otherSpecialCategory;
      case 'Kudumbashree Member':
        return data.kudumbashreeMember;
      case 'Kudumbashree NHG Name':
        return data.kudumbashreeNHGName;
      case 'Kudumbashree Internal Loan':
        return data.kudumbashreeInternalLoan;
      case 'Kudumbashree Internal Loan Amount':
        return data.kudumbashreeInternalLoanAmount.toString();
      case 'Kudumbashree Linkage Loan':
        return data.kudumbashreeLinkageLoan;
      case 'Kudumbashree Linkage Loan Amount':
        return data.kudumbashreeLinkageLoanAmount.toString();
      case 'Kudumbashree Microenterprise Loan':
        return data.kudumbashreeMicroenterpriseLoan;
      case 'Kudumbashree Microenterprise Loan Amount':
        return data.kudumbashreeMicroenterpriseLoanAmount.toString();
      case 'Additional Support Required':
        return data.additionalSupportRequired;
      case 'Food Security Additional Info':
        return data.foodSecurityAdditionalInfo;
      case 'Primary Occupation':
        return data.primaryOccupation;
      case 'Secondary Occupation':
        return data.secondaryOccupation;
      case 'Outside Damaged Area':
        return data.outsideDamagedArea.toString();
      case 'Received Allowance':
        return data.receivedAllowance.toString();
      default:
        return null;
    }
  }

  String? _getMemberDataValue(Member member, String header) {
    switch (header) {
      case 'Member Name':
        return member.name;
      case 'Member Age':
        return member.age;
      case 'Member Gender':
        return member.gender;
      case 'Member Relationship':
        return member.relationship;
      case 'Member Marital Status':
        return member.maritalStatus;
      case 'Member L/D/M':
        return member.ldm;
      case 'Member Aadhar No':
        return member.aadharNo;
      case 'Member Grievously Injured':
        return member.grievouslyInjured;
      case 'Member Bedridden Palliative':
        return member.bedriddenPalliative;
      case 'Member PWDs':
        return member.pwDs;
      case 'Member Psycho Social Assistance':
        return member.psychoSocialAssistance;
      case 'Member Nursing Home Assistance':
        return member.nursingHomeAssistance;
      case 'Member Assistive Devices':
        return member.assistiveDevices;
      case 'Member Special Medical Requirements':
        return member.specialMedicalRequirements;
      case 'Member Education':
        return member.education;
      case 'Member Previous Status':
        return member.previousStatus;
      case 'Member Employment Type':
        return member.employmentType;
      case 'Member Salary':
        return member.salary;
      case 'Member Unemployed Due To Disaster':
        return member.unemployedDueToDisaster;
      case 'Member Class Name':
        return member.className;
      case 'Member School/Institute Name':
        return member.schoolInstituteName;
      case 'Member Are Dropout':
        return member.areDropout;
      case 'Member Preferred Mode Of Education':
        return member.preferredModeOfEducation;
      case 'Member Types Of Assistance Transport':
        return member.typesOfAssistanceTransport;
      case 'Member Types Of Assistance Digital Device':
        return member.typesOfAssistanceDigitalDevice;
      case 'Member Types Of Assistance Study Materials':
        return member.typesOfAssistanceStudyMaterials;
      case 'Member Types Of Assistance Any Other Specific Requirement':
        return member.typesOfAssistanceAnyOtherSpecificRequirement;
      case 'Member Present Skill Set':
        return member.presentSkillSet;
      case 'Member Type Of Livelihood Assistance Required':
        return member.typeOfLivelihoodAssistanceRequired;
      case 'Member Type Of Skilling Assistance Required':
        return member.typeOfSkillingAssistanceRequired;
      case 'Member Other Relationship':
        return member.otherRelationship;
      case 'Member Other Gender':
        return member.otherGender;
      case 'Accommodation Status':
        return member.accommodationStatus;
      case 'Other Accommodation':
        return member.otherAccommodation;
      default:
        return null;
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
                _buildDetailRow(
                  'Avg Monthly Income:',
                  '₹${data.avgMonthlyFamilyIncome.toStringAsFixed(0)}',
                ),
                _buildDetailRow(
                  'Primary Income Source:',
                  data.primaryIncomeSource,
                ),
                _buildDetailRow(
                  'Livelihood Affected:',
                  data.livelihoodAffected,
                ),
                _buildDetailRow(
                  'Number of Members:',
                  data.numMembers.toString(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Family Members:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(data.members ?? []).map((member) {
                  // null check
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.name} (${member.age} years, ${member.gender})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _buildDetailRow('Relationship:', member.relationship),
                        _buildDetailRow('Education:', member.education),
                        _buildDetailRow('Employment:', member.employmentType),
                        _buildDetailRow('Salary', member.salary),
                        _buildDetailRow(
                          'Unemployed Due to Disaster',
                          member.unemployedDueToDisaster,
                        ),
                        _buildDetailRow('Class Name', member.className),
                        _buildDetailRow(
                          'School/Institute Name',
                          member.schoolInstituteName,
                        ),
                        _buildDetailRow('Are Dropout', member.areDropout),
                        _buildDetailRow(
                          'Preferred Mode of Education',
                          member.preferredModeOfEducation,
                        ),
                        _buildDetailRow(
                          'Types of Assistance Transport',
                          member.typesOfAssistanceTransport,
                        ),
                        _buildDetailRow(
                          'Types of Assistance Digital Device',
                          member.typesOfAssistanceDigitalDevice,
                        ),
                        _buildDetailRow(
                          'Types of Assistance Study Materials',
                          member.typesOfAssistanceStudyMaterials,
                        ),
                        _buildDetailRow(
                          'Types of Assistance Any Other',
                          member.typesOfAssistanceAnyOtherSpecificRequirement,
                        ),
                        _buildDetailRow(
                          'Present Skill Set',
                          member.presentSkillSet,
                        ),
                        _buildDetailRow(
                          'Type of Livelihood Assistance Required',
                          member.typeOfLivelihoodAssistanceRequired,
                        ),
                        _buildDetailRow(
                          'Type of Skilling Assistance Required',
                          member.typeOfSkillingAssistanceRequired,
                        ),
                        _buildDetailRow(
                          'Other Relationship',
                          member.otherRelationship,
                        ),
                        _buildDetailRow('Other Gender', member.otherGender),
                        if (member.specialMedicalRequirements?.isNotEmpty ??
                            false)
                          _buildDetailRow(
                            'Medical Needs:',
                            member.specialMedicalRequirements!,
                          ),
                        _buildDetailRow('Marital Status', member.maritalStatus),
                        _buildDetailRow('L/D/M', member.ldm),
                        _buildDetailRow('Aadhar No', member.aadharNo),
                        _buildDetailRow(
                          'Grievously Injured',
                          member.grievouslyInjured,
                        ),
                        _buildDetailRow(
                          'Bedridden Palliative',
                          member.bedriddenPalliative,
                        ),
                        _buildDetailRow('PWDs', member.pwDs),
                        _buildDetailRow(
                          'Psycho Social Assistance',
                          member.psychoSocialAssistance,
                        ),
                        _buildDetailRow(
                          'Nursing Home Assistance',
                          member.nursingHomeAssistance,
                        ),
                        _buildDetailRow(
                          'Assistive Devices',
                          member.assistiveDevices,
                        ),
                        _buildDetailRow(
                          'Previous Status',
                          member.previousStatus,
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
            width: 250, // Increased width for labels
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villageWards = NeedAssessmentData.getDistinctValues(
      allFamilies,
      'villageWard',
    );
    final shelterTypes = NeedAssessmentData.getDistinctValues(
      allFamilies,
      'shelterType',
    );
    final rationCategories = NeedAssessmentData.getDistinctValues(
      allFamilies,
      'rationCategory',
    );
    final castes = NeedAssessmentData.getDistinctValues(allFamilies, 'caste');
    final genders = NeedAssessmentData.getDistinctValues(allFamilies, 'gender');
    final educationLevels = NeedAssessmentData.getDistinctValues(
      allFamilies,
      'education',
    );
    final employmentTypes = NeedAssessmentData.getDistinctValues(
      allFamilies,
      'employmentType',
    );
    final allHeaders = [..._getFamilyDataHeaders(), ..._getMemberDataHeaders()];

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
              if (_showPromptDialog) ...[
                AlertDialog(
                  title: const Text('AI Data Filter'),
                  content: TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Enter your prompt for filtering data (e.g., "Show families with children under 5 who need food assistance")',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _aiPrompt = value;
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showPromptDialog = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showPromptDialog = false;
                        });
                        if (_aiPrompt.isNotEmpty) {
                          _showConfirmationDialog(_aiPrompt);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],

              // AI Filter Button at the very top (before other filters)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showPromptDialog = true;
                  });
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Column visibility toggles
              ExpansionTile(
                title: const Text(
                  'Select Columns to Display',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children:
                    allHeaders.map((header) {
                      return CheckboxListTile(
                        title: Text(header),
                        value: columnVisibility[header],
                        onChanged: (bool? value) {
                          setState(() {
                            columnVisibility[header] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(
                height: 20,
              ), // Family-level filters as ExpansionTile
              ExpansionTile(
                title: const Text(
                  'Family-Level Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  _buildFilterDropdown(
                    'Village/Ward',
                    villageWards,
                    selectedVillageWard,
                    (value) {
                      setState(() {
                        selectedVillageWard = value;
                      });
                    },
                  ),
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
                  _buildFilterDropdown(
                    'Shelter Type',
                    shelterTypes,
                    selectedShelterType,
                    (value) {
                      setState(() {
                        selectedShelterType = value;
                      });
                    },
                  ),
                  _buildFilterDropdown(
                    'Ration Category',
                    rationCategories,
                    selectedRationCategory,
                    (value) {
                      setState(() {
                        selectedRationCategory = value;
                      });
                    },
                  ),
                  _buildFilterDropdown('Caste', castes, selectedCaste, (value) {
                    setState(() {
                      selectedCaste = value;
                    });
                  }),
                  _buildCheckboxRow(
                    'Outside Damaged Area',
                    outsideDamagedAreaFilter,
                    (value) {
                      setState(() {
                        outsideDamagedAreaFilter = value;
                      });
                    },
                  ),
                  _buildCheckboxRow(
                    'Received Allowance',
                    receivedAllowanceFilter,
                    (value) {
                      setState(() {
                        receivedAllowanceFilter = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text(
                  'Individual-Level Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
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
                  _buildFilterDropdown('Gender', genders, memberGenderFilter, (
                    value,
                  ) {
                    setState(() {
                      memberGenderFilter = value;
                    });
                  }),
                  _buildFilterDropdown(
                    'Education Level',
                    educationLevels,
                    memberEducationFilter,
                    (value) {
                      setState(() {
                        memberEducationFilter = value;
                      });
                    },
                  ),
                  _buildFilterDropdown(
                    'Employment Type',
                    employmentTypes,
                    memberEmploymentTypeFilter,
                    (value) {
                      setState(() {
                        memberEmploymentTypeFilter = value;
                      });
                    },
                  ),
                  _buildCheckboxRow(
                    'Unemployed Due to Disaster',
                    memberUnemployedDueToDisasterFilter,
                    (value) {
                      setState(() {
                        memberUnemployedDueToDisasterFilter = value;
                      });
                    },
                  ),
                  _buildCheckboxRow(
                    'Has Medical Needs',
                    memberHasMedicalNeedsFilter,
                    (value) {
                      setState(() {
                        memberHasMedicalNeedsFilter = value;
                      });
                    },
                  ),
                  _buildCheckboxRow('Is Bedridden', memberIsBedriddenFilter, (
                    value,
                  ) {
                    setState(() {
                      memberIsBedriddenFilter = value;
                    });
                  }),
                  _buildCheckboxRow(
                    'Needs Counselling',
                    memberNeedsCounsellingFilter,
                    (value) {
                      setState(() {
                        memberNeedsCounsellingFilter = value;
                      });
                    },
                  ),
                ],
              ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Results count
              Text(
                '${filteredFamilies.length} families, ${filteredFamilies.fold(0, (sum, family) => sum + (family.data?.members?.length ?? 0))} individuals',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Data table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns:
                      allHeaders
                          .where((header) => columnVisibility[header] == true)
                          .map((header) => DataColumn(label: Text(header)))
                          .toList(),
                  rows: _buildDataRows(allHeaders),
                ),
              ),
              const SizedBox(height: 20),
              if (filteredFamilies.isEmpty && !_isLoading)
                Center(child: Text('No family data available')),
            ],
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildDataRows(List<String> allHeaders) {
    List<DataRow> rows = [];
    for (var family in filteredFamilies) {
      final data = family.data;
      if (data != null) {
        if ((data.members?.isEmpty ?? true)) {
          // Add a single row for family with no members
          rows.add(
            DataRow(
              onSelectChanged: (_) => _showFamilyDetails(family),
              cells:
                  allHeaders
                      .where((header) => columnVisibility[header] == true)
                      .map((header) {
                        final value = _getFamilyDataValue(data, header);
                        return DataCell(Text(value ?? 'N/A'));
                      })
                      .toList(),
            ),
          );
        } else {
          // Add rows for each family member
          for (var member in data.members ?? []) {
            rows.add(
              DataRow(
                onSelectChanged: (_) => _showFamilyDetails(family),
                cells:
                    allHeaders
                        .where((header) => columnVisibility[header] == true)
                        .map((header) {
                          final value =
                              _getMemberDataValue(member, header) ??
                              _getFamilyDataValue(data, header);
                          return DataCell(Text(value ?? 'N/A'));
                        })
                        .toList(),
              ),
            );
          }
        }
      }
    }
    return rows;
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
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
            return DropdownMenuItem(value: value, child: Text(value));
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

  Widget _buildRangeSlider(
    String label,
    RangeValues values,
    double min,
    double max,
    ValueChanged<RangeValues> onChanged,
  ) {
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

  Widget _buildCheckboxRow(
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
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
