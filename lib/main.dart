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
import 'screens/profile_setup.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable Impeller by setting this environment variable
  // This approach works across different Flutter versions
  if (Platform.isAndroid) {
    debugPrint("Attempting to disable Impeller for Android");
    bool? enableImpeller = false;
  }
  
  await AuthService().loadAuthState(); // Load auth state only once
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<List<String>> _fetchRoles() async {
    return AuthService().getCurrentUserRoles();
  }

  Widget getDashboardForRole(List<String> roles) {
    if (roles.contains('superadmin')) return SuperAdminDashboard();
    if (roles.contains('admin')) return AdminDashboard();
    if (roles.contains('stat')) return StatDashboard();
    if (roles.contains('kas')) return KasDashboard();
    if (roles.contains('collectionpointadmin')) return CollectionPointDashboard();
    if (roles.contains('campadmin')) return CampAdminRequestScreen();
    if (roles.contains('collectionpointvolunteer')) return VolunteerDashboard();
    return HomeScreen(); // Default screen if no specific role is found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchRoles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final authService = AuthService();
        final isAuthenticated = authService.isAuthenticated;
        final isProfileCompleted = authService.isProfileCompleted;
      List<String> roles = snapshot.data ?? [];
// Provide an empty list as the default value// Fixed null-aware operator

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: _getPrimaryColor(),
          ),
          initialRoute: '/', // Set the initial route to '/'
          routes: {
            // Public Routes
            '/': (context) => const AuthRoute(requiresAuth: false, child: LoginScreen()), // Login route
            '/otp': (context) => const AuthRoute(requiresAuth: false, child: OtpScreen()),

            // Protected Routes
            '/app': (context) => AuthRoute(
                  requiredRoles: [
                    'stat', 'admin', 'kas', 'superadmin',
                    'collectionpointadmin', 'campadmin', 'collectionpointvolunteer',
                  ],
                  child: getDashboardForRole(roles),
                ),
            '/families': (context) => const AuthRoute(
                  requiredRoles: ['admin', 'familySurvey'],
                  child: FamiliesScreen(),
                ),
            '/camp-status': (context) => const AuthRoute(
                  requiredRoles: ['admin', 'campadmin'],
                  child: CampStatusScreen(),
                ),
            '/notice-board': (context) => const AuthRoute(
                  requiredRoles: ['admin'],
                  child: RoleCreationScreen(),
                ),
            '/create-notice': (context) => const AuthRoute(
                  requiredRoles: ['admin'],
                  child: CreateNoticeScreen(),
                ),
            '/home': (context) => const AuthRoute(requiresAuth: false, child: HomeScreen()),
            '/public-donation': (context) => DonationRequestPage(),
           '/profile-setup': (context) => FutureBuilder<String?>(
      future: AuthService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } 
        if (!snapshot.hasData || snapshot.data == null) {
          // Handle the case where the token is not available
          return const Scaffold(body: Center(child: Text('Token not found')));
        }
        return AuthRoute(
          requiresAuth: true,
          child: ProfileSetupScreen(
            token: snapshot.data!, // Pass the token here
            roles: roles, 
          ),
        );
      },
    ),
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('404 - Page Not Found')),
            ),
          ),
        );
      },
    );
  }

  Color _getPrimaryColor() {
    try {
      return Platform.isAndroid ? Colors.green : Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }
}