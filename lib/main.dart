import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:resq/screens/kas_dashboard.dart';
import 'package:resq/screens/collectionpoint_dashboard.dart';
import 'package:resq/screens/campadmin_dashboard.dart';
import 'package:resq/screens/volunteer_dashboard.dart';
import 'package:resq/screens/no_network_screen.dart';
import 'package:resq/screens/items_list.dart';
import 'package:resq/screens/downloading.dart';
import 'package:resq/screens/families.dart';
import 'package:resq/screens/camp_status.dart' as camp_status;
import 'package:resq/screens/role_creation.dart';
import 'package:resq/screens/create_notice.dart';
import 'package:resq/screens/camprole_creation.dart';
import 'package:resq/screens/donation_request_form.dart';
import 'package:resq/screens/loan_relief_upload.dart' as loan_relief;
import 'package:resq/screens/family_data_download.dart';
import 'package:resq/screens/collection_point.dart';
import 'package:resq/screens/profile_updation.dart';
import 'package:resq/screens/donations_screen.dart';
import 'package:resq/screens/verification_volunteer_dashboard.dart';
import 'package:resq/screens/familysurvay_home.dart';
import 'package:resq/screens/section_a_screen.dart';
import 'package:resq/models/NeedAssessmentData.dart';

void main() async {
  // This is required before calling any platform channels
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  } else {
    // Only request permissions on mobile platforms
    await requestPermission();
  }
  runApp(const MyApp());
}

Future<void> requestPermission() async {
  print("Requesting storage permissions...");

  if (Platform.isAndroid) {
    // For Android 13+ (SDK 33+), we need more specific permissions
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    // For files in external storage on newer Android versions
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    // For photos and media
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
  } else if (Platform.isIOS) {
    // iOS requires specific permissions
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
  }

  // Check final status and log it
  final storageStatus = await Permission.storage.status;
  print("Storage permission status: $storageStatus");
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
      case '/disaster':
        builder =
            (context) =>
                const AuthRoute(requiresAuth: false, child: ItemsList());
        break;
      case '/download':
        builder =
            (context) =>
                const AuthRoute(requiresAuth: false, child: Downloading());
        break;
      case '/families':
        builder =
            (context) => const AuthRoute(
              requiredRoles: ['admin', 'familySurvey'],
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
        builder =
            (context) => const AuthRoute(
              requiredRoles: ['admin'],
              child: RoleCreationScreen(),
            );
        break;
      case '/create-notice':
        builder =
            (context) => const AuthRoute(
              requiredRoles: ['admin'],
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
        builder =
            (context) =>
                AuthRoute(requiresAuth: false, child: DonationRequestPage());
        break;
      case '/loan-relief':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['admin', 'kas', 'superadmin', 'campadmin'],
              child: loan_relief.LoanReliefUploadScreen(),
            );
        break;
      case '/test-family':
        builder = (context) => FamilyDataDownloadScreen();
        break;
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
      case '/test-statistics':
        builder = (context) => DashboardScreen();
        break;
      case '/test-profile':
        builder = (context) => ProfileUpdateScreen();
        break;
      case '/donations':
        builder = (context) => const DonationsScreen();
        break;
      case '/verification-volunteer':
        builder = (context) => const VerificationVolunteerDashboard();
        break;
      case '/add-fam-home':
        builder =
            (context) => AuthRoute(
              requiredRoles: ['familiySurvey'],
              child: FamiliSurveyHomeScreen(),
            );
        break;
      case '/sectionA':
        final data = NeedAssessmentData();
        builder =
            (context) =>
                AuthRoute(requiresAuth: false, child: ScreenA(data: data));
        break;
      case '/logout':
        builder = (BuildContext context) {
          // Execute logout in the next frame after the route is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AuthService().logout().then((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => OtpScreen()),
                (Route<dynamic> route) => false,
              );
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
    if (roles.contains('kas')) return KasDashboard();
    if (roles.contains('collectionPointAdmin'))
      return CollectionPointDashboard();
    if (roles.contains('campAdmin')) return CampAdminRequestScreen();
    if (roles.contains('collectionpointvolunteer')) return VolunteerDashboard();
    return const Scaffold(body: Center(child: Text("No valid role assigned")));
  }
}
