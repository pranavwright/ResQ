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
  static List<Family> filterFamilies(
    List<Family> families,
    Map<String, dynamic> filters,
  ) {
    return families.where((family) {
      final data = family.data;
      if (data == null) return false;

      // Family-level filters
      if (filters['villageWard'] != null) {
        if (filters['villageWard'] is String) {
          if (!data.villageWard
              .toLowerCase()
              .contains(filters['villageWard'].toLowerCase())) {
            return false;
          }
        } else if (filters['villageWard'] is List) {
          if (!filters['villageWard'].contains(data.villageWard)) {
            return false;
          }
        }
      }

      if (filters['houseNumber'] != null) {
        if (filters['houseNumber'] is String) {
          if (!data.houseNumber
              .toLowerCase()
              .contains(filters['houseNumber'].toLowerCase())) {
            return false;
          }
        } else if (filters['houseNumber'] is List) {
          if (!filters['houseNumber'].contains(data.houseNumber)) {
            return false;
          }
        }
      }

      if (filters['householdHead'] != null) {
        if (filters['householdHead'] is String) {
          if (!data.householdHead
              .toLowerCase()
              .contains(filters['householdHead'].toLowerCase())) {
            return false;
          }
        } else if (filters['householdHead'] is List) {
          if (!filters['householdHead'].contains(data.householdHead)) {
            return false;
          }
        }
      }

      if (filters['avgMonthlyFamilyIncome'] != null) {
        if (filters['avgMonthlyFamilyIncome'] is Map) {
          final minIncome =
              filters['avgMonthlyFamilyIncome']['min'] as double?;
          final maxIncome =
              filters['avgMonthlyFamilyIncome']['max'] as double?;
          if (minIncome != null && data.avgMonthlyFamilyIncome < minIncome) {
            return false;
          }
          if (maxIncome != null && data.avgMonthlyFamilyIncome > maxIncome) {
            return false;
          }
        } else if (filters['avgMonthlyFamilyIncome'] is double) {
          if (data.avgMonthlyFamilyIncome !=
              filters['avgMonthlyFamilyIncome']) {
            return false;
          }
        }
      }

      if (filters['shelterType'] != null) {
        if (filters['shelterType'] is String) {
          if (!data.shelterType
              .toLowerCase()
              .contains(filters['shelterType'].toLowerCase())) {
            return false;
          }
        } else if (filters['shelterType'] is List) {
          if (!filters['shelterType'].contains(data.shelterType)) {
            return false;
          }
        }
      }

      if (filters['rationCategory'] != null) {
        if (filters['rationCategory'] is String) {
          if (data.rationCategory != filters['rationCategory']) {
            return false;
          }
        } else if (filters['rationCategory'] is List) {
          if (!filters['rationCategory'].contains(data.rationCategory)) {
            return false;
          }
        }
      }

      if (filters['caste'] != null) {
        if (filters['caste'] is String) {
          if (data.caste != filters['caste']) {
            return false;
          }
        } else if (filters['caste'] is List) {
          if (!filters['caste'].contains(data.caste)) {
            return false;
          }
        }
      }

      if (filters['outsideDamagedArea'] != null &&
          data.outsideDamagedArea != filters['outsideDamagedArea']) {
        return false;
      }

      if (filters['receivedAllowance'] != null &&
          data.receivedAllowance != filters['receivedAllowance']) {
        return false;
      }

      // Individual-level filters
      final hasIndividualFilters = filters.keys
          .any((key) => key.startsWith('member')); //check if any key starts with member

      if (!hasIndividualFilters) {
        return true;
      }

      // Check if any member matches the individual filters
      return data.members.any((member) {
        if (filters['memberName'] != null) {
          if (filters['memberName'] is String) {
            if (!member.name
                .toLowerCase()
                .contains(filters['memberName'].toLowerCase())) {
              return false;
            }
          } else if (filters['memberName'] is List) {
            if (!filters['memberName'].contains(member.name)) {
              return false;
            }
          }
        }

        if (filters['memberAge'] != null) {
          if (filters['memberAge'] is String) {
            if (member.age != filters['memberAge']) {
              return false;
            }
          } else if (filters['memberAge'] is Map) {
            final minAge = filters['memberAge']['min'] as int?;
            final maxAge = filters['memberAge']['max'] as int?;
            final memberAgeInt = int.tryParse(member.age);
            if (memberAgeInt == null) return false;
            if (minAge != null && memberAgeInt < minAge) {
              return false;
            }
            if (maxAge != null && memberAgeInt > maxAge) {
              return false;
            }
          }
        }

        if (filters['memberGender'] != null) {
          if (filters['memberGender'] is String) {
            if (member.gender != filters['memberGender']) {
              return false;
            }
          } else if (filters['memberGender'] is List) {
            if (!filters['memberGender'].contains(member.gender)) {
              return false;
            }
          }
        }

        if (filters['memberEducation'] != null) {
          if (filters['memberEducation'] is String) {
            if (member.education != filters['memberEducation']) {
              return false;
            }
          } else if (filters['memberEducation'] is List) {
            if (!filters['memberEducation'].contains(member.education)) {
              return false;
            }
          }
        }

        if (filters['memberEmploymentType'] != null) {
          if (filters['memberEmploymentType'] is String) {
            if (member.employmentType != filters['memberEmploymentType']) {
              return false;
            }
          } else if (filters['memberEmploymentType'] is List) {
            if (!filters['memberEmploymentType']
                .contains(member.employmentType)) {
              return false;
            }
          }
        }

        if (filters['memberUnemployedDueToDisaster'] != null) {
          final expectedValue =
              filters['memberUnemployedDueToDisaster'] ? 'Yes' : 'No';
          if (member.unemployedDueToDisaster != expectedValue) {
            return false;
          }
        }

        if (filters['memberHasMedicalNeeds'] != null) {
          final hasMedicalNeeds =
              member.specialMedicalRequirements?.isNotEmpty ?? false;
          if (hasMedicalNeeds != filters['memberHasMedicalNeeds']) {
            return false;
          }
        }

        if (filters['memberIsBedridden'] != null) {
          final isBedridden = member.bedriddenPalliative == 'Yes';
          if (isBedridden != filters['memberIsBedridden']) {
            return false;
          }
        }

        if (filters['memberNeedsCounselling'] != null) {
          final needsCounselling = member.psychoSocialAssistance == 'Yes';
          if (needsCounselling != filters['memberNeedsCounselling']) {
            return false;
          }
        }

        return true;
      });
    }).toList();
  }

  // Helper method to get distinct values for filters
  static List<String> getDistinctValues(
      List<Family> families, String propertyName) {
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
          if (data.primaryIncomeSource.isNotEmpty)
            values.add(data.primaryIncomeSource);
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
            if (member.employmentType.isNotEmpty)
              values.add(member.employmentType);
          }
          break;
        case 'relationship':
          for (final member in data.members) {
            if (member.relationship.isNotEmpty)
              values.add(member.relationship);
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
    this.otherRelationship = '',
    this.otherGender = '',
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
    String? otherRelationship,
    String? otherGender,
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
      psychoSocialAssistance:
          psychoSocialAssistance ?? this.psychoSocialAssistance,
      nursingHomeAssistance:
          nursingHomeAssistance ?? this.nursingHomeAssistance,
      assistiveDevices: assistiveDevices ?? this.assistiveDevices,
      specialMedicalRequirements:
          specialMedicalRequirements ?? this.specialMedicalRequirements,
      education: education ?? this.education,
      previousStatus: previousStatus ?? this.previousStatus,
      employmentType: employmentType ?? this.employmentType,
      salary: salary ?? this.salary,
      unemployedDueToDisaster:
          unemployedDueToDisaster ?? this.unemployedDueToDisaster,
      className: className ?? this.className,
      schoolInstituteName: schoolInstituteName ?? this.schoolInstituteName,
      areDropout: areDropout ?? this.areDropout,
      preferredModeOfEducation:
          preferredModeOfEducation ?? this.preferredModeOfEducation,
      typesOfAssistanceTransport:
          typesOfAssistanceTransport ?? this.typesOfAssistanceTransport,
      typesOfAssistanceDigitalDevice: typesOfAssistanceDigitalDevice ??
          this.typesOfAssistanceDigitalDevice,
      typesOfAssistanceStudyMaterials: typesOfAssistanceStudyMaterials ??
          this.typesOfAssistanceStudyMaterials,
      typesOfAssistanceAnyOtherSpecificRequirement:
          typesOfAssistanceAnyOtherSpecificRequirement ??
              this.typesOfAssistanceAnyOtherSpecificRequirement,
      presentSkillSet: presentSkillSet ?? this.presentSkillSet,
      typeOfLivelihoodAssistanceRequired: typeOfLivelihoodAssistanceRequired ??
          this.typeOfLivelihoodAssistanceRequired,
      typeOfSkillingAssistanceRequired: typeOfSkillingAssistanceRequired ??
          this.typeOfSkillingAssistanceRequired,
      otherRelationship: otherRelationship ?? this.otherRelationship,
      otherGender: otherGender ?? this.otherGender,
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
