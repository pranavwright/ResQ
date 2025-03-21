import 'package:flutter/material.dart';
import 'package:resq/utils/auth/auth_service.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final List<String> roles;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.roles,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      title: json['title'],
      icon: _getIconData(json['icon']),
      route: json['route'],
      roles: List<String>.from(json['roles']),
    );
  }

  static IconData _getIconData(dynamic icon) {
    if (icon is IconData) {
      return icon;
    } else if (icon == Icons.home) {
      return Icons.home;
    } else if (icon == Icons.person) {
      return Icons.person;
    } else if (icon == Icons.settings) {
      return Icons.settings;
    } else if (icon == Icons.exit_to_app) {
      return Icons.exit_to_app;
    } else {
      // Handle other icons or return a default
      return Icons.error; // Or another default icon
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'route': route,
      'roles': roles,
    };
  }
}

final List<Map<String, dynamic>> menuData = [
  {
    "title": "Home",
    "icon": Icons.home,
    "route": "/home",
    "roles": ["stat", "admin", "kas", "superAdmin", "collectionpointadmin", "campadmin", "collectionpointvolunteer"]
  },
  {
    "title": "Profile",
    "icon": Icons.person,
    "route": "/profile",
    "roles": ["stat", "admin", "kas", "superAdmin", "collectionpointadmin", "campadmin", "collectionpointvolunteer"]
  },
  {
    "title": "Settings",
    "icon": Icons.settings,
    "route": "/settings",
    "roles": ["stat", "admin", "kas", "superAdmin", "collectionpointadmin", "campadmin", "collectionpointvolunteer"]
  },
  {
    "title": "Logout",
    "icon": Icons.exit_to_app,
    "route": "/logout",
    "roles": ["stat", "admin", "kas", "superAdmin", "collectionpointadmin", "campadmin", "collectionpointvolunteer"]
  }
];

List<MenuItem> menuItems = menuData.map((data) => MenuItem.fromJson(data)).toList();

// Example Usage (in a widget build method):

// Assuming you have a user's roles stored in a list called 'userRoles'.
List<MenuItem> getFilteredMenuItems(List<String?> userRoles) {
  userRoles = userRoles.length > 0 ? userRoles : AuthService().getCurrentUserRoles() ?? [];
  return menuItems.where((item) => item.roles.any(userRoles.contains)).toList();
}

// Example usage inside a widget build method.
//List<String> userRoles = ['admin', 'stat']; // Example user roles
//List<MenuItem> filteredMenuItems = getFilteredMenuItems(userRoles);