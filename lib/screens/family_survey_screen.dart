import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: NeedAssessmentScreen(),
  ));
}

class NeedAssessmentScreen extends StatefulWidget {
  const NeedAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<NeedAssessmentScreen> createState() => _NeedAssessmentScreenState();
}

class _NeedAssessmentScreenState extends State<NeedAssessmentScreen> {
  // List to store demographic entries (merged tables except loan table + skill table)
  List<DemographicModel> demographics = [];

  // Separate list for skill building
  List<SkillModel> skillModels = [];

  // For editing existing data
  bool isEditing = false;

  // Controllers/keys for capturing user input. You can expand these as you need.
  // Shown here are minimal placeholders for the merged data card.
  final TextEditingController villageController = TextEditingController();
  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController householdHeadController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController rationNoController = TextEditingController();
  final TextEditingController casteController = TextEditingController();
  final TextEditingController noOfFamilyMembersController = TextEditingController();

  // For dynamic family members
  List<DemographicMember> familyMembers = [];

  // Skill card fields (we have a separate card for these)
  // Name is a dropdown that uses previously entered names from the demographics
  String? selectedName; // from the dropdown
  final TextEditingController skillTypeController = TextEditingController();

  @override
  void dispose() {
    villageController.dispose();
    houseNoController.dispose();
    householdHeadController.dispose();
    addressController.dispose();
    contactNoController.dispose();
    rationNoController.dispose();
    casteController.dispose();
    noOfFamilyMembersController.dispose();
    skillTypeController.dispose();
    super.dispose();
  }

  // Call this to add dynamic fields for each family member
  void addFamilyFields(int count) {
    familyMembers.clear();
    for (int i = 0; i < count; i++) {
      familyMembers.add(DemographicMember(
        nameController: TextEditingController(),
        ageController: TextEditingController(),
        genderController: TextEditingController(),
        positionController: TextEditingController(),
        maritalStatusController: TextEditingController(),
        aadhaarController: TextEditingController(),
      ));
    }
    setState(() {});
  }

  // After user enters data, press a button to save data
  void saveData() {
    // We combine data from the main card and the dynamic family members.
    // You can store them as a single object or do whatever fits your structure.
    DemographicModel demoModel = DemographicModel(
      village: villageController.text.trim(),
      houseNo: houseNoController.text.trim(),
      householdHead: householdHeadController.text.trim(),
      address: addressController.text.trim(),
      contactNo: contactNoController.text.trim(),
      rationNo: rationNoController.text.trim(),
      caste: casteController.text.trim(),
      familyCount: familyMembers.length,
      members: familyMembers.map((member) {
        return FamilyMemberData(
          name: member.nameController.text.trim(),
          age: member.ageController.text.trim(),
          gender: member.genderController.text.trim(),
          position: member.positionController.text.trim(),
          maritalStatus: member.maritalStatusController.text.trim(),
          aadhaar: member.aadhaarController.text.trim(),
        );
      }).toList(),
    );

    // Store or update in the local list:
    if (isEditing) {
      // If editing, replace the last entry or whichever you prefer
      // For demonstration, assume we only edit the most recent
      demographics[demographics.length - 1] = demoModel;
      isEditing = false;
    } else {
      demographics.add(demoModel);
    }

    // Clear fields if you want to
    clearMainForm();

    // Print in console
    print("===== DEMOGRAPHIC DATA =====");
    for (var d in demographics) {
      print("Village: ${d.village}, HouseNo: ${d.houseNo}, HouseholdHead: ${d.householdHead}");
      print("Family Members: ${d.familyCount}");
      for (var m in d.members) {
        print(" -> ${m.name}, ${m.age}, ${m.gender}, ${m.position}, ${m.maritalStatus}, ${m.aadhaar}");
      }
    }

    // Example: Push to API
    pushToApi(demoModel);
  }

  void clearMainForm() {
    villageController.clear();
    houseNoController.clear();
    householdHeadController.clear();
    addressController.clear();
    contactNoController.clear();
    rationNoController.clear();
    casteController.clear();
    noOfFamilyMembersController.clear();
    familyMembers.clear();
    setState(() {});
  }

  // Edit button tapped
  void editData() {
    if (demographics.isEmpty) return;
    DemographicModel latest = demographics.last;
    villageController.text = latest.village;
    houseNoController.text = latest.houseNo;
    householdHeadController.text = latest.householdHead;
    addressController.text = latest.address;
    contactNoController.text = latest.contactNo;
    rationNoController.text = latest.rationNo;
    casteController.text = latest.caste;
    addFamilyFields(latest.familyCount);

    for (int i = 0; i < latest.members.length; i++) {
      familyMembers[i].nameController.text = latest.members[i].name;
      familyMembers[i].ageController.text = latest.members[i].age;
      familyMembers[i].genderController.text = latest.members[i].gender;
      familyMembers[i].positionController.text = latest.members[i].position;
      familyMembers[i].maritalStatusController.text = latest.members[i].maritalStatus;
      familyMembers[i].aadhaarController.text = latest.members[i].aadhaar;
    }

    isEditing = true;
    setState(() {});
  }

  // Example function to push data to an API
  Future<void> pushToApi(DemographicModel model) async {
    try {
      // Replace this with your actual endpoint
      var url = Uri.parse('https://example.com/api/submit');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(model.toJson()),
      );
      if (response.statusCode == 200) {
        print("Data posted successfully");
      } else {
        print("Failed to post data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in pushToApi: $e");
    }
  }

