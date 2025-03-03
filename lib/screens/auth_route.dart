import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthRoute extends StatelessWidget {
  final Widget child;
  final bool requiresAuth;
  final List<String> requiredRoles;
  final String unauthorizedRedirect;

  const AuthRoute({
    super.key,
    required this.child,
    this.requiresAuth = true,
    this.requiredRoles = const [],
    this.unauthorizedRedirect = '/app',
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final bool isAuthenticated = authService.isAuthenticated;

    // If authentication is required and user is not authenticated, redirect to login
    if (requiresAuth && !isAuthenticated) {
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If user is authenticated and trying to access login/otp screens, redirect to dashboard
    if (isAuthenticated && !requiresAuth) {
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(unauthorizedRedirect, (route) => false);
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If route requires specific roles and user doesn't have them, redirect to dashboard
    if (requiredRoles.isNotEmpty && !authService.hasAnyRole(requiredRoles)) {
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(unauthorizedRedirect, (route) => false);
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Normal case: return the requested screen
    return child;
  }
}
