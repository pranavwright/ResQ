import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resq/firebase_options.dart';
import 'package:resq/screens/mian_home.dart';
import 'package:resq/widgets/text_animation.dart';
import 'package:resq/utils/auth/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  final String initialRoute;

  const SplashScreen({super.key, required this.initialRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  bool _initStarted = false; // Add flag to prevent multiple initializations

  @override
  void initState() {
    super.initState();
    // Only start initialization once
    if (!_initStarted) {
      _initStarted = true;
      _initialize(widget.initialRoute);
    }

    // Add a timeout to prevent the splash screen from hanging indefinitely
    Future.delayed(Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Initialization took too long. Please restart the app.';
        });
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => MainHome()));
        return;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _initialize(widget.initialRoute);
    }
  }

  Future<void> _initialize(String initialRoute) async {
    try {

      try {
        print("Initializing Firebase...");
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print("Firebase initialized successfully");
      } catch (e) {
        print("Error initializing Firebase: $e");
      }


      print("Initializing app...");
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasConnection = connectivityResult != ConnectivityResult.none;
      print("Network connectivity: $hasConnection");

      if (!hasConnection) {
        print("No network connection, showing no-network screen");
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/no-network');
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load auth state
      print("Loading auth state...");
      final authService = AuthService();
      await authService.loadAuthState();
      final isAuthenticated = authService.isAuthenticated;
      final isComplete = authService.isProfileComplete();
      print(
        "Auth state: isAuthenticated=$isAuthenticated, isComplete=$isComplete",
      );

      if (!mounted) return;

      if (initialRoute.isNotEmpty && initialRoute != '/') {
        Navigator.of(context).pushReplacementNamed(initialRoute);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      initialRoute =
          isAuthenticated
              ? isComplete
                  ? '/app'
                  : '/profile-setup'
              : kIsWeb
              ? '/'
              : '/otp';

      print("Navigating to route: $initialRoute");
      if (initialRoute == '/') {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => MainHome()));
        setState(() {
          _isLoading = false;
        });
        return;
      }
      Navigator.of(context).pushReplacementNamed(initialRoute);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error during app initialization: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to initialize app: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.jpg',
              width: 160,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.volunteer_activism,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
            const SizedBox(height: 40),
            // Animated text
            LoadingResqAnimation(text: "ResQ"),
            const SizedBox(height: 30),

            // Show error message if any
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
