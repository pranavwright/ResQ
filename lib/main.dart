import 'package:flutter/material.dart';
import 'package:resq/screens/a_section_screen.dart';
import 'package:resq/screens/b_section_screen.dart';
import 'package:resq/screens/c_section_screen.dart';
import 'package:resq/screens/d_section_screen.dart';
import 'package:resq/screens/downloading.dart';
import 'package:resq/screens/add_members.dart';
import 'package:resq/screens/agriculture.dart';
import 'package:resq/screens/assistance_support.dart';
import 'package:resq/screens/connectivity_wrapper.dart';
import 'package:resq/screens/e_section_screen.dart';
import 'package:resq/screens/education_livielhoood.dart';
import 'package:resq/screens/emp_status.dart';
import 'package:resq/screens/f_section_screen.dart';
import 'package:resq/screens/familysurvay_home.dart';
import 'package:resq/screens/foodand_health.dart';
import 'package:resq/screens/g_section_screen.dart';
import 'package:resq/screens/h_section_screen.dart';
import 'package:resq/screens/helthnew.dart';
import 'package:resq/screens/i_section_screen.dart';
import 'package:resq/screens/incom_andlose.dart';
import 'package:resq/screens/items_list.dart';
import 'package:resq/screens/j_section_screen.dart';
import 'package:resq/screens/k_section_screen.dart';
import 'package:resq/screens/kudumbasree.dart';
import 'package:resq/screens/mian_home.dart';
import 'package:resq/screens/no_network_screen.dart';
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
import 'package:resq/screens/notice_display_screen.dart';

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

class RedirectWidget extends StatelessWidget {
  final String route;

  const RedirectWidget({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirect after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(route);
    });

    // Return an empty container while redirecting
    return Container();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget getDashboardForRole(List<String> roles) {
    final authService = AuthService();
    final userRoles = authService.getCurrentUserRoles();
    if (userRoles.contains('superAdmin')) return SuperAdminDashboard();
    if (userRoles.contains('admin')) return AdminDashboard();
    if (userRoles.contains('stat')) return DashboardScreen();
    if (userRoles.contains('kas')) return KasDashboard();
    if (userRoles.contains('collectionpointadmin'))
      return CollectionPointDashboard();
    if (userRoles.contains('campadmin')) return CampAdminRequestScreen();
    if (userRoles.contains('collectionpointvolunteer'))
      return VolunteerDashboard();
    return RedirectWidget(route: '/otp');
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAuthenticated = authService.isAuthenticated;
    List<String> roles = authService.getCurrentUserRoles() ?? [];

    // String initialRoute =
    //     isAuthenticated
    //         ? '/profile-setup'
    //         : kIsWeb
    //         ? '/'
    //         : '/otp';
    // String initialRoute = '/notices';  // Set notices as initial route for testing
  String initialRoute =  '/test-family';

    return ConnectivityWrapper(
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: _getPrimaryColor(),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: {
          '/no-network':
              (context) => NoNetworkScreen(
                onRetry:
                    () => Navigator.of(
                      context,
                    ).pushReplacementNamed(initialRoute),
              ),

          // '/':
          //     (context) =>
          //         AuthRoute(requiresAuth: false, child: Familysurveyhome()),
          '/':
              (context) =>
                 AuthRoute(requiresAuth: false, child: FamilyDataDownloadScreen()),

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
          '/add-fam-home':
              (context) => AuthRoute(
                requiredRoles: ["familiySurvey"],
                child: Familysurveyhome(),
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

          '/add-famili': (context) => AddFamilies(),
          '/notices': (context) => const NoticeScreen(userId: '',),

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
          '/test-family': (context) => FamilyDataDownloadScreen(),
          '/test-collectionpoint': (context) => CollectionPointDashboard(),
          '/test-statistics': (context) => DashboardScreen(),
          '/test-profile': (context) => ProfileUpdateScreen(),
          '/donations': (context) => const DonationsScreen(),
          '/verification-volunteer':
              (context) => const VerificationVolunteerDashboard(),
          '/sectionA': (context) {
            // Create a fresh data object to pass around for sections A–K
            final data = NeedAssessmentData();
            return AuthRoute(
              requiresAuth: false, // or true, if you want to force login
              child: ASectionScreen(data: data),
            );
          },

          '/sectionB': (context) {
            // Grab the same data from arguments
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: BSectionScreen(data: data),
            );
          },

          '/sectionC': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: CSectionScreen(data: data),
            );
          },

          '/sectionD': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: DSectionScreen(data: data),
            );
          },

          '/sectionE': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: ESectionScreen(data: data),
            );
          },

          '/sectionF': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: FSectionScreen(data: data),
            );
          },

          '/sectionG': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: GSectionScreen(data: data),
            );
          },

          '/sectionH': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: HSectionScreen(data: data),
            );
          },

          '/sectionI': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: ISectionScreen(data: data),
            );
          },

          '/sectionJ': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: JSectionScreen(data: data),
            );
          },

          '/sectionK': (context) {
            final data =
                ModalRoute.of(context)!.settings.arguments
                    as NeedAssessmentData;
            return AuthRoute(
              requiresAuth: false,
              child: KSectionScreen(data: data),
            );
          },
        },
          

        onUnknownRoute:
            (settings) => MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(child: Text('404 - Page Not Found')),
                  ),
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
