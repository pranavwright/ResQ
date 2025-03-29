import 'package:flutter/material.dart';

class NeedAssessmentData {
  String villageWard = ''; 
  String houseNumber = ''; 
  String householdHead = ''; 
  String uniqueHouseholdId = ''; 
  String address = ''; 
  String contactNo = ''; 
  String rationCardNo = ''; 
  String rationCategory = ''; 
  String caste = ''; 
  String otherCaste = ''; 
  int numChildrenAnganwadi = 0; 
  String anganwadiStatus = ''; 
  String childrenMalnutritionStatus = ''; 
  int numPregnantWomen = 0; 
  int numLactatingMothers = 0; 
  String foodAssistanceSufficient = ''; 
  String foodAssistanceNeedDuration = ''; 
  String govtNutritionDisruption = ''; 
  String healthInsuranceStatus = ''; 
  String healthInsuranceDetails = ''; 
  String shelterType = ''; 
  String otherShelterType = ''; 
  String residentialLandArea = ''; 
  String accommodationStatus = ''; 
  String otherAccommodation = ''; 
  String vehiclePossession = ''; 
  String vehicleType = ''; 
  String otherVehicleType = ''; 
  String vehicleLoss = ''; 
  String vehicleLossType = ''; 
  String otherVehicleLossType = '';
  double avgMonthlyFamilyIncome = 0.0; 
  String primaryIncomeSource = ''; 
  String livelihoodAffected = ''; 
  String employmentLoss = '';
  String businessLoss = '';
  String dailyWageLoss = '';
  String breadwinnerLoss = '';
  String animalLoss = '';
  String agriculturalLandLoss = '';
  String otherLivelihoodLoss = ''; 
  String otherLivelihoodLossDetails = ''; 
  String agriculturalLandLossArea = ''; 
  String storedCropsLoss = ''; 
  String cropType = ''; 
  String equipmentLoss = ''; 
  String equipmentLossDetails = ''; 
  String animalHusbandryLoss = ''; 
  String animalHusbandryLossDetails = ''; 
  String shedLoss = ''; 
  String shedLossDetails = ''; 
  String equipmentToolsLoss = ''; 
  String equipmentToolsLossDetails = ''; 
  String livelihoodInsurance = ''; 
  String livelihoodInsuranceDetails = ''; 
  String pensionBeneficiary = ''; 
  String pensionType = ''; 
  String otherPensionType = ''; 
  String mgnregaBeneficiary = ''; 
  String mgnregaDetails = ''; 
  String legalDocumentsLost = ''; 
  String aadharCardLoss = '';
  String governmentIDLoss = '';
  String passportLoss = '';
  String employmentCardLoss = '';
  String panCardLoss = '';
  String insuranceCardLoss = '';
  String drivingLicenseLoss = '';
  String atmCardLoss = '';
  String rationCardLossDoc = '';
  String landDocumentLoss = '';
  String propertyDocumentLoss = '';
  String birthCertificateLoss = '';
  String marriageCertificateLoss = '';
  String educationalDocumentLoss = '';
  String otherDocumentLoss = ''; 
  String otherDocumentLossDetails = ''; 
  String loanRepaymentPending = ''; 
  String specialCategory = ''; 
  String otherSpecialCategory = ''; 
  String kudumbashreeMember = ''; 
  String kudumbashreeNHGName = ''; 
  String kudumbashreeInternalLoan = ''; 
  double kudumbashreeInternalLoanAmount = 0.0; 
  String kudumbashreeLinkageLoan = ''; 
  String? businessDamage;
  double kudumbashreeLinkageLoanAmount = 0.0; 
  String kudumbashreeMicroenterpriseLoan = ''; 
  double kudumbashreeMicroenterpriseLoanAmount = 0.0; 
  String additionalSupportRequired = ''; 
  String foodSecurityAdditionalInfo = '';
  String primaryOccupation = '';
  String secondaryOccupation = '';
  bool outsideDamagedArea = false;
  bool receivedAllowance = false;
  int get numMembers => members.length; 
  List<Member> members = [];
  List<LoanDetail> loanDetails = [];

