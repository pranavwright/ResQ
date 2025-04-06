import 'package:resq/utils/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static const String _pendingNotificationKey = 'pending_notification';
  
  // Save notification info for later navigation
  static Future<void> savePendingNotification(String route, dynamic arguments) async {
    await AuthService().saveToLocal(_pendingNotificationKey, jsonEncode({
      'route': route,
      'arguments': arguments,
    }));
  }
  
  // Get and clear any pending notification
  static Future<Map<String, dynamic>?> getPendingNotification() async {
    final String? notificationData = await AuthService().readFromStorage(_pendingNotificationKey);
    
    if (notificationData != null && notificationData.isNotEmpty ) {
      await AuthService().deleteFromStorage(_pendingNotificationKey);
      return  jsonDecode(notificationData) ;
    }
    return null;
  }
}