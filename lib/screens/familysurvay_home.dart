import 'package:flutter/material.dart';
import 'package:resq/screens/add_famili.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FamilysurvayHome(),
    );
  }
}

class FamilysurvayHome extends StatefulWidget {
  const FamilysurvayHome({super.key});

  @override
  _FamilysurvayHomeState createState() => _FamilysurvayHomeState();
}

class _FamilysurvayHomeState extends State<FamilysurvayHome> {
  // Dummy family member data
  List<Map<String, String>> add_famili= [
    {"name": "John Doe", "relation": "Father", "age": "40"},
    {"name": "Jane Doe", "relation": "Mother", "age": "38"},
    {"name": "Alice Doe", "relation": "Daughter", "age": "10"},
    {"name": "Bob Doe", "relation": "Son", "age": "8"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Survey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddFamilyMemberPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFamilies()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: add_famili.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(add_famili[index]['name']!),
              subtitle: Text(
                  '${add_famili[index]['relation']} - Age: ${add_famili[index]['age']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to EditFamilyMemberPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFamilies(
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  _AddFamilyMemberPageState createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  final nameController = TextEditingController();
  final relationController = TextEditingController();
  final ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Family Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: relationController,
              decoration: const InputDecoration(labelText: 'Relation'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Get the family member details from the input fields
                String name = nameController.text;
                String relation = relationController.text;
                String age = ageController.text;

                // Handle adding the new family member (you can modify the family list here)
                print('Added Name: $name');
                print('Added Relation: $relation');
                print('Added Age: $age');

                // Navigate back to the home page after adding
                Navigator.pop(context);
              },
              child: const Text('Add Family Member'),
            ),
          ],
        ),
      ),
    );
  }
}