  NeedAssessmentData();

  // Filtering methods
  static List<Family> filterFamilies(List<Family> families, {
    String? villageWard,
    String? houseNumber,
    String? householdHead,
    double? minIncome,
    double? maxIncome,
    String? shelterType,
    String? rationCategory,
    String? caste,
    bool? outsideDamagedArea,
    bool? receivedAllowance,
    String? memberName,
    String? memberAge,
    int? minAge,
    int? maxAge,
    String? memberGender,
    String? memberEducation,
    String? memberEmploymentType,
    bool? memberUnemployedDueToDisaster,
    bool? memberHasMedicalNeeds,
    bool? memberIsBedridden,
    bool? memberNeedsCounselling,
  }) {
    return families.where((family) {
      final data = family.data;
      if (data == null) return false;

      // Family-level filters
      if (villageWard != null && !data.villageWard.toLowerCase().contains(villageWard.toLowerCase())) {
        return false;
      }

      if (houseNumber != null && !data.houseNumber.toLowerCase().contains(houseNumber.toLowerCase())) {
        return false;
      }

      if (householdHead != null && !data.householdHead.toLowerCase().contains(householdHead.toLowerCase())) {
        return false;
      }

      if (minIncome != null && data.avgMonthlyFamilyIncome < minIncome) {
        return false;
      }

      if (maxIncome != null && data.avgMonthlyFamilyIncome > maxIncome) {
        return false;
      }

      if (shelterType != null && !data.shelterType.toLowerCase().contains(shelterType.toLowerCase())) {
        return false;
      }

      if (rationCategory != null && data.rationCategory != rationCategory) {
        return false;
      }

      if (caste != null && data.caste != caste) {
        return false;
      }

      if (outsideDamagedArea != null && data.outsideDamagedArea != outsideDamagedArea) {
        return false;
      }

      if (receivedAllowance != null && data.receivedAllowance != receivedAllowance) {
        return false;
      }

      // Individual-level filters
      final hasIndividualFilters = memberName != null || 
          memberAge != null || 
          minAge != null || 
          maxAge != null ||
          memberGender != null || 
          memberEducation != null || 
          memberEmploymentType != null || 
          memberUnemployedDueToDisaster != null || 
          memberHasMedicalNeeds != null ||
          memberIsBedridden != null ||
          memberNeedsCounselling != null;

      if (!hasIndividualFilters) {
        return true;
      }

      // Check if any member matches the individual filters
      return data.members.any((member) {
        if (memberName != null && !member.name.toLowerCase().contains(memberName.toLowerCase())) {
          return false;
        }

        if (memberAge != null && member.age != memberAge) {
          return false;
        }

        if (minAge != null) {
          final memberAgeInt = int.tryParse(member.age);
          if (memberAgeInt == null || memberAgeInt < minAge) {
            return false;
          }
        }

        if (maxAge != null) {
          final memberAgeInt = int.tryParse(member.age);
          if (memberAgeInt == null || memberAgeInt > maxAge) {
            return false;
          }
        }

        if (memberGender != null && member.gender != memberGender) {
          return false;
        }

        if (memberEducation != null && member.education != memberEducation) {
          return false;
        }

        if (memberEmploymentType != null && member.employmentType != memberEmploymentType) {
          return false;
        }

        if (memberUnemployedDueToDisaster != null && 
            member.unemployedDueToDisaster != (memberUnemployedDueToDisaster ? 'Yes' : 'No')) {
          return false;
        }

        if (memberHasMedicalNeeds != null && 
            ((memberHasMedicalNeeds && (member.specialMedicalRequirements?.isEmpty ?? true)) || 
             (!memberHasMedicalNeeds && (member.specialMedicalRequirements?.isNotEmpty ?? false)))) {
          return false;
        }

        if (memberIsBedridden != null && 
            member.bedriddenPalliative != (memberIsBedridden ? 'Yes' : 'No')) {
          return false;
        }

        if (memberNeedsCounselling != null && 
            member.psychoSocialAssistance != (memberNeedsCounselling ? 'Yes' : 'No')) {
          return false;
        }

        return true;
      });
    }).toList();
  }

