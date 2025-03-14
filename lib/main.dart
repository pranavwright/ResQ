import 'package:flutter/material.dart';
import 'package:resq/downloading.dart';
import 'package:resq/home.dart';
import 'package:resq/screens/add_members.dart';
import 'package:resq/screens/agriculture.dart';
import 'package:resq/screens/assistance_support.dart';
import 'package:resq/screens/education_livielhoood.dart';
import 'package:resq/screens/emp_status.dart';
import 'package:resq/screens/foodand_health.dart';
import 'package:resq/screens/helthnew.dart';
import 'package:resq/screens/incom_andlose.dart';
import 'package:resq/screens/items_list.dart';
import 'package:resq/screens/kudumbasree.dart';
import 'package:resq/screens/mian_home.dart';
import 'package:resq/screens/otp_screen.dart';
import 'package:resq/screens/personal_loan.dart';
import 'package:resq/screens/shelter.dart';
import 'package:resq/screens/skill.dart';
import 'package:resq/screens/social.dart';
import 'package:resq/screens/special_category.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/camp_status.dart';
import 'screens/create_notice.dart';
import 'screens/families.dart';
import 'screens/role_creation.dart';
import 'utils/auth/auth_route.dart';
import 'utils/auth/auth_service.dart';
import 'screens/stat_dashboard.dart';
import 'screens/campadmin_dashboard.dart';
import 'screens/kas_dashboard.dart';
import 'screens/superAdmin_dashboard.dart';
import 'screens/collectionpoint_dashboard.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/donation_request_form.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/profile_setup.dart';
import 'screens/add_famili.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:resq/screens/family_data_download.dart';
import 'package:resq/screens/loan_relief_upload.dart' as loan_relief;
import 'package:resq/screens/profile_updation.dart';
import 'package:resq/screens/donations_screen.dart';
import 'package:resq/screens/verification_volunteer_dashboard.dart';

void main() async {
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  final authService = AuthService();
  try {
    await authService.loadAuthState();
    print("Auth state loaded: ${authService.isAuthenticated}");
  } catch (e) {
    print("Error loading auth state: $e");
  }

  print("App initialized with auth state: ${authService.isAuthenticated}");
  print("User roles: ${authService.userRoles}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget getDashboardForRole(List<String> roles) {
    if (roles.contains('superAdmin')) return SuperAdminDashboard();
    if (roles.contains('admin')) return AdminDashboard();
    if (roles.contains('stat')) return DashboardScreen();
    if (roles.contains('kas')) return KasDashboard();
    if (roles.contains('collectionpointadmin')) return CollectionPointDashboard();
    if (roles.contains('campadmin')) return CampAdminRequestScreen();
    if (roles.contains('collectionpointvolunteer')) return VolunteerDashboard();
    return Home();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAuthenticated = authService.isAuthenticated;
    List<String> roles = authService.getCurrentUserRoles() ?? [];

    String initialRoute =
        isAuthenticated
            ? '/profile-setup'
            : kIsWeb
            ? '/'
            : '/otp';

    print(initialRoute);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,

        primaryColor: _getPrimaryColor(),
      ),

      initialRoute: initialRoute,

      routes: {
        '/': (context) => AuthRoute(requiresAuth: false, child: SuperAdminDashboard()),

        '/otp':
            (context) =>
                const AuthRoute(requiresAuth: false, child: OtpScreen()),
        '/app':
            (context) => AuthRoute(
              requiredRoles: [
                'stat',

                'admin',

                'kas',

                'superAdmin',

                'collectionpointadmin',

                'campadmin',

                'collectionpointvolunteer',
              ],

              child: getDashboardForRole(roles),
            ),
        '/disaster':
            (context) =>
                const AuthRoute(requiresAuth: false, child: ItemsList()),
        '/download':
            (context) =>
                const AuthRoute(requiresAuth: false, child: Downloading()),

        '/families':
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'familySurvey'],

              child: FamiliesScreen(),
            ),

        '/camp-status':
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'campadmin'],

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

        '/home':
            (context) => const AuthRoute(requiresAuth: false, child: Home()),

        '/public-donation': (context) => DonationRequestPage(),

        '/foodand-health': (context) => FoodandHealth(),

        '/shelter': (context) => Shelter(),

        '/education-livilehood': (context) => EducationLivielhoood(),

        '/agriculture': (context) => Agriculture(),

        '/social': (context) => Social(),

        '/personal-loan': (context) => PersonalLoan(),

        '/special': (context) => SpecialCategory(),

        '/kudumbasree': (context) => Kudumbasree(),

        '/assistance': (context) => AssistanceSupport(),

        '/incomandlose': (context) => IncomAndlose(),

        '/emp-status': (context) => EmpStatus(),

        '/add-members': (context) => AddMembers(),

        '/helthnew': (context) => HealthNew(),

        '/skill': (context) => Skill(),

        '/root': (context) => Home(),

        '/add-famili': (context) => AddFamilies(),

        '/profile-setup':
            (context) => AuthRoute(
              requiresAuth: true,
              // redirect: isProfileCompleted ? '/app' : null,
              child: ProfileSetupScreen(),
            ),
        '/loan-relief':
            (context) => AuthRoute(
              requiredRoles: ['admin', 'kas', 'superadmin', 'campadmin'],
              child:
                  loan_relief.LoanReliefUploadScreen(), // Add the prefix here
            ),
        '/test-family': (context) => FamilyDataScreen(),
        '/test-collectionpoint': (context) => CollectionPointDashboard(),
        '/test-statistics': (context) => DashboardScreen(),
        '/test-profile': (context) => ProfileUpdateScreen(),
        '/donations': (context) => const DonationsScreen(),
        '/verification-volunteer':
            (context) => const VerificationVolunteerDashboard(),
      },

      onUnknownRoute:
          (settings) => MaterialPageRoute(
            builder:
                (context) => const Scaffold(
                  body: Center(child: Text('404 - Page Not Found')),
                ),
          ),
    );
  }

  Color _getPrimaryColor() {
    try {
      return kIsWeb ? Colors.green : Colors.blue;
    } catch (e) {
      debugPrint('Error getting platform color: $e');

      return Colors.blue;
    }
  }
}
