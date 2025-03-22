import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resq/firebase_options.dart';
import 'package:resq/widgets/text_animation.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasConnection = connectivityResult != ConnectivityResult.none;
    
    if (!mounted) return;
    
    // If no connection, show no network screen
    if (!hasConnection) {
      Navigator.of(context).pushReplacementNamed('/no-network');
      return;
    }
    
    // Load auth state
    final authService =await AuthService();
    await authService.loadAuthState();
    final isAuthenticated = authService.isAuthenticated;
    final isComplete = authService.isProfileComplete();
    final roles = authService.getCurrentUserRoles() ?? [];
    
    if (!mounted) return;
    
    // Determine which screen to show
    String initialRoute;
    if (kIsWeb && Uri.base.path.isNotEmpty && Uri.base.path != '/') {
      initialRoute = Uri.base.path;
    } else {
      initialRoute = isAuthenticated
          ? isComplete
              ? '/app'
              : '/profile-setup'
          : kIsWeb
              ? '/'
              : '/otp';
    }
    
    Navigator.of(context).pushReplacementNamed(initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (replace with your app logo)
            Image.asset(
              'assets/images/logo.jpg',
              width: 160,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.volunteer_activism, 
                  size: 80, color: Theme.of(context).primaryColor);
              },
            ),
            const SizedBox(height: 40),
            // Animated text
            LoadingResqAnimation(text: "ResQ"),
            const SizedBox(height: 30),
            // const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}