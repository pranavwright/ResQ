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
  double kudumbashreeLinkageLoanAmount = 0.0; 
  String kudumbashreeMicroenterpriseLoan = ''; 
  double kudumbashreeMicroenterpriseLoanAmount = 0.0; 
  String additionalSupportRequired = ''; 
  String foodSecurityAdditionalInfo = '';
  String primaryOccupation = '';
  String secondaryOccupation = '';
  int numMembers = 2; 
  List<Member> members = [
    Member(name: 'John Doe', age: '35', relationship: 'Head', gender: 'Male'),
    Member(name: 'Jane Doe', age: '30', relationship: 'Wife', gender: 'Female'),
  ];

  // Example list of LoanDetail
  List<LoanDetail> loanDetails = [
    LoanDetail(
      bankName: "Bank A",
      branch: "Branch 1",
      accountNumber: "12345",
      loanCategory: "Home Loan",
      loanAmount: "100000",
      loanOutstanding: "50000",
    ),
    LoanDetail(
      bankName: "Bank B",
      branch: "Branch 2",
      accountNumber: "67890",
      loanCategory: "Personal Loan",
      loanAmount: "50000",
      loanOutstanding: "25000",
    ),
  ];

  NeedAssessmentData();
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