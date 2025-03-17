import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../screens/no_network_screen.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  late final Connectivity _connectivity;
  
  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    
    // Check connectivity initially
    _checkConnectivity();
    
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      setState(() => _isConnected = false);
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    print('Connectivity status changed: $result');
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If connected, show the main app, otherwise show the no network screen
    return _isConnected 
      ? widget.child 
      : NoNetworkScreen(
          onRetry: _checkConnectivity,
        );
  }
}