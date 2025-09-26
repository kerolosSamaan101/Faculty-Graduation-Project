import 'package:FCIS_F1/src/my_app.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/post_storage_service.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Check if we should clear all data (set this to 1 to clear, 0 to keep)
  const int clear = 0; // Change this to 1 to clear all data

  if (clear == 1) {
    await _clearAllAppData(prefs);
    print("All app data has been cleared");
  }

  // First run check (optional)
  bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  if (isFirstRun) {
    await prefs.setBool('isFirstRun', false);
  }

  runApp(MyApp());
}

Future<void> _clearAllAppData(SharedPreferences prefs) async {
  try {
    // Clear all posts
    final postStorage = PostStorageService();
    await postStorage.clearAllPosts();

    // Clear all notifications
    final notificationService = NotificationService();
    await notificationService.clearNotifications();

    // Clear all user accounts and preferences
    await prefs.clear();

    print("Successfully cleared all app data");
  } catch (e) {
    print("Error clearing app data: $e");
  }
}
