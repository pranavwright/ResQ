import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resq/firebase_options.dart';
import 'package:resq/main.dart';
import 'package:resq/screens/main_home.dart';
import 'package:resq/utils/notification_service.dart';
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
    _checkPendingNotifications();

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
    _checkPendingNotifications();
    if (_isLoading) {
      _initialize(widget.initialRoute);
    }
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

  // Get FCM token for this device
  final token = await messaging.getToken();
  print('FCM Token: $token');
  // You should send this token to your server to target this device
}



  Future<void> _checkPendingNotifications() async {
    final pendingNotification =
        await NotificationService.getPendingNotification();
    if (pendingNotification != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed(
          pendingNotification['route'],
          arguments: pendingNotification['arguments'],
        );
      });
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }

  Future<void> requestPermission() async {


  // Request notification permissions early
  await _requestNotificationPermissions();
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

  Future<void> _initialize(String initialRoute) async {
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      if (!kIsWeb) {
        print("Requesting permissions...");
        await requestPermission();
      }

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message contained a notification: ${message.notification}');
        }
      });

      print("Initializing app...");
      // Check connectivity first
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        final bool hasConnection =
            connectivityResult != ConnectivityResult.none;
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
      } catch (e) {
        print("Error checking connectivity: $e");
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