  // Helper method to get distinct values for filters
  static List<String> getDistinctValues(List<Family> families, String propertyName) {
    final values = <String>{};
    
    for (final family in families) {
      final data = family.data;
      if (data == null) continue;

      switch (propertyName) {
        case 'villageWard':
          if (data.villageWard.isNotEmpty) values.add(data.villageWard);
          break;
        case 'shelterType':
          if (data.shelterType.isNotEmpty) values.add(data.shelterType);
          break;
        case 'rationCategory':
          if (data.rationCategory.isNotEmpty) values.add(data.rationCategory);
          break;
        case 'caste':
          if (data.caste.isNotEmpty) values.add(data.caste);
          break;
        case 'primaryIncomeSource':
          if (data.primaryIncomeSource.isNotEmpty) values.add(data.primaryIncomeSource);
          break;
        case 'gender':
          for (final member in data.members) {
            if (member.gender.isNotEmpty) values.add(member.gender);
          }
          break;
        case 'education':
          for (final member in data.members) {
            if (member.education.isNotEmpty) values.add(member.education);
          }
          break;
        case 'employmentType':
          for (final member in data.members) {
            if (member.employmentType.isNotEmpty) values.add(member.employmentType);
          }
          break;
        case 'relationship':
          for (final member in data.members) {
            if (member.relationship.isNotEmpty) values.add(member.relationship);
          }
          break;
      }
    }

    return values.toList()..sort();
  }
}

class Member {
  String name;         
  String age;          
  String gender;       
  String relationship; 
  String maritalStatus = ''; 
  String ldm = ''; // L/D/M
  String aadharNo = ''; 
  String grievouslyInjured = ''; 
  String bedriddenPalliative = ''; 
  String pwDs = ''; 
  String psychoSocialAssistance = ''; 
  String nursingHomeAssistance = ''; 
  String assistiveDevices = ''; 
  String specialMedicalRequirements = ''; 
  String education = ''; 
  String previousStatus = ''; 
  String employmentType = ''; 
  String salary = ''; 
  String unemployedDueToDisaster = ''; 
  String className = ''; 
  String schoolInstituteName = ''; 
  String areDropout = ''; 
  String preferredModeOfEducation = ''; 
  String typesOfAssistanceTransport = ''; 
  String typesOfAssistanceDigitalDevice = ''; 
  String typesOfAssistanceStudyMaterials = ''; 
  String typesOfAssistanceAnyOtherSpecificRequirement = ''; 
  String presentSkillSet = ''; 
  String typeOfLivelihoodAssistanceRequired = ''; 
  String typeOfSkillingAssistanceRequired = '';
  String otherRelationship = '';
  String otherGender = '';

  Member({
    required this.name,
    required this.age,
    required this.relationship,
    required this.gender,
    this.maritalStatus = '',
    this.ldm = '',
    this.aadharNo = '',
    this.grievouslyInjured = '',
    this.bedriddenPalliative = '',
    this.pwDs = '',
    this.psychoSocialAssistance = '',
    this.nursingHomeAssistance = '',
    this.assistiveDevices = '',
    this.specialMedicalRequirements = '',
    this.education = '',
    this.previousStatus = '',
    this.employmentType = '',
    this.salary = '',
    this.unemployedDueToDisaster = '',
    this.className = '',
    this.schoolInstituteName = '',
    this.areDropout = '',
    this.preferredModeOfEducation = '',
    this.typesOfAssistanceTransport = '',
    this.typesOfAssistanceDigitalDevice = '',
    this.typesOfAssistanceStudyMaterials = '',
    this.typesOfAssistanceAnyOtherSpecificRequirement = '',
    this.presentSkillSet = '',
    this.typeOfLivelihoodAssistanceRequired = '',
    this.typeOfSkillingAssistanceRequired = '',
  });

