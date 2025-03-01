import 'package:flutter/material.dart';
import 'screens/otp_screen.dart';  // Ensure underscores (_) not hyphens (-)
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/camp_status.dart';
import 'screens/collection_point.dart';
import 'screens/create_notice.dart';
import 'screens/families.dart';
import 'screens/role_creation.dart';  // Check if this is the correct file
import 'screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',  
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/otp':
            return MaterialPageRoute(builder: (context) => OtpScreen());
          case '/admin-dashboard':
            return MaterialPageRoute(builder: (context) => AdminDashboard());
          case '/families':
            return MaterialPageRoute(builder: (context) => FamiliesScreen());
          case '/camp-status':
            return MaterialPageRoute(builder: (context) => CampStatusScreen());
          case '/notice-board':
            return MaterialPageRoute(builder: (context) => RoleNoticeBoard());
          case '/collection-point':
            return MaterialPageRoute(builder: (context) => CollectionPointScreen());
          case '/create-notice':
            return MaterialPageRoute(builder: (context) => CreateNoticeScreen());
          case '/home':  // Add this if you need home.dart
            return MaterialPageRoute(builder: (context) => HomeScreen());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Page Not Found')),
              ),
            );
        }
      },
    );
  }
}
