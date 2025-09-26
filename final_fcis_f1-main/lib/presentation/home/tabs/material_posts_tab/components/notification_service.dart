import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/post_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'models.dart' as models;

class NotificationService {
  static const String _notificationsKey = 'all_notifications';
  static const String _readStatusKeyPrefix = 'read_status_';
  final Uuid _uuid = Uuid();

  Future<models.Notification> _createBaseNotification({
    required String postId,
    required models.PostType postType,
    required String userId,
    required String userName,
    required String content,
    String? userImage,
    String? jobTitle,
    String? userStatus,
    String? category,
    String? notificationType,
  }) async {
    return models.Notification(
      id: _uuid.v4(),
      postId: postId,
      postType: postType,
      userId: userId,
      userName: userName,
      userImage: userImage,
      jobTitle: jobTitle,
      userStatus: userStatus,
      postPreview:
          content.length > 50 ? '${content.substring(0, 50)}...' : content,
      timestamp: DateTime.now(),
      category: category,
      notificationType: notificationType,
    );
  }

  // Add this method to NotificationService class
  Future<int> getUnreadNotificationCount(String userId) async {
    final notifications = await getNotificationsForUser(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> addNotification(models.Notification notification) async {
    if (kDebugMode) {
      print(
          '[NotificationService] Adding notification for post: ${notification.postId}');
      print(
          'Type: ${notification.postType}, Category: ${notification.category}');
      print('From: ${notification.userStatus}');
    }

    final notifications = await getAllNotifications();
    notifications.insert(0, notification);
    await _saveAllNotifications(notifications);
  }

  Future<List<models.Notification>> getAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    return notificationsJson
        .map((json) {
          try {
            return models.Notification.fromMap(jsonDecode(json));
          } catch (e) {
            if (kDebugMode) {
              print('[NotificationService] Error parsing notification: $e');
            }
            return null;
          }
        })
        .whereType<models.Notification>()
        .toList();
  }

  Future<List<models.Notification>> getNotificationsForUser(
      String userId) async {
    if (kDebugMode) {
      print('[NotificationService] Getting notifications for user: $userId');
    }

    final prefs = await SharedPreferences.getInstance();
    final allNotifications = await getAllNotifications();
    final readStatusKey = '${_readStatusKeyPrefix}$userId';

    // Get current user data
    final userInterests = prefs.getStringList('userInterests') ?? [];
    final userStatus = prefs.getString('userStatus') ?? 'Student';

    if (kDebugMode) {
      print('Current User Status: $userStatus');
      print('Current User Interests: $userInterests');
    }

    final readStatusMap = prefs.getString(readStatusKey) != null
        ? Map<String, bool>.from(jsonDecode(prefs.getString(readStatusKey)!))
        : <String, bool>{};

    final filteredNotifications = <models.Notification>[];
    final seenCommentNotifications = <String, bool>{};

    for (final notification in allNotifications) {
      if (kDebugMode) {
        print('\nProcessing notification ID: ${notification.id}');
        print(
            'Post ID: ${notification.postId}, Type: ${notification.postType}');
        print('From: ${notification.userId} (${notification.userStatus})');
        print('Category: ${notification.category}');
        print('Special Type: ${notification.notificationType}');
      }

      // 1. Special handling for opportunity reports
      if (notification.notificationType == 'opportunity_report') {
        // Only show to the company rep who created it
        if (notification.userId == userId) {
          filteredNotifications.add(notification.copyWith(
            isRead: readStatusMap[notification.id] ?? false,
          ));
          if (kDebugMode) {
            print('Including opportunity report notification');
          }
        } else {
          if (kDebugMode) {
            print('Skipping: Opportunity report not meant for this user');
          }
        }
        continue;
      }

      // 2. Skip notifications from current user
      if (notification.userId == userId) {
        if (kDebugMode) {
          print('Skipping: Notification from current user');
        }
        continue;
      }

      // 3. Check status-based visibility rules
      final statusAllowed = shouldReceiveNotification(
        posterStatus: notification.userStatus ?? 'Student',
        receiverStatus: userStatus,
        postType: notification.postType,
      );

      if (!statusAllowed) {
        if (kDebugMode) {
          print('Skipping: Status rules not allowed');
        }
        continue;
      }

      // 4. Check interest matching
      if (notification.category == null) {
        if (kDebugMode) {
          print('Skipping: No category specified');
        }
        continue;
      }

      final interestMatch = userInterests.contains(notification.category) ||
          (notification.category == 'Other' && userInterests.contains('Other'));

      if (!interestMatch) {
        if (kDebugMode) {
          print('Skipping: Category not matched (${notification.category})');
        }
        continue;
      }

      // 5. Additional check for duplicate comment notifications
      if (notification.postType == models.PostType.qna) {
        final commentKey = '${notification.postId}_${notification.userId}';
        if (seenCommentNotifications.containsKey(commentKey)) {
          if (kDebugMode) {
            print('Skipping: Duplicate comment notification detected');
          }
          continue;
        }
        seenCommentNotifications[commentKey] = true;
      }

      // If all checks passed, include the notification
      filteredNotifications.add(notification.copyWith(
        isRead: readStatusMap[notification.id] ?? false,
      ));
      if (kDebugMode) {
        print('Including notification');
      }
    }

    // Sort by timestamp (newest first)
    filteredNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (kDebugMode) {
      print('\nFinal notifications count: ${filteredNotifications.length}');
      print('====================================');
    }

    return filteredNotifications;
  }

  Future<models.Notification> createOpportunityNotification({
    required String postId,
    required String userId,
    required String userName,
    required String jobTitle,
    String? userImage,
    String? userStatus,
    required String category,
  }) async {
    final notification = await _createBaseNotification(
      postId: postId,
      postType: models.PostType.opportunity,
      userId: userId,
      userName: userName,
      content: 'New opportunity in $category: $jobTitle',
      userImage: userImage,
      jobTitle: jobTitle,
      userStatus: userStatus,
      category: category,
    );
    await addNotification(notification);
    return notification;
  }

  Future<models.Notification> createOpportunityReport({
    required String postId,
    required String userId,
    required String userName,
    String? userImage,
    String? jobTitle,
    String? userStatus,
    required String category,
  }) async {
    final notification = await _createBaseNotification(
      postId: postId,
      postType: models.PostType.opportunity,
      userId: userId,
      userName: userName,
      content: 'View candidate matches for: $category',
      userImage: userImage,
      jobTitle: jobTitle,
      userStatus: userStatus,
      category: category,
      notificationType: 'opportunity_report',
    );
    await addNotification(notification);
    return notification;
  }

  Future<List<models.Notification>> getNotificationsForPost(
      String postId) async {
    final notifications = await getAllNotifications();
    return notifications.where((n) => n.postId == postId).toList();
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final readStatusKey = '$_readStatusKeyPrefix$userId';
    final prefs = await SharedPreferences.getInstance();
    final readStatusMap = prefs.getString(readStatusKey) != null
        ? Map<String, bool>.from(jsonDecode(prefs.getString(readStatusKey)!))
        : <String, bool>{};
    readStatusMap[notificationId] = true;
    await prefs.setString(readStatusKey, jsonEncode(readStatusMap));
    if (kDebugMode) {
      print('Marked notification $notificationId as read for user $userId');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final readStatusKey = '$_readStatusKeyPrefix$userId';
    final prefs = await SharedPreferences.getInstance();
    final allNotifications = await getAllNotifications();
    final readStatusMap = <String, bool>{};

    for (var notification in allNotifications) {
      readStatusMap[notification.id] = true;
    }

    await prefs.setString(readStatusKey, jsonEncode(readStatusMap));
    if (kDebugMode) {
      print('Marked all notifications as read for user $userId');
    }
  }

  Future<void> removeNotification(String notificationId) async {
    final notifications = await getAllNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveAllNotifications(notifications);
    if (kDebugMode) {
      print('Removed notification $notificationId');
    }
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);

    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(_readStatusKeyPrefix)) {
        await prefs.remove(key);
      }
    }
    if (kDebugMode) {
      print('Cleared all notifications and read statuses');
    }
  }

  bool shouldReceiveNotification({
    required String posterStatus,
    required String receiverStatus,
    required models.PostType postType,
  }) {
    if (kDebugMode) {
      print('Checking status rules:');
      print(
          'Poster: $posterStatus, Receiver: $receiverStatus, Type: $postType');
    }

    // Q&A Tab Rules
    if (postType == models.PostType.qna) {
      switch (posterStatus) {
        case 'Student':
          return receiverStatus == 'Student' ||
              receiverStatus == 'Graduate' ||
              receiverStatus == 'Employee';
        case 'Graduate':
          return receiverStatus == 'Graduate' ||
              receiverStatus == 'Employee' ||
              receiverStatus == 'Company Representative';
        case 'Employee':
          return receiverStatus == 'Employee' ||
              receiverStatus == 'Company Representative';
        case 'Company Representative':
          return receiverStatus == 'Student' ||
              receiverStatus == 'Graduate' ||
              receiverStatus == 'Employee';
        default:
          return false;
      }
    }

    // Material Posts Tab Rules
    if (postType == models.PostType.material) {
      switch (posterStatus) {
        case 'Student':
          return receiverStatus == 'Student';
        case 'Graduate':
        case 'Employee':
        case 'Company Representative':
          return receiverStatus == 'Student' ||
              receiverStatus == 'Graduate' ||
              receiverStatus == 'Employee';
        default:
          return false;
      }
    }

    // Opportunity Tab Rules
    if (postType == models.PostType.opportunity) {
      return receiverStatus == 'Student' ||
          receiverStatus == 'Graduate' ||
          receiverStatus == 'Employee';
    }

    return false;
  }

  Future<models.Notification> createPostNotification({
    required String postId,
    required models.PostType postType,
    required String userId,
    required String userName,
    required String content,
    String? userImage,
    String? jobTitle,
    String? userStatus,
    String? category,
    String? notificationType,
  }) async {
    if (kDebugMode) {
      print('[NotificationService] Creating notification for post: $postId');
      print('Type: ${postType.toString()} | Category: $category');
      print('From: $userName ($userId) | Status: $userStatus');
    }

    // Special handling for opportunity posts from company reps
    if (postType == models.PostType.opportunity &&
        userStatus == 'Company Representative') {
      final reportNotification = models.Notification(
        id: _uuid.v4(),
        postId: postId,
        postType: postType,
        userId: userId,
        userName: userName,
        userImage: userImage,
        jobTitle: jobTitle,
        userStatus: userStatus,
        postPreview: "View matching candidates for: $category",
        timestamp: DateTime.now(),
        category: category,
        notificationType: 'opportunity_report',
      );

      await addNotification(reportNotification);

      if (kDebugMode) {
        print('Created OPPORTUNITY REPORT notification for company rep');
        print('Notification ID: ${reportNotification.id}');
      }

      return reportNotification;
    }

    // Standard notification for all other cases
    final notification = models.Notification(
      id: _uuid.v4(),
      postId: postId,
      postType: postType,
      userId: userId,
      userName: userName,
      userImage: userImage,
      jobTitle: jobTitle,
      userStatus: userStatus ?? 'Student',
      postPreview:
          content.length > 50 ? '${content.substring(0, 50)}...' : content,
      timestamp: DateTime.now(),
      category: category,
      notificationType: notificationType,
    );

    await addNotification(notification);

    if (kDebugMode) {
      print('Created STANDARD notification');
      print('Notification ID: ${notification.id}');
    }

    return notification;
  }

  Future<void> _saveAllNotifications(
      List<models.Notification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson =
        notifications.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
    if (kDebugMode) {
      print('Saved ${notifications.length} notifications');
    }
  }
}
