import 'package:flutter/material.dart';

class SpecialCategory extends StatefulWidget {
  const SpecialCategory({super.key});

  @override
  _SpecialCategoryState createState() => _SpecialCategoryState();
}

class _SpecialCategoryState extends State<SpecialCategory> {
  // Variable to hold the selected value of the radio button
  String? _selectedCategory;
  // Controller for the 'Others' text field
  TextEditingController _otherCategoryController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the text controller to avoid memory leaks
    _otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Category Selection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/personal-loan',
                  (route) => false,
                );
                // Implement // This pops the current screen from the navigation stack
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            const Text(
              'Are you part of any special category?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Space between question and radio buttons

            // Radio button options
            Row(
              children: [
                Radio<String>(
                  value: 'Elderly only Family (Including Children)',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Elderly only Family (Including Children)'),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Women only Family (Including Children)',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Women only Family (Including Children)'),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Lone survivor',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Lone survivor'),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Children only',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Children only'),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Tribals',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Tribals'),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Transgenders',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Transgenders'),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'others',
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const Text('Others'),
              ],
            ),

            // Show TextField when "others" is selected
            if (_selectedCategory == 'others') 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Please specify:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otherCategoryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Specify your category',
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/kudumbasree',
                  (route) => false,
                );
                // Implement your action here (e.g., submit the data)
              },
              child: const Text("Next"),
            ), // Space after radio buttons
          ],
        ),
      ),
    );
  }
}
