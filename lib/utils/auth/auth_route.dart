import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'auth_service.dart';
class AuthRoute extends StatelessWidget {
  final Widget child;
  final bool requiresAuth;
  final List<String>? requiredRoles;
  final String? redirect;

  const AuthRoute({
    Key? key,
    required this.child,
    this.requiresAuth = true,
    this.requiredRoles,
    this.redirect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAuthenticated = authService.isAuthenticated;
    final userRoles = authService.getCurrentUserRoles();
    
    print("AuthRoute - Path: ${ModalRoute.of(context)?.settings.name}, Auth required: $requiresAuth, Is authenticated: $isAuthenticated");
    
    if (redirect != null) {
      print("Redirecting to: $redirect");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(redirect!);
      });
      return Container(); 
    }

    if (requiresAuth && !isAuthenticated) {
      print("Authentication required but not authenticated. Redirecting to login.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(kIsWeb ? '/' : '/otp');
      });
      return Container(); 
    }

    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      final hasRequiredRole = requiredRoles!.any((role) => userRoles.contains(role));
      
      print("Required roles: $requiredRoles, User roles: $userRoles, Has required role: $hasRequiredRole");
      
      if (!hasRequiredRole) {
        print("User does not have required role. Redirecting to app home.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/app');
        });
        return Container(); // Placeholder while redirecting
      }
    }
    if(isAuthenticated && ModalRoute.of(context)?.settings.name == '/otp'){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/app');
      });
      return Container();
    }

    return child;
  }
}