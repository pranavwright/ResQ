class NeedAssessmentData {
  String villageWard = ''; // [cite: 1]
  String houseNumber = ''; // [cite: 1]
  String householdHead = ''; // [cite: 1]
  String uniqueHouseholdId = ''; // [cite: 1]
  String address = ''; // [cite: 1]
  String contactNo = ''; // [cite: 1]
  String rationCardNo = ''; // [cite: 1]
  String rationCategory = ''; // [cite: 1]
  String caste = ''; // [cite: 1]
  String otherCaste = ''; // For "Other" caste specification [cite: 2]
  int numChildrenAnganwadi = 0; // Total number of children enrolled in Anganwadi centers [cite: 4]
  String anganwadiStatus = ''; // Is the Anganwadi damaged? Yes/No [cite: 4]
  String childrenMalnutritionStatus = ''; // Any children with malnutrition [cite: 4]
  int numPregnantWomen = 0; // Pregnant women in the family [cite: 4]
  int numLactatingMothers = 0; // Lactating mothers in the family [cite: 4]
  String foodAssistanceSufficient = ''; // Is the present food assistance sufficient? Yes/No [cite: 4]
  String foodAssistanceNeedDuration = ''; // How long do you need food assistance [cite: 4]
  String govtNutritionDisruption = ''; // Disruption in government nutrition service [cite: 4]
  String healthInsuranceStatus = ''; // Do you have health insurance coverage? Yes/No [cite: 6]
  String healthInsuranceDetails = ''; // If Yes, specify: [cite: 6]
  String shelterType = ''; // Type of house [cite: 7]
  String otherShelterType = ''; // For "Others" shelter type specification [cite: 8]
  String residentialLandArea = ''; // Extend (area) of residential land [cite: 8]
  String accommodationStatus = ''; // Accommodation in the aftermath of the disaster [cite: 8, 9]
  String otherAccommodation = ''; // If Others, specify: [cite: 9]
  String vehiclePossession = ''; // Do you possess any Vehicle before the disaster: Yes/No [cite: 9]
  String vehicleType = ''; // If Yes, specify: [cite: 9]
  String otherVehicleType = ''; // If Any other, specify (vehicle number and details): [cite: 9]
  String vehicleLoss = ''; // Any Vehicle lost in the aftermath of the disaster: Yes/No [cite: 9]
  String vehicleLossType = ''; // [cite: 9]
  String otherVehicleLossType = '';
  double avgMonthlyFamilyIncome = 0.0; // What was your average monthly family income? [cite: 12]
  String primaryIncomeSource = ''; // Primary Source of Income [cite: 12]
  String livelihoodAffected = ''; // Source of livelihood affected or not: Yes/No [cite: 12]
  String employmentLoss = '';
  String businessLoss = '';
  String dailyWageLoss = '';
  String breadwinnerLoss = '';
  String animalLoss = '';
  String agriculturalLandLoss = '';
  String otherLivelihoodLoss = ''; // [cite: 13]
  String otherLivelihoodLossDetails = ''; // If Other, specify: [cite: 13]
  String agriculturalLandLossArea = ''; // Did you incur any loss of agricultural land (area): [cite: 17]
  String storedCropsLoss = ''; // Did you experience any loss of stored crops (quantity): [cite: 17]
  String cropType = ''; // If Yes, type of Crop: [cite: 17]
  String equipmentLoss = ''; // Did you lose any equipment/Tools/vehicles: Yes/No [cite: 17]
  String equipmentLossDetails = ''; // If Yes, specify: [cite: 17]
  String animalHusbandryLoss = ''; // Have you suffered the loss of any Cattle or Poultry: Yes/No [cite: 17]
  String animalHusbandryLossDetails = ''; // If Yes, specify number and type: [cite: 17]
  String shedLoss = ''; // Have you lost any Poultry Shed or Cattle Shed: Yes/No [cite: 17]
  String shedLossDetails = ''; // If Yes, specify number and type: [cite: 17]
  String equipmentToolsLoss = ''; // Did you lose any equipment or Tools: Yes/No [cite: 17]
  String equipmentToolsLossDetails = ''; // If Yes, specify the items: [cite: 17]
  String livelihoodInsurance = ''; // Do you have any livelihood Insurance Coverage (agricultural land-crop/animals): Yes/No [cite: 17]
  String livelihoodInsuranceDetails = ''; // If Yes, specify the details: [cite: 17]
  String pensionBeneficiary = ''; // Are you or anyone in your family currently a beneficiary of any pension: Yes/No [cite: 18]
  String pensionType = ''; // Old Age Pension / Widow Pension / Divyang Pension / Others [cite: 18]
  String otherPensionType = ''; // If Others, specify: [cite: 18]
  String mgnregaBeneficiary = ''; // Is anyone in your family a beneficiary of MGNREGA Scheme: Yes/No [cite: 18]
  String mgnregaDetails = ''; // If Yes, specify details: [cite: 18]
  String legalDocumentsLost = ''; // Have you lost any of the following legal documents: Yes/No [cite: 18]
  // Individual document loss fields
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
  String otherDocumentLoss = ''; // [cite: 19]
  String otherDocumentLossDetails = ''; // If Others, specify: [cite: 19]
  String loanRepaymentPending = ''; // Do you have any loan repayment (bank/cooperatives/private) pending: Yes/No [cite: 19]
  String specialCategory = ''; // Are you part of any special category: [cite: 21]
  String otherSpecialCategory = ''; // If Others, specify: [cite: 21]
  String kudumbashreeMember = ''; // Are you a member of any Kudumbashree community: Yes/No [cite: 21]
  String kudumbashreeNHGName = ''; // If yes, what is the name of your Neighborhood Group (NHG): [cite: 21]
  String kudumbashreeInternalLoan = ''; // Have you taken any internal loans through your NHG: Yes/No [cite: 21]
  double kudumbashreeInternalLoanAmount = 0.0; // If yes, specify the amount: [cite: 21]
  String kudumbashreeLinkageLoan = ''; // Have you taken any linkage loans through your NHG: Yes/No [cite: 21]
  double kudumbashreeLinkageLoanAmount = 0.0; // If yes, specify the amount: [cite: 21]
  String kudumbashreeMicroenterpriseLoan = ''; // Have you taken any micro-enterprise loans through your NHG: Yes/No [cite: 21]
  double kudumbashreeMicroenterpriseLoanAmount = 0.0; // If yes, specify the amount: [cite: 21]
  String additionalSupportRequired = ''; // Any Specific Assistance or Support needed? [cite: 22]
  String foodSecurityAdditionalInfo = '';
  int numMembers = 2; // Number of family members [cite: 3]
  List<Member> members = [
    Member(name: 'John Doe', age: '35', relationship: 'Head', gender: 'Male'),
    Member(name: 'Jane Doe', age: '30', relationship: 'Wife', gender: 'Female'),
  ];

  //Loan Details
  List<LoanDetail> loanDetails = [
    LoanDetail(
        bankName: "Bank A",
        branch: "Branch 1",
        accountNumber: "12345",
        loanCategory: "Home Loan",
        loanAmount: "100000",
        loanOutstanding: "50000"),
    LoanDetail(
        bankName: "Bank B",
        branch: "Branch 2",
        accountNumber: "67890",
        loanCategory: "Personal Loan",
        loanAmount: "50000",
        loanOutstanding: "25000")
  ];


  NeedAssessmentData();
}

