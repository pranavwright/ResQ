import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../screens/no_network_screen.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _hasShownDisconnectedMessage = false;
  String _lastRoute = '/';

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Check connectivity with debounce to avoid rapid state changes
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      setState(() => _isConnected = result != ConnectivityResult.none);

      // Subscribe to connectivity changes with debounce
      _subscription = Connectivity().onConnectivityChanged.listen((result) {
        if (mounted) {
          setState(() => _isConnected = result != ConnectivityResult.none);

          if (_isConnected && _hasShownDisconnectedMessage) {
            _hasShownDisconnectedMessage = false;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Connection restored')));
          }

          if (!_isConnected) {
            _hasShownDisconnectedMessage = true;
            // Store current route when disconnecting
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != null && currentRoute != '/no-network') {
              _lastRoute = currentRoute;
            }
          }
        }
      });
    } catch (e) {
      print('Connectivity check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home:
          _isConnected
              ? widget.child
              : NoNetworkScreen(
                onRetry: () async {
                  final result = await Connectivity().checkConnectivity();
                  if (result != ConnectivityResult.none && mounted) {
                    setState(() => _isConnected = true);
                    if (_lastRoute.isNotEmpty) {
                      Navigator.of(context).pushReplacementNamed(_lastRoute);
                    }
                  }
                },
              ),
    );
  }
}
