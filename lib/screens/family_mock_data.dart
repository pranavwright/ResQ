import 'family_data_download.dart';
import 'package:resq/models/NeedAssessmentData.dart';

List<Family> generateMockFamilies() {
  return [
    Family(
      id: 'F001',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 1'
        ..houseNumber = '123'
        ..householdHead = 'John Doe'
        ..uniqueHouseholdId = 'HH001'
        ..address = '123 Main St, Disaster Zone A'
        ..contactNo = '9876543210'
        ..rationCardNo = 'RC001'
        ..rationCategory = 'APL'
        ..caste = 'General'
        ..numChildrenAnganwadi = 2
        ..numPregnantWomen = 1
        ..shelterType = 'Own House'
        ..avgMonthlyFamilyIncome = 15000.0
        ..primaryIncomeSource = 'Agriculture'
        ..livelihoodAffected = 'Yes'
        ..members = [
          Member(
            name: 'John Doe',
            age: '35',
            gender: 'Male',
            relationship: 'Head',
            education: 'High School',
            employmentType: 'Self-employed',
            salary: '15000',
          ),
          Member(
            name: 'Jane Doe',
            age: '30',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'High School',
            employmentType: 'Homemaker',
          ),
          Member(
            name: 'Baby Doe',
            age: '5',
            gender: 'Male',
            relationship: 'Son',
            education: 'Anganwadi',
          ),
        ],
    ),
    Family(
      id: 'F002',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 2'
        ..houseNumber = '456'
        ..householdHead = 'Robert Smith'
        ..uniqueHouseholdId = 'HH002'
        ..address = '456 Oak Ave, Disaster Zone B'
        ..contactNo = '9876543211'
        ..rationCardNo = 'RC002'
        ..rationCategory = 'BPL'
        ..caste = 'SC'
        ..numChildrenAnganwadi = 1
        ..shelterType = 'Rented House'
        ..avgMonthlyFamilyIncome = 10000.0
        ..primaryIncomeSource = 'Daily Wage'
        ..livelihoodAffected = 'Yes'
        ..employmentLoss = 'Yes'
        ..members = [
          Member(
            name: 'Robert Smith',
            age: '45',
            gender: 'Male',
            relationship: 'Head',
            education: 'Primary',
            employmentType: 'Daily Wage',
            salary: '10000',
            unemployedDueToDisaster: 'Yes',
          ),
          Member(
            name: 'Maria Smith',
            age: '40',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'Primary',
            employmentType: 'Daily Wage',
            salary: '8000',
          ),
        ],
    ),
    // Add 8 more families with similar structure
    Family(
      id: 'F003',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 3'
        ..houseNumber = '789'
        ..householdHead = 'David Johnson'
        ..uniqueHouseholdId = 'HH003'
        ..address = '789 Pine Rd, Disaster Zone A'
        ..contactNo = '9876543212'
        ..rationCardNo = 'RC003'
        ..rationCategory = 'APL'
        ..caste = 'ST'
        ..numChildrenAnganwadi = 0
        ..numPregnantWomen = 0
        ..shelterType = 'Own House'
        ..avgMonthlyFamilyIncome = 25000.0
        ..primaryIncomeSource = 'Business'
        ..livelihoodAffected = 'No'
        ..members = [
          Member(
            name: 'David Johnson',
            age: '50',
            gender: 'Male',
            relationship: 'Head',
            education: 'University',
            employmentType: 'Business',
            salary: '25000',
          ),
          Member(
            name: 'Sarah Johnson',
            age: '48',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'College',
            employmentType: 'Homemaker',
          ),
        ],
    ),
    Family(
      id: 'F004',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 1'
        ..houseNumber = '321'
        ..householdHead = 'Michael Brown'
        ..uniqueHouseholdId = 'HH004'
        ..address = '321 Elm St, Disaster Zone C'
        ..contactNo = '9876543213'
        ..rationCardNo = 'RC004'
        ..rationCategory = 'BPL'
        ..caste = 'OBC'
        ..numChildrenAnganwadi = 3
        ..numPregnantWomen = 0
        ..shelterType = 'Temporary Shelter'
        ..avgMonthlyFamilyIncome = 8000.0
        ..primaryIncomeSource = 'Agriculture'
        ..livelihoodAffected = 'Yes'
        ..agriculturalLandLoss = 'Yes'
        ..members = [
          Member(
            name: 'Michael Brown',
            age: '60',
            gender: 'Male',
            relationship: 'Head',
            education: 'Primary',
            employmentType: 'Farmer',
            salary: '8000',
          ),
          Member(
            name: 'Emily Brown',
            age: '55',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'None',
            employmentType: 'Homemaker',
          ),
          Member(
            name: 'Child 1 Brown',
            age: '10',
            gender: 'Male',
            relationship: 'Son',
            education: 'Primary',
          ),
          Member(
            name: 'Child 2 Brown',
            age: '8',
            gender: 'Female',
            relationship: 'Daughter',
            education: 'Primary',
          ),
          Member(
            name: 'Child 3 Brown',
            age: '4',
            gender: 'Male',
            relationship: 'Son',
            education: 'Anganwadi',
          ),
        ],
    ),
    Family(
      id: 'F005',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 2'
        ..houseNumber = '654'
        ..householdHead = 'James Wilson'
        ..uniqueHouseholdId = 'HH005'
        ..address = '654 Maple Dr, Disaster Zone B'
        ..contactNo = '9876543214'
        ..rationCardNo = 'RC005'
        ..rationCategory = 'APL'
        ..caste = 'General'
        ..numChildrenAnganwadi = 0
        ..numPregnantWomen = 1
        ..shelterType = 'Own House'
        ..avgMonthlyFamilyIncome = 30000.0
        ..primaryIncomeSource = 'Government Job'
        ..livelihoodAffected = 'No'
        ..members = [
          Member(
            name: 'James Wilson',
            age: '42',
            gender: 'Male',
            relationship: 'Head',
            education: 'University',
            employmentType: 'Government',
            salary: '30000',
          ),
          Member(
            name: 'Jennifer Wilson',
            age: '38',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'College',
            employmentType: 'Teacher',
            salary: '20000',
          ),
          Member(
            name: 'Teen Wilson',
            age: '15',
            gender: 'Female',
            relationship: 'Daughter',
            education: 'High School',
          ),
        ],
    ),
      Family(
      id: 'F006',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 3'
        ..houseNumber = '987'
        ..householdHead = 'William Anderson'
        ..uniqueHouseholdId = 'HH006'
        ..address = '987 Birch Ln, Disaster Zone A'
        ..contactNo = '9876543215'
        ..rationCardNo = 'RC006'
        ..rationCategory = 'BPL'
        ..caste = 'SC'
        ..numChildrenAnganwadi = 1
        ..shelterType = 'Temporary Shelter'
        ..avgMonthlyFamilyIncome = 7000.0
        ..primaryIncomeSource = 'Fisherman'
        ..livelihoodAffected = 'Yes'
        ..employmentLoss = 'Yes'
        ..members = [
          Member(
            name: 'William Anderson',
            age: '50',
            gender: 'Male',
            relationship: 'Head',
            education: 'High School',
            employmentType: 'Fisherman',
            salary: '7000',
            unemployedDueToDisaster: 'Yes',
          ),
          Member(
            name: 'Linda Anderson',
            age: '45',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'Primary',
            employmentType: 'Homemaker',
          ),
          Member(
            name: 'Charlie Anderson',
            age: '3',
            gender: 'Male',
            relationship: 'Son',
            education: 'Anganwadi',
          ),
        ],
    ),
    Family(
      id: 'F007',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 1'
        ..houseNumber = '159'
        ..householdHead = 'Richard Martinez'
        ..uniqueHouseholdId = 'HH007'
        ..address = '159 Cedar St, Disaster Zone C'
        ..contactNo = '9876543216'
        ..rationCardNo = 'RC007'
        ..rationCategory = 'APL'
        ..caste = 'OBC'
        ..numChildrenAnganwadi = 0
        ..numPregnantWomen = 0
        ..shelterType = 'Own House'
        ..avgMonthlyFamilyIncome = 20000.0
        ..primaryIncomeSource = 'Retail Business'
        ..livelihoodAffected = 'Yes'
        ..businessDamage = 'Yes'
        ..members = [
          Member(
            name: 'Richard Martinez',
            age: '48',
            gender: 'Male',
            relationship: 'Head',
            education: 'University',
            employmentType: 'Business Owner',
            salary: '20000',
          ),
          Member(
            name: 'Sophia Martinez',
            age: '46',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'University',
            employmentType: 'Teacher',
            salary: '18000',
          ),
          Member(
            name: 'Lily Martinez',
            age: '17',
            gender: 'Female',
            relationship: 'Daughter',
            education: 'High School',
          ),
        ],
    ),
    Family(
      id: 'F008',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 2'
        ..houseNumber = '753'
        ..householdHead = 'Thomas Lee'
        ..uniqueHouseholdId = 'HH008'
        ..address = '753 Oakwood Dr, Disaster Zone B'
        ..contactNo = '9876543217'
        ..rationCardNo = 'RC008'
        ..rationCategory = 'BPL'
        ..caste = 'ST'
        ..numChildrenAnganwadi = 2
        ..numPregnantWomen = 1
        ..shelterType = 'Makeshift Tent'
        ..avgMonthlyFamilyIncome = 5000.0
        ..primaryIncomeSource = 'Daily Wage'
        ..livelihoodAffected = 'Yes'
        ..employmentLoss = 'Yes'
        ..members = [
          Member(
            name: 'Thomas Lee',
            age: '35',
            gender: 'Male',
            relationship: 'Head',
            education: 'Primary',
            employmentType: 'Daily Wage',
            salary: '5000',
            unemployedDueToDisaster: 'Yes',
          ),
          Member(
            name: 'Anna Lee',
            age: '32',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'None',
            employmentType: 'Homemaker',
          ),
          Member(
            name: 'Lucy Lee',
            age: '6',
            gender: 'Female',
            relationship: 'Daughter',
            education: 'Anganwadi',
          ),
          Member(
            name: 'Leo Lee',
            age: '4',
            gender: 'Male',
            relationship: 'Son',
            education: 'Anganwadi',
          ),
        ],
    ),
    Family(
      id: 'F009',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 3'
        ..houseNumber = '258'
        ..householdHead = 'Christopher Harris'
        ..uniqueHouseholdId = 'HH009'
        ..address = '258 Willow St, Disaster Zone C'
        ..contactNo = '9876543218'
        ..rationCardNo = 'RC009'
        ..rationCategory = 'APL'
        ..caste = 'General'
        ..numChildrenAnganwadi = 0
        ..numPregnantWomen = 0
        ..shelterType = 'Own House'
        ..avgMonthlyFamilyIncome = 35000.0
        ..primaryIncomeSource = 'IT Professional'
        ..livelihoodAffected = 'No'
        ..members = [
          Member(
            name: 'Christopher Harris',
            age: '40',
            gender: 'Male',
            relationship: 'Head',
            education: 'University',
            employmentType: 'Software Engineer',
            salary: '35000',
          ),
          Member(
            name: 'Olivia Harris',
            age: '38',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'University',
            employmentType: 'Doctor',
            salary: '50000',
          ),
          Member(
            name: 'Ella Harris',
            age: '12',
            gender: 'Female',
            relationship: 'Daughter',
            education: 'Middle School',
          ),
        ],
    ),
    Family(
      id: 'F010',
      data: NeedAssessmentData()
        ..villageWard = 'Ward 1'
        ..houseNumber = '369'
        ..householdHead = 'Daniel White'
        ..uniqueHouseholdId = 'HH010'
        ..address = '369 Aspen Rd, Disaster Zone A'
        ..contactNo = '9876543219'
        ..rationCardNo = 'RC010'
        ..rationCategory = 'BPL'
        ..caste = 'OBC'
        ..numChildrenAnganwadi = 1
        ..shelterType = 'Community Shelter'
        ..avgMonthlyFamilyIncome = 6000.0
        ..primaryIncomeSource = 'Handicrafts'
        ..livelihoodAffected = 'Yes'
        ..businessDamage = 'Yes'
        ..members = [
          Member(
            name: 'Daniel White',
            age: '55',
            gender: 'Male',
            relationship: 'Head',
            education: 'High School',
            employmentType: 'Handicraftsman',
            salary: '6000',
          ),
          Member(
            name: 'Nancy White',
            age: '52',
            gender: 'Female',
            relationship: 'Spouse',
            education: 'None',
            employmentType: 'Homemaker',
          ),
          Member(
            name: 'Chris White',
            age: '7',
            gender: 'Male',
            relationship: 'Son',
            education: 'Primary',
          ),
        ],
    ),

  ];
}