class Member {
  String name; // [cite: 3, 5, 11, 14, 16]
  String age; // [cite: 3]
  String gender; // [cite: 3]
  String relationship; // Position in the family [cite: 3]
  String maritalStatus = ''; // [cite: 3]
  String ldm = ''; // L/D/M [cite: 3]
  String aadharNo = ''; // [cite: 3]
  String grievouslyInjured = ''; // [cite: 5]
  String bedriddenPalliative = ''; // [cite: 5]
  String pwDs = ''; // [cite: 5]
  String psychoSocialAssistance = ''; // [cite: 5]
  String nursingHomeAssistance = ''; // [cite: 5]
  String assistiveDevices = ''; // [cite: 5]
  String specialMedicalRequirements = ''; // [cite: 5]
  String education = ''; // [cite: 14]
  String previousStatus = ''; // (Employed/Unemployed/Self-employed/Unemployed due to health condition) [cite: 14]
  String employmentType = ''; // Govt/Pvt [cite: 14]
  String salary = ''; // [cite: 14]
  String unemployedDueToDisaster = ''; // Whether unemployed due to disaster [cite: 14]
  String className = ''; // Class/course [cite: 11]
  String schoolInstituteName = ''; // School/Institution [cite: 11]
  String areDropout = ''; // Are Dropout [cite: 11]
  String preferredModeOfEducation = ''; // Preferred mode of education - regular(R)/open(O) [cite: 11]
  String typesOfAssistanceTransport = ''; // Types of assistance - Transportation [cite: 11]
  String typesOfAssistanceDigitalDevice = ''; // Digital device [cite: 11]
  String typesOfAssistanceStudyMaterials = ''; // Study materials [cite: 11]
  String typesOfAssistanceAnyOtherSpecificRequirement = ''; // Any other specific requirement [cite: 11]
  String presentSkillSet = ''; // [cite: 16]
  String typeOfLivelihoodAssistanceRequired = ''; // [cite: 16]
  String typeOfSkillingAssistanceRequired = ''; // [cite: 16]

  Member({
    required this.name,
    required this.age,
    required this.relationship,
    required this.gender,
  });
}


class LoanDetail {
  String bankName; // [cite: 20]
  String branch; // [cite: 20]
  String accountNumber; // A/C Number [cite: 20]
  String loanCategory; // [cite: 20]
  String loanAmount; // [cite: 20]
  String loanOutstanding; // [cite: 20]

  LoanDetail(
      {required this.bankName,
      required this.branch,
      required this.accountNumber,
      required this.loanCategory,
      required this.loanAmount,
      required this.loanOutstanding});
}