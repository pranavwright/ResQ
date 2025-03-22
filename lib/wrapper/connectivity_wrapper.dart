import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:resq/firebase_options.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _hasShownDisconnectedMessage = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    
    if (mounted) {
      if (!isConnected && !_hasShownDisconnectedMessage) {
        _hasShownDisconnectedMessage = true;
        
        // Show a message about lost connection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No internet connection'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/no-network');
              },
            ),
          ),
        );
      } else if (isConnected && _hasShownDisconnectedMessage) {
        _hasShownDisconnectedMessage = false;
        
        // Show reconnected message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection restored')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}