  Member copyWith({
    String? name,
    String? age,
    String? gender,
    String? relationship,
    String? maritalStatus,
    String? ldm,
    String? aadharNo,
    String? grievouslyInjured,
    String? bedriddenPalliative,
    String? pwDs,
    String? psychoSocialAssistance,
    String? nursingHomeAssistance,
    String? assistiveDevices,
    String? specialMedicalRequirements,
    String? education,
    String? previousStatus,
    String? employmentType,
    String? salary,
    String? unemployedDueToDisaster,
    String? className,
    String? schoolInstituteName,
    String? areDropout,
    String? preferredModeOfEducation,
    String? typesOfAssistanceTransport,
    String? typesOfAssistanceDigitalDevice,
    String? typesOfAssistanceStudyMaterials,
    String? typesOfAssistanceAnyOtherSpecificRequirement,
    String? presentSkillSet,
    String? typeOfLivelihoodAssistanceRequired,
    String? typeOfSkillingAssistanceRequired,
  }) {
    return Member(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      ldm: ldm ?? this.ldm,
      aadharNo: aadharNo ?? this.aadharNo,
      grievouslyInjured: grievouslyInjured ?? this.grievouslyInjured,
      bedriddenPalliative: bedriddenPalliative ?? this.bedriddenPalliative,
      pwDs: pwDs ?? this.pwDs,
      psychoSocialAssistance: psychoSocialAssistance ?? this.psychoSocialAssistance,
      nursingHomeAssistance: nursingHomeAssistance ?? this.nursingHomeAssistance,
      assistiveDevices: assistiveDevices ?? this.assistiveDevices,
      specialMedicalRequirements: specialMedicalRequirements ?? this.specialMedicalRequirements,
      education: education ?? this.education,
      previousStatus: previousStatus ?? this.previousStatus,
      employmentType: employmentType ?? this.employmentType,
      salary: salary ?? this.salary,
      unemployedDueToDisaster: unemployedDueToDisaster ?? this.unemployedDueToDisaster,
      className: className ?? this.className,
      schoolInstituteName: schoolInstituteName ?? this.schoolInstituteName,
      areDropout: areDropout ?? this.areDropout,
      preferredModeOfEducation: preferredModeOfEducation ?? this.preferredModeOfEducation,
      typesOfAssistanceTransport: typesOfAssistanceTransport ?? this.typesOfAssistanceTransport,
      typesOfAssistanceDigitalDevice: typesOfAssistanceDigitalDevice ?? this.typesOfAssistanceDigitalDevice,
      typesOfAssistanceStudyMaterials: typesOfAssistanceStudyMaterials ?? this.typesOfAssistanceStudyMaterials,
      typesOfAssistanceAnyOtherSpecificRequirement: typesOfAssistanceAnyOtherSpecificRequirement ?? this.typesOfAssistanceAnyOtherSpecificRequirement,
      presentSkillSet: presentSkillSet ?? this.presentSkillSet,
      typeOfLivelihoodAssistanceRequired: typeOfLivelihoodAssistanceRequired ?? this.typeOfLivelihoodAssistanceRequired,
      typeOfSkillingAssistanceRequired: typeOfSkillingAssistanceRequired ?? this.typeOfSkillingAssistanceRequired,
    );
  }
}

class LoanDetail {
  String bankName;
  String branch;
  String accountNumber;
  String loanCategory;
  String loanAmount;
  String loanOutstanding;

  LoanDetail({
    this.bankName = '',
    this.branch = '',
    this.accountNumber = '',
    this.loanCategory = '',
    this.loanAmount = '',
    this.loanOutstanding = '',
  });
  
  LoanDetail copyWith({
    String? bankName,
    String? branch,
    String? accountNumber,
    String? loanCategory,
    String? loanAmount,
    String? loanOutstanding,
  }) {
    return LoanDetail(
      bankName: bankName ?? this.bankName,
      branch: branch ?? this.branch,
      accountNumber: accountNumber ?? this.accountNumber,
      loanCategory: loanCategory ?? this.loanCategory,
      loanAmount: loanAmount ?? this.loanAmount,
      loanOutstanding: loanOutstanding ?? this.loanOutstanding,
    );
  }
}

class Family {
  final String id;
  final NeedAssessmentData? data;

  Family({required this.id, this.data});
}