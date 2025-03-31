import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resq/firebase_options.dart';
import 'package:resq/screens/collectionpoint_volunteer.dart';
import 'package:resq/screens/identity.dart';
import 'package:resq/screens/login_screen.dart';
import 'package:resq/screens/splash_screen.dart';
import 'dart:io';

import 'utils/auth/auth_service.dart';
import 'utils/auth/auth_route.dart';

// Screens
import 'package:resq/screens/otp_screen.dart';
import 'package:resq/screens/profile_setup.dart';
import 'package:resq/screens/superAdmin_dashboard.dart';
import 'package:resq/screens/admin_dashboard.dart';
import 'package:resq/screens/stat_dashboard.dart';
import 'package:resq/screens/collectionpoint_dashboard.dart';
import 'package:resq/screens/campadmin_dashboard.dart';
import 'package:resq/screens/volunteer_dashboard.dart';
import 'package:resq/screens/no_network_screen.dart';
import 'package:resq/screens/items_list.dart';
import 'package:resq/screens/downloading.dart';
import 'package:resq/screens/families.dart';
import 'package:resq/screens/camp_status.dart' as camp_status;
import 'package:resq/screens/create_notice.dart';
import 'package:resq/screens/camprole_creation.dart';
import 'package:resq/screens/donation_request_form.dart';
import 'package:resq/screens/loan_relief_upload.dart' as loan_relief;
import 'package:resq/screens/family_data_download.dart';
import 'package:resq/screens/collection_point.dart';
import 'package:resq/screens/profile_updation.dart';
import 'package:resq/screens/donations_screen.dart';
import 'package:resq/screens/verification_volunteer_dashboard.dart';
import 'package:resq/screens/familysurvey_home.dart';
import 'package:resq/screens/section_a_screen.dart';
import 'package:resq/models/NeedAssessmentData.dart';
import 'package:resq/screens/change_disaster.dart';
import 'package:resq/screens/notice_display_screen.dart';
import 'package:resq/screens/collectionpoint_volunteer_management.dart';
import 'package:resq/screens/view_notice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
  await _requestNotificationPermissions(); // Request early
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const MyApp());
}

