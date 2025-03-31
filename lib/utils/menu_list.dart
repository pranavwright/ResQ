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

  Map<String, dynamic> toJson() {
    return {'title': title, 'icon': icon, 'route': route, 'roles': roles};
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      title: json['title'],
      icon: json['icon'],
      route: json['route'],
      roles: List<String>.from(json['roles']),
    );
  }
}

final List<Map<String, dynamic>> menuData = [
  {
    "title": "Home",
    "icon": Icons.home,
    "route": "/app",
    "roles": ["all"],
  },
  {
    "title": "Families",
    "icon": Icons.people,
    "route": "/family-data-download",
    "roles": ["admin", "stat"],
  },
  {
    "title": "Camp Status",
    "icon": Icons.home_work,
    "route": "/camp-status", // screen route
    "roles": ["admin"],
  },
  {
    "title": "Notice Board",
    "icon": Icons.announcement,
    "route": "/notice-board",
    "roles": ["admin", "stat"],
  },
  {
    "title": "Officals",
    "icon": Icons.assignment_ind,
    "route": "/role-creation",
    "roles": ["admin","stat"],
  },
  {
    "title": "Collection Points",
    "icon": Icons.add_location,
    "route": '/admin-collectionpoint',
    "roles": ["admin"],
  },
  {
    "title": "Identity",
    "icon": Icons.person,
    "route": "/identity",
    "roles": ["all"],
  },
  {
    "title": "Family Survey",
    "icon": Icons.family_restroom,
    "route": "/family-survey",
    "roles": ['surveyOfficial'],
  },
  {
    'title': 'Verification ',
    'icon': Icons.verified_user,
    'route': '/verification-volunteer',
    'roles': ['verifyOfficial'],
  },
  {
    'title': 'Manage Camp',
    'icon': Icons.cabin,
    'route': '/manage-camp',
    'roles': ['campAdmin'],
  },
  {
    'title': 'Manage Collection Point',
    'icon': Icons.cabin,
    'route': '/manage-collectionpoint',
    'roles': ['collectionPointAdmin'],
  },
  {
    'title': 'Need Assessment Surveys',
    'icon': Icons.assignment,
    'route': '/need-assessment-surveys',
    'roles': ['surveyOfficial'],
  },
  {
    'title': 'Collection Point Requests',
    'icon': Icons.request_page,
    'route': '/collectionpoint-volunteer',
    'roles': ['collectionpointvolunteer'],
  },
  {
    'title': 'Change Disaster',
    'icon': Icons.change_circle,
    'route': '/change-disaster',
    'roles': ['all'],
  },
  {
    'title': 'Disaster Data',
    'icon': Icons.data_usage,
    'route':'/disaster',
    'roles': ['noAuth'],
  },
  {
    'title':'loan',
    'icon': Icons.money,
    'route': '/loan-relief',
    'roles': ['stat'],
  },
  {
    "title": "Logout",
    "icon": Icons.exit_to_app,
    "route": "/logout",
    "roles": ["all"],
  },
  {
    'title':'Collection Point Volunteer Management',
    'icon': Icons.group,
    'route': '/collectionpoint-volunteer-management',
    'roles': ['collectionPointAdmin'],
  }
];

List<MenuItem> menuItems =
    menuData.map((data) => MenuItem.fromJson(data)).toList();

// Function to get filtered menu items based on user roles
List<MenuItem> getFilteredMenuItems(List<dynamic> userRoles) {
  // Convert dynamic userRoles to string list
  final roles = List<String>.from(userRoles.whereType<String>());

  // Use current user roles if userRoles is empty
  List<dynamic> updatedUserRoles =
      userRoles.isNotEmpty
          ? userRoles
          : AuthService().getCurrentUserRoles() ?? [];

  if (updatedUserRoles.isNotEmpty && roles.isEmpty) {
    roles.add("all");
    roles.add("noAuth");
    roles.addAll(updatedUserRoles.whereType<String>());
  } else {
    roles.add("noAuth");
  }

  return menuItems
      .where((item) => item.roles.any((role) => roles.contains(role)))
      .toList();
}

