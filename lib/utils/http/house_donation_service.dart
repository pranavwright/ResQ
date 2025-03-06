import 'dart:convert';
import 'package:http/http.dart' as http;

class HouseDonationService {
  static const String apiUrl = 'https://example.com/api/house-donations'; // Replace with actual API URL

  static Future<void> submitHouseDonation(Map<String, dynamic> houseDetails) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(houseDetails),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('House donation submitted successfully: ${response.body}');
      } else {
        print('Failed to submit house donation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting house donation: $e');
      throw e;
    }
  }
}