Future<void> _requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('Authorization status: ${settings.authorizationStatus}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String initialRoute = '/';
    if (kIsWeb) {
      final uri = Uri.parse(Uri.base.toString());
      final path = uri.path;

      if (path.isNotEmpty && path != '/') {
        initialRoute = path;
        print('Initial route from URL: $initialRoute');
      }
    }

    return MaterialApp(
      title: 'RESQ App',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: _getPrimaryColor(),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(initialRoute: initialRoute),
      routes: {
        '/no-network':
            (context) => NoNetworkScreen(
              onRetry: () async {
                final connectivityResult =
                    await Connectivity().checkConnectivity();
                if (connectivityResult != ConnectivityResult.none) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (context) => SplashScreen(initialRoute: initialRoute),
                    ),
                  );
                }
              },
            ),
      },
      onGenerateRoute: _generateRoute,
    );
  }

  Color _getPrimaryColor() => kIsWeb ? Colors.green : Colors.blue;

  Route<dynamic> _generateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    final authService = AuthService();
    final roles = authService.getCurrentUserRoles() ?? [];
    // or '/public-donation'

    switch (settings.name) {
      case '/':
        builder = (context) => SplashScreen(initialRoute: '/');
        break;

      case '/otp':
        builder =
            (context) => AuthRoute(requiresAuth: false, child: OtpScreen());
        break;
      case '/app':
        builder =
            (context) => AuthRoute(
              requiresAuth: true,
              child: getDashboardForRole(roles),
            );
        break;
      case '/profile-setup':
        builder =
            (context) =>
                AuthRoute(requiresAuth: true, child: ProfileSetupScreen());
        break;
      case '/debug-camp':
        builder = (context) => CampAdminDashboard();
        break;
      case '/disaster':
        final args = settings.arguments as dynamic?;
        String disasterId = '';
        if (args != null) {
          disasterId = args['disasterId'];
        }
        builder =
            (context) => AuthRoute(
              requiresAuth: false,
              child: ItemsList(disasterId: disasterId),
            );
        break;
      case '/download':
        builder =
            (context) =>
                const AuthRoute(requiresAuth: false, child: Downloading());
        break;
      case '/families':
        builder =
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'surveyOfficial'],
              child: FamiliesScreen(),
            );
        break;
      case '/camp-status':
        builder =
            (context) => AuthRoute(
              requiredRoles: const ['admin', 'campadmin'],
              child: camp_status.CampStatusScreen(),
            );
        break;
      case '/notice-board':
        builder = (context) => const AuthRoute(child: NoticeScreen());
        break;
      case '/create-notice':
        builder =
            (context) => const AuthRoute(
              requiredRoles: ['admin', "stat"],
              child: CreateNoticeScreen(),
            );
        break;
      case '/role-creation':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['admin', 'stat'],
              child: CamproleCreation(),
            );

        break;
      case '/public-donation':
        final args = settings.arguments as dynamic?;
        String disasterId = args['disasterId'] ?? '';
        builder =
            (context) => AuthRoute(
              requiresAuth: false,
              child: DonationRequestPage(disasterId: disasterId),
            );
        break;
      case '/loan-relief':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['admin', 'stat', 'superadmin', 'campadmin'],
              child: loan_relief.LoanReliefUploadScreen(),
            );
        break;
      case '/family-data-download':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['admin', 'stat'],
              child: FamilyDataDownloadScreen(families: []),
            );
      case '/identity':
        builder = (context) => AuthRoute(requiresAuth: true, child: Identity());
        break;
      case '/admin-collectionpoint':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['admin', 'stat'],
              child: CollectionPointScreen(),
            );
        break;
      case '/stat-dashboard':
        builder =
            (context) =>
                AuthRoute(requiredRoles: ['stat'], child: DashboardScreen());
        break;
      case '/manage-camp':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['campAdmin'],
              child: CampAdminDashboard(),
            );
        break;
      case '/manage-collectionpoint':
        builder =
            (context) =>
                AuthRoute(requiredRoles: ['collectionPointAdmin'], child: CollectionPointDashboard());
        break;
      case '/profile-update':
        builder =
            (context) =>
                AuthRoute(requiresAuth: true, child: ProfileUpdateScreen());
        break;
      case '/donations':
        builder =
            (context) =>
                AuthRoute(requiresAuth: false, child: const DonationsScreen());
        break;
      case '/verification-volunteer':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['verifyOfficial'],
              child: const VerificationVolunteerDashboard(),
            );
        break;
      case '/family-survey':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['surveyOfficial'],
              child: FamilySurveyHomeScreen(),
            );
        break;
      case '/sectionA':
        final data = NeedAssessmentData();
        builder =
            (context) =>
                AuthRoute(requiresAuth: false, child: ScreenA(data: data));
        break;
      case '/collectionpoint-volunteer':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['collectionpointvolunteer'],
              child: VolunteerDashboard(),
            );
        break;
      case '/change-disaster':
        builder =
            (context) =>
                AuthRoute(requiresAuth: true, child: ChangeDisasterScreen());
        break;
      case '/manage-collectionpoint':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['collectionPointAdmin'],
              child: CollectionPointDashboard(),
            );
        break;
      case '/view-notice':
        final args = settings.arguments as Map<String, dynamic>?;
        final noticeId = args?['noticeId'] as String? ?? '';
        builder =
            (context) => AuthRoute(
              requiresAuth: true,
              child: ViewNotice(noticeId: noticeId),
            );
        break;
      case '/collectionpoint-volunteer-management':
        final args = settings.arguments as Map<String, dynamic>?;
        final collectionPointId = args?['collectionPointId'] as String? ?? '';
        builder =
            (context) => AuthRoute(
              requiredRoles: ['collectionPointAdmin'],
              child: CollectionPointManagementScreen(
                collectionPointId: collectionPointId,
              ),
            );
        break;
    
        
      case '/logout':
        builder = (BuildContext context) {
          // Execute logout in the next frame after the route is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AuthService().logout().then((_) {
              Navigator.of(context).pushReplacementNamed('/otp');
            });
          });
          // Return a loading screen while logout is processing
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        };
        break;
      default:
        builder =
            (context) => const Scaffold(
              body: Center(child: Text('404 - Page Not Found')),
            );
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }

  Widget getDashboardForRole(List<String> roles) {
    if (roles.contains('superAdmin')) return SuperAdminDashboard();
    if (roles.contains('admin')) return AdminDashboard();
    if (roles.contains('stat')) return DashboardScreen();
    if (roles.contains('collectionPointAdmin'))
      return CollectionPointDashboard();
    if (roles.contains('campAdmin')) return CampAdminDashboard();
    if (roles.contains('collectionpointvolunteer')) return VolunteerScreen();
    if (roles.contains('surveyOfficial')) return FamilySurveyHomeScreen();
    if (roles.contains('verifyOfficial'))
      return VerificationVolunteerDashboard();
    return const Scaffold(body: Center(child: Text("No valid role assigned")));
  }
}
