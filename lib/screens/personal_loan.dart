import 'package:flutter/material.dart';
import 'package:resq/screens/special_category.dart';

class PersonalLoan extends StatefulWidget {
  const PersonalLoan({super.key});

  @override
  _PersonalLoanState createState() => _PersonalLoanState();
}

class _PersonalLoanState extends State<PersonalLoan> {
  // List to hold data for multiple bank details
  List<Map<String, TextEditingController>> bankDetailsList = [];

  // Initialize one bank detail set
  @override
  void initState() {
    super.initState();
    _addNewBankDetail();  // Add initial set of bank details
  }

  // Function to add a new set of text controllers for bank details
  void _addNewBankDetail() {
    setState(() {
      bankDetailsList.add({
        'bankname': TextEditingController(),
        'branch': TextEditingController(),
        'accountNumber': TextEditingController(),
        'loanCategory': TextEditingController(),
        'loanAmount': TextEditingController(),
        'loanOutstanding': TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var bankDetail in bankDetailsList) {
      bankDetail.values.forEach((controller) {
        controller.dispose();
      });
    }
    super.dispose();
  }

  // Function to navigate to the next page
  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SpecialCategory()),  // Navigate to the next page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Loan Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
             Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/social',
                  (route) => false,
                ); // Pops the current screen off the navigation stack
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Bank Loan Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic form for each bank detail set
            Expanded(
              child: ListView.builder(
                itemCount: bankDetailsList.length,
                itemBuilder: (context, index) {
                  final bankDetails = bankDetailsList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: bankDetails['bankname'],
                            decoration: const InputDecoration(
                              labelText: 'Bank Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bankDetails['branch'],
                            decoration: const InputDecoration(
                              labelText: 'Branch',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bankDetails['accountNumber'],
                            decoration: const InputDecoration(
                              labelText: 'Account Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bankDetails['loanCategory'],
                            decoration: const InputDecoration(
                              labelText: 'Loan Category',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bankDetails['loanAmount'],
                            decoration: const InputDecoration(
                              labelText: 'Loan Amount',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bankDetails['loanOutstanding'],
                            decoration: const InputDecoration(
                              labelText: 'Loan Outstanding',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add Button
            Center(
              child: ElevatedButton(
                onPressed: _addNewBankDetail,
                child: const Text('Add Another Bank'),
              ),
            ),

            // Next Button to navigate to the next page
            Center(
              child: ElevatedButton(
                onPressed: _navigateToNextPage, // Navigate to next page
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
