import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FamilyTableScreen extends StatefulWidget {
  @override
  _FamilyTableScreenState createState() => _FamilyTableScreenState();
}

class _FamilyTableScreenState extends State<FamilyTableScreen> {
  List<Map<String, dynamic>> families = [
    {"Name": "John Doe", "Size": 5, "Income": 20000, "Damage": "Partial"},
    {"Name": "Jane Smith", "Size": 3, "Income": 15000, "Damage": "Severe"},
    {"Name": "Sam Wilson", "Size": 4, "Income": 25000, "Damage": "Minor"},
  ];

  List<String> columns = ["Name", "Size", "Income", "Damage"];
  List<String> selectedFilters = [];

  void _exportToExcel() async {
    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];

    // Add headers
    for (int i = 0; i < selectedFilters.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(selectedFilters[i]);
    }

    // Add data
    for (int row = 0; row < families.length; row++) {
      for (int col = 0; col < selectedFilters.length; col++) {
        sheet.getRangeByIndex(row + 2, col + 1).setText(
            families[row][selectedFilters[col]].toString());
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/Filtered_Family_Data.xlsx";
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel file saved at: $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Family Details")),
      body: Column(
        children: [
          // Filter Selection
          Wrap(
            children: columns.map((filter) {
              return CheckboxListTile(
                title: Text(filter),
                value: selectedFilters.contains(filter),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedFilters.add(filter);
                    } else {
                      selectedFilters.remove(filter);
                    }
                  });
                },
              );
            }).toList(),
          ),

          // Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
                rows: families.map((family) {
                  return DataRow(
                    cells: columns.map((col) => DataCell(Text(family[col].toString()))).toList(),
                  );
                }).toList(),
              ),
            ),
          ),

          // Export Button
          ElevatedButton(
            onPressed: selectedFilters.isNotEmpty ? _exportToExcel : null,
            child: Text("Download Selected Columns"),
          ),
        ],
      ),
    );
  }
}
