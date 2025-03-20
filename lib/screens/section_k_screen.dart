import 'package:flutter/material.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'dart:convert'; // Import for JSON encoding

class ScreenK extends StatelessWidget {
  final NeedAssessmentData data;

  ScreenK({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen K: Review and Submit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Your Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Display all the data here, for example:
              Text('Village/Ward: ${data.villageWard}'),
              Text('House Number: ${data.houseNumber}'),
              Text('Household Head: ${data.householdHead}'),
              // ... Display other fields similarly ...
              Text('Members:'),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.members.length,
                itemBuilder: (context, index) {
                  return Text(
                    '  - ${data.members[index].name}, Age: ${data.members[index].age}, Gender: ${data.members[index].gender}',
                  );
                },
              ),
              Text('Loan Details:'),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.loanDetails.length,
                itemBuilder: (context, index) {
                  return Text(
                    '  - Bank: ${data.loanDetails[index].bankName}, Loan: ${data.loanDetails[index].loanCategory}',
                  );
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Print the data to the console as JSON
                  print(
                    jsonEncode(data.toJson()),
                  ); // Assuming you add toJson() to NeedAssessmentData

                  // Implement your submission logic here (e.g., send data to a server)
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add toJson() method to NeedAssessmentData class
extension NeedAssessmentDataToJson on NeedAssessmentData {
  Map<String, dynamic> toJson() {
    return {
      'villageWard': villageWard,
      'houseNumber': houseNumber,
      'householdHead': householdHead,
      'uniqueHouseholdId': uniqueHouseholdId,
      'address': address,
      'contactNo': contactNo,
      'rationCardNo': rationCardNo,
      'rationCategory': rationCategory,
      'caste': caste,
      'otherCaste': otherCaste,
      'numChildrenAnganwadi': numChildrenAnganwadi,
      'anganwadiStatus': anganwadiStatus,
      'childrenMalnutritionStatus': childrenMalnutritionStatus,
      'numPregnantWomen': numPregnantWomen,
      'numLactatingMothers': numLactatingMothers,
      'foodAssistanceSufficient': foodAssistanceSufficient,
      'foodAssistanceNeedDuration': foodAssistanceNeedDuration,
      'govtNutritionDisruption': govtNutritionDisruption,
      'healthInsuranceStatus': healthInsuranceStatus,
      'healthInsuranceDetails': healthInsuranceDetails,
      'shelterType': shelterType,
      'otherShelterType': otherShelterType,
      'residentialLandArea': residentialLandArea,
      'accommodationStatus': accommodationStatus,
      'otherAccommodation': otherAccommodation,
      'vehiclePossession': vehiclePossession,
      'vehicleType': vehicleType,
      'otherVehicleType': otherVehicleType,
      'vehicleLoss': vehicleLoss,
      'vehicleLossType': vehicleLossType,
      'otherVehicleLossType': otherVehicleLossType,
      'avgMonthlyFamilyIncome': avgMonthlyFamilyIncome,
      'primaryIncomeSource': primaryIncomeSource,
      'livelihoodAffected': livelihoodAffected,
      'employmentLoss': employmentLoss,
      'businessLoss': businessLoss,
      'dailyWageLoss': dailyWageLoss,
      'breadwinnerLoss': breadwinnerLoss,
      'animalLoss': animalLoss,
      'agriculturalLandLoss': agriculturalLandLoss,
      'otherLivelihoodLoss': otherLivelihoodLoss,
      'otherLivelihoodLossDetails': otherLivelihoodLossDetails,
      'agriculturalLandLossArea': agriculturalLandLossArea,
      'storedCropsLoss': storedCropsLoss,
      'cropType': cropType,
      'equipmentLoss': equipmentLoss,
      'equipmentLossDetails': equipmentLossDetails,
      'animalHusbandryLoss': animalHusbandryLoss,
      'animalHusbandryLossDetails': animalHusbandryLossDetails,
      'shedLoss': shedLoss,
      'shedLossDetails': shedLossDetails,
      'equipmentToolsLoss': equipmentToolsLoss,
      'equipmentToolsLossDetails': equipmentToolsLossDetails,
      'livelihoodInsurance': livelihoodInsurance,
      'livelihoodInsuranceDetails': livelihoodInsuranceDetails,
      'pensionBeneficiary': pensionBeneficiary,
      'pensionType': pensionType,
      'otherPensionType': otherPensionType,
      'mgnregaBeneficiary': mgnregaBeneficiary,
      'mgnregaDetails': mgnregaDetails,
      'legalDocumentsLost': legalDocumentsLost,
      'aadharCardLoss': aadharCardLoss,
      'governmentIDLoss': governmentIDLoss,
      'passportLoss': passportLoss,
      'employmentCardLoss': employmentCardLoss,
      'panCardLoss': panCardLoss,
      'insuranceCardLoss': insuranceCardLoss,
      'drivingLicenseLoss': drivingLicenseLoss,
      'atmCardLoss': atmCardLoss,
      'rationCardLossDoc': rationCardLossDoc,
      'landDocumentLoss': landDocumentLoss,
      'propertyDocumentLoss': propertyDocumentLoss,
      'birthCertificateLoss': birthCertificateLoss,
      'marriageCertificateLoss': marriageCertificateLoss,
      'educationalDocumentLoss': educationalDocumentLoss,
      'otherDocumentLoss': otherDocumentLoss,
      'otherDocumentLossDetails': otherDocumentLossDetails,
      'loanRepaymentPending': loanRepaymentPending,
      'specialCategory': specialCategory,
      'otherSpecialCategory': otherSpecialCategory,
      'kudumbashreeMember': kudumbashreeMember,
      'kudumbashreeNHGName': kudumbashreeNHGName,
      'kudumbashreeInternalLoan': kudumbashreeInternalLoan,
      'kudumbashreeInternalLoanAmount': kudumbashreeInternalLoanAmount,
      'kudumbashreeLinkageLoan': kudumbashreeLinkageLoan,
      'kudumbashreeLinkageLoanAmount': kudumbashreeLinkageLoanAmount,
      'kudumbashreeMicroenterpriseLoan': kudumbashreeMicroenterpriseLoan,
      'kudumbashreeMicroenterpriseLoanAmount':
          kudumbashreeMicroenterpriseLoanAmount,
      'additionalSupportRequired': additionalSupportRequired,
      'foodSecurityAdditionalInfo': foodSecurityAdditionalInfo,
      'primaryOccupation': primaryOccupation,
      'secondaryOccupation': secondaryOccupation,
      'numMembers': numMembers,
      'members': members.map((member) => member.toJson()).toList(),
      'loanDetails': loanDetails.map((loan) => loan.toJson()).toList(),
    };
  }
}

// Add toJson() method to Member class
extension MemberToJson on Member {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'relationship': relationship,
      'maritalStatus': maritalStatus,
      'ldm': ldm,
      'aadharNo': aadharNo,
      'grievouslyInjured': grievouslyInjured,
      'bedriddenPalliative': bedriddenPalliative,
      'pwDs': pwDs,
      'psychoSocialAssistance': psychoSocialAssistance,
      'nursingHomeAssistance': nursingHomeAssistance,
      'assistiveDevices': assistiveDevices,
      'specialMedicalRequirements': specialMedicalRequirements,
      'education': education,
      'previousStatus': previousStatus,
      'employmentType': employmentType,
      'salary': salary,
      'unemployedDueToDisaster': unemployedDueToDisaster,
      'className': className,
      'schoolInstituteName': schoolInstituteName,
      'areDropout': areDropout,
      'preferredModeOfEducation': preferredModeOfEducation,
      'typesOfAssistanceTransport': typesOfAssistanceTransport,
      'typesOfAssistanceDigitalDevice': typesOfAssistanceDigitalDevice,
      'typesOfAssistanceStudyMaterials': typesOfAssistanceStudyMaterials,
      'typesOfAssistanceAnyOtherSpecificRequirement':typesOfAssistanceAnyOtherSpecificRequirement,
      'presentSkillSet': presentSkillSet,
      'typeOfLivelihoodAssistanceRequired': typeOfLivelihoodAssistanceRequired,
      'typeOfSkillingAssistanceRequired': typeOfSkillingAssistanceRequired,
    };
  }
}

// Add toJson() method to LoanDetail class
extension LoanDetailToJson on LoanDetail {
  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'branch': branch,
      'accountNumber': accountNumber,
      'loanCategory': loanCategory,
      'loanAmount': loanAmount,
      'loanOutstanding': loanOutstanding,
    };
  }
}