  // Save skill building data in a separate card
  void saveSkillData() {
    if (selectedName == null || selectedName!.isEmpty) {
      // handle error
      return;
    }
    SkillModel skillModel = SkillModel(
      personName: selectedName!,
      skillType: skillTypeController.text.trim(),
    );
    skillModels.add(skillModel);

    // Print in console
    print("===== SKILL BUILDING DATA =====");
    for (var s in skillModels) {
      print("Name: ${s.personName}, Skill: ${s.skillType}");
    }

    // Clear skill fields
    selectedName = null;
    skillTypeController.clear();

    // For demonstration, you might push to your skill-building API:
    // pushSkillsToApi(skillModel);

    setState(() {});
  }

  // Build demographic card (merged tables except loan + skill)
  Widget buildDemographicCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Merged Demographic Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: villageController,
              decoration: const InputDecoration(labelText: 'Village/Ward'),
            ),
            TextField(
              controller: houseNoController,
              decoration: const InputDecoration(labelText: 'House Number'),
            ),
            TextField(
              controller: householdHeadController,
              decoration: const InputDecoration(labelText: 'Household Head'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: contactNoController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
            ),
            TextField(
              controller: rationNoController,
              decoration: const InputDecoration(labelText: 'Ration Card Number'),
            ),
            TextField(
              controller: casteController,
              decoration: const InputDecoration(labelText: 'Caste'),
            ),
            // Add more fields here if you have more from your merged table

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noOfFamilyMembersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'No. of Family Members'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (noOfFamilyMembersController.text.isNotEmpty) {
                      int count = int.parse(noOfFamilyMembersController.text);
                      addFamilyFields(count);
                    }
                  },
                  child: const Text("Add Family"),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Show dynamic family member fields
            Column(
              children: List.generate(
                familyMembers.length,
                (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Member ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: familyMembers[index].nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: familyMembers[index].ageController,
                        decoration: const InputDecoration(labelText: 'Age'),
                      ),
                      TextField(
                        controller: familyMembers[index].genderController,
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                      TextField(
                        controller: familyMembers[index].positionController,
                        decoration: const InputDecoration(labelText: 'Position in family'),
                      ),
                      TextField(
                        controller: familyMembers[index].maritalStatusController,
                        decoration: const InputDecoration(labelText: 'Marital Status'),
                      ),
                      TextField(
                        controller: familyMembers[index].aadhaarController,
                        decoration: const InputDecoration(labelText: 'Aadhaar No'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: saveData,
                  child: Text(isEditing ? "Update" : "Save"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: editData,
                  child: const Text("Edit (Load Last Entry)"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build skill building card
  Widget buildSkillBuildingCard() {
    // For the name dropdown, we gather all the previously entered names in demographics
    final List<String> allNames = [];
    for (var d in demographics) {
      for (var m in d.members) {
        if (m.name.isNotEmpty) {
          allNames.add(m.name);
        }
      }
    }
    // remove duplicates if needed
    final uniqueNames = allNames.toSet().toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Skill Building",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: selectedName,
              items: uniqueNames
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedName = val;
                });
              },
              decoration: const InputDecoration(labelText: "Select Name"),
            ),
            TextField(
              controller: skillTypeController,
              decoration: const InputDecoration(labelText: 'Skill or Assistance Required'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: saveSkillData,
              child: const Text("Save Skill"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Assessment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildDemographicCard(),
            buildSkillBuildingCard(),
          ],
        ),
      ),
    );
  }
}

// Models

class DemographicModel {
  final String village;
  final String houseNo;
  final String householdHead;
  final String address;
  final String contactNo;
  final String rationNo;
  final String caste;
  final int familyCount;
  final List<FamilyMemberData> members;

  DemographicModel({
    required this.village,
    required this.houseNo,
    required this.householdHead,
    required this.address,
    required this.contactNo,
    required this.rationNo,
    required this.caste,
    required this.familyCount,
    required this.members,
  });

  Map<String, dynamic> toJson() {
    return {
      "village": village,
      "houseNo": houseNo,
      "householdHead": householdHead,
      "address": address,
      "contactNo": contactNo,
      "rationNo": rationNo,
      "caste": caste,
      "familyCount": familyCount,
      "members": members.map((m) => m.toJson()).toList(),
    };
  }
}

class FamilyMemberData {
  final String name;
  final String age;
  final String gender;
  final String position;
  final String maritalStatus;
  final String aadhaar;

  FamilyMemberData({
    required this.name,
    required this.age,
    required this.gender,
    required this.position,
    required this.maritalStatus,
    required this.aadhaar,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "gender": gender,
      "position": position,
      "maritalStatus": maritalStatus,
      "aadhaar": aadhaar,
    };
  }
}

// Model for the skill building card
class SkillModel {
  final String personName;
  final String skillType;

  SkillModel({
    required this.personName,
    required this.skillType,
  });

  Map<String, dynamic> toJson() {
    return {
      "personName": personName,
      "skillType": skillType,
    };
  }
}

// Helper for dynamic family fields
class DemographicMember {
  TextEditingController nameController;
  TextEditingController ageController;
  TextEditingController genderController;
  TextEditingController positionController;
  TextEditingController maritalStatusController;
  TextEditingController aadhaarController;

  DemographicMember({
    required this.nameController,
    required this.ageController,
    required this.genderController,
    required this.positionController,
    required this.maritalStatusController,
    required this.aadhaarController,
  });
}
                                                     