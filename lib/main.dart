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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService()
      .loadAuthState(); // Ensuring auth state is loaded before app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget getDashboardForRole(List<String> roles) {
    
    if (roles.contains('superadmin')) return SuperAdminDashboard();
    if (roles.contains('admin')) return AdminDashboard();
    if (roles.contains('stat')) return StatDashboard();
    if (roles.contains('kas')) return KasDashboard();
    if (roles.contains('collectionpointadmin'))return CollectionPointDashboard();
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
        // Auth not required for these routes
        '/':
            (context) =>
                const AuthRoute(requiresAuth: false, child: LoginScreen()),
        '/otp':
            (context) =>
                const AuthRoute(requiresAuth: false, child: OtpScreen()),

        // Admin dashboard - requires admin role
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

        // Family survey - requires admin or familySurvey role
        '/families':
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'familySurvey'],
              child: FamiliesScreen(),
            ),

        // Camp status - requires admin or camp admin role
        '/camp-status':
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'campAdmin'],
              child: CampStatusScreen(),
            ),

        // Role creation - requires admin role only
        '/notice-board':
            (context) => const AuthRoute(
              requiredRoles: ['admin'],
              child: RoleCreationScreen(),
            ),

        // Create notice - requires admin role
        '/create-notice':
            (context) => const AuthRoute(
              requiredRoles: ['admin'],
              child: CreateNoticeScreen(),
            ),

        // Home - accessible to all authenticated users
        '/home': (context) => const AuthRoute(child: HomeScreen()),
     
      '/public-donation': (context) => DonationRequestPage(),
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
