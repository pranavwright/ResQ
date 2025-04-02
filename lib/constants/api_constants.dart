import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // static const String baseUrl = "https://api.realsq.tech"; 
  static const String baseUrl = "http://192.168.224.208:2900"; 
  
  // Get API key from .env file
  // Get Maps API key with fallback
  static String get GOOGLE_MAPS_API_KEY {
    try {
      return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY_HERE';
    } catch (e) {
      print("Error accessing env variables: $e");
      return 'YOUR_DEFAULT_API_KEY_HERE';
    }
  }
}