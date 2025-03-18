import 'package:flutter/material.dart';
import 'package:resq/screens/familysurvay_home.dart';

class HSectionScreen extends StatefulWidget {
  final NeedAssessmentData data;

  const HSectionScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<HSectionScreen> createState() => _HSectionScreenState();
}

class _HSectionScreenState extends State<HSectionScreen> {
  // Controllers for each field in Section H
  late TextEditingController pensionStatusController;
  late TextEditingController loanRepaymentStatusController;
  late TextEditingController outstandingLoansController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data for Section H
    pensionStatusController = TextEditingController(text: widget.data.pensionStatus);
    loanRepaymentStatusController = TextEditingController(text: widget.data.loanRepaymentStatus);
    outstandingLoansController = TextEditingController(text: widget.data.outstandingLoans);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    pensionStatusController.dispose();
    loanRepaymentStatusController.dispose();
    outstandingLoansController.dispose();
    super.dispose();
  }

  void saveData() {
    // Save the changes back into the NeedAssessmentData object
    widget.data.pensionStatus = pensionStatusController.text;
    widget.data.loanRepaymentStatus = loanRepaymentStatusController.text;
    widget.data.outstandingLoans = outstandingLoansController.text;

    // For demonstration, you can handle saving by sending the data to a backend, local storage, etc.
    print("Section H Updated: Pension Status: ${widget.data.pensionStatus}, Loan Repayment Status: ${widget.data.loanRepaymentStatus}, Outstanding Loans: ${widget.data.outstandingLoans}");

    // Optionally, navigate back to the previous screen or the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section H - Social Security and Loan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social Security and Loan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: pensionStatusController,
              decoration: const InputDecoration(
                labelText: '1. Does the household have a pension?',
                hintText: 'Yes/No',
              ),
            ),
            TextField(
              controller: loanRepaymentStatusController,
              decoration: const InputDecoration(
                labelText: '2. Loan repayment status',
                hintText: 'Pending/Completed',
              ),
            ),
            TextField(
              controller: outstandingLoansController,
              decoration: const InputDecoration(
                labelText: '3. Any outstanding loans?',
                hintText: 'Yes/No',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
