import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'screens/otp_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/camp_status.dart';

import 'screens/create_notice.dart';
import 'screens/families.dart';
import 'screens/role_creation.dart';
import 'screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add platform-specific theme settings if needed
        primaryColor: Platform.isAndroid ? Colors.green : Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/otp': (context) => OtpScreen(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/families': (context) => FamiliesScreen(),
        '/camp-status': (context) => CampStatusScreen(),
        '/notice-board': (context) => RoleNoticeBoard(),
       
        '/create-notice': (context) => CreateNoticeScreen(),
        '/home': (context) => HomeScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(body: Center(child: Text('Page Not Found'))),
      ),
    );
  }
}