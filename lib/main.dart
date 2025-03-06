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
import 'utlis/auth/auth_route.dart';
import 'utlis/auth/auth_service.dart';
import 'screens/stat_dashboard.dart';
import 'screens/campadmin_dashboard.dart';
import 'screens/kas_dashboard.dart';
import 'screens/superadmin_dashboard.dart';
import 'screens/collectionpoint_dashboard.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/donation_request_form.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // setUrlStrategy(PathUrlStrategy());
  await AuthService()
      .loadAuthState(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Widget getDashboardForRole(List<String> roles) {
    if (roles.contains('superadmin')) return SuperAdminDashboard();
    if (roles.contains('admin')) return AdminDashboard();
    if (roles.contains('stat')) return StatDashboard();
    if (roles.contains('kas')) return KasDashboard();
    if (roles.contains('collectionpointadmin'))
      return CollectionPointDashboard();
    if (roles.contains('campadmin')) return CampAdminDashboard();
    if (roles.contains('collectionpointvolunteer')) return VolunteerDashboard();
    return HomeScreen(); // Provide a fallback
  }

  @override
  Widget build(BuildContext context) {
    List<String> roles = AuthService().getCurrentUserRoles();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: _getPrimaryColor(),
      ),
      initialRoute: '/',
      routes: {
        '/':
            (context) =>
                const AuthRoute(requiresAuth: false, child: LoginScreen()),
        '/otp':
            (context) =>
                const AuthRoute(requiresAuth: false, child: OtpScreen()),

        '/app':
            (context) => AuthRoute(
              requiredRoles: [
                'stat',
                'admin',
                'kas',
                'superadmin',
                'collectionpointadmin',
                'campadmin',
                'collectionpointvolunteer',
              ],
              child: getDashboardForRole(roles),
            ),

        '/families':
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'familySurvey'],
              child: FamiliesScreen(),
            ),

        '/camp-status':
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'campAdmin'],
              child: CampStatusScreen(),
            ),

        '/notice-board':
            (context) => const AuthRoute(
              requiredRoles: ['admin'],
              child: RoleCreationScreen(),
            ),

        '/create-notice':
            (context) => const AuthRoute(
              requiredRoles: ['admin'],
              child: CreateNoticeScreen(),
            ),

        '/public-donation': (context) => DonationRequestPage(),

        // accessible to all authenticated users
        '/home': (context) => const AuthRoute(child: HomeScreen()),
      },
      onUnknownRoute:
          (settings) => MaterialPageRoute(
            builder:
                (context) =>
                    const Scaffold(body: Center(child: Text('Page Not Found'))),
          ),
    );
  }

  Color _getPrimaryColor() {
    try {
      return Platform.isAndroid ? Colors.green : Colors.blue;
    } catch (e) {
      return Colors.blue; // Default color for web and other platforms
    }
  }
}
