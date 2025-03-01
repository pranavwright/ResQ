
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'screens/otp_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/camp_status.dart';
import 'screens/collection_point.dart';
import 'screens/create_notice.dart';
import 'screens/families.dart';
import 'screens/role_creation.dart';
import 'screens/home.dart';

void main() {
  // Configure the URL strategy for web
  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // Use routes instead of onGenerateRoute for better web support
        '/': (context) => LoginScreen(),
        '/otp': (context) => OtpScreen(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/families': (context) => FamiliesScreen(),
        '/camp-status': (context) => CampStatusScreen(),
        '/notice-board': (context) => RoleNoticeBoard(),
        '/collection-point': (context) => CollectionPointScreen(),
        '/create-notice': (context) => CreateNoticeScreen(),
        '/home': (context) => HomeScreen(),
      },
      onUnknownRoute:
          (settings) => MaterialPageRoute(
            builder:
                (context) =>
                    Scaffold(body: Center(child: Text('Page Not Found'))),
          ),
    );
  }
}
