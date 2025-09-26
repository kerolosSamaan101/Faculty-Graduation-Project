import 'package:FCIS_F1/presentation/home/tabs/opportioneties_tab/opportunity_report_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FCIS_F1/core/utils/colors_manager.dart';
import 'package:FCIS_F1/core/utils/routes_manager.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/models.dart'
    as models;
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/notification_service.dart';
import 'dart:io';

class NotificationTab extends StatefulWidget {
  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  final NotificationService _notificationService = NotificationService();
  List<models.Notification> _notifications = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _currentUserStatus;
  List<String> _userInterests = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndNotifications();
    _checkForceRefresh();
  }

  Future<void> _checkForceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('force_notification_refresh') == true) {
      await prefs.remove('force_notification_refresh');
      if (mounted) {
        await _loadUserDataAndNotifications();
      }
    }
  }

  bool _shouldShowNotification(models.Notification notification) {
    // Debug information header
    debugPrint('\n=== Notification Filter ===');
    debugPrint('Notification ID: ${notification.id}');
    debugPrint(
        'Type: ${notification.postType} | Special Type: ${notification.notificationType}');
    debugPrint('Category: ${notification.category}');
    debugPrint('From: ${notification.userId} (${notification.userStatus})');
    debugPrint('Current User: $_currentUserId ($_currentUserStatus)');
    debugPrint('User Interests: $_userInterests');

    // 1. FIRST - Handle opportunity reports (show only to creator)
    if (notification.notificationType == 'opportunity_report') {
      final shouldShow = notification.userId == _currentUserId;
      debugPrint('🔐 OPPORTUNITY REPORT - Show to creator only: $shouldShow');
      return shouldShow;
    }

    // 2. Skip notifications from current user
    if (notification.userId == _currentUserId) {
      debugPrint('🚫 FILTERED: Notification from current user');
      return false;
    }

    // 3. Handle STANDARD opportunity notifications
    if (notification.postType == models.PostType.opportunity &&
        notification.notificationType != 'opportunity_report') {
      debugPrint('💼 Processing STANDARD OPPORTUNITY');

      // 3a. Check valid receiver status
      final validStatus =
          ['Student', 'Graduate', 'Employee'].contains(_currentUserStatus);
      if (!validStatus) {
        debugPrint(
            '🚫 FILTERED: Invalid status $_currentUserStatus for opportunities');
        return false;
      }

      // 3b. Check category exists
      if (notification.category == null) {
        debugPrint('🚫 FILTERED: Missing opportunity category');
        return false;
      }

      // 3c. Case-insensitive interest matching
      final categoryLower = notification.category!.toLowerCase().trim();
      final hasInterestMatch = _userInterests.any((interest) {
        final interestLower = interest?.toLowerCase()?.trim() ?? '';
        return interestLower == categoryLower ||
            (categoryLower == 'other' && interestLower == 'other');
      });

      debugPrint(hasInterestMatch
          ? '✅ OPPORTUNITY MATCH: Category "$categoryLower" found in interests'
          : '🚫 OPPORTUNITY MISMATCH: No matching interest for "$categoryLower"');
      return hasInterestMatch;
    }

    // 4. Handle OTHER notification types (material, qna)
    debugPrint('📄 Processing REGULAR notification');

    // 4a. Status-based filtering
    final statusAllowed = _notificationService.shouldReceiveNotification(
      posterStatus: notification.userStatus ?? 'Student',
      receiverStatus: _currentUserStatus ?? 'Student',
      postType: notification.postType,
    );

    if (!statusAllowed) {
      debugPrint('🚫 FILTERED: Status rules not allowed');
      return false;
    }

    // 4b. Category-based filtering
    if (notification.category == null) {
      debugPrint('✅ SHOWING: Notification without category');
      return true;
    }

    final categoryMatch = _userInterests.contains(notification.category) ||
        (notification.category == 'Other' && _userInterests.contains('Other'));

    debugPrint(categoryMatch
        ? '✅ CATEGORY MATCH: "${notification.category}" found in interests'
        : '🚫 CATEGORY MISMATCH: No matching interest for "${notification.category}"');

    return categoryMatch;
  }

  Future<void> _loadUserDataAndNotifications() async {
    try {
      debugPrint('\n=== LOADING NOTIFICATIONS ===');
      final prefs = await SharedPreferences.getInstance();

      // Load current user data
      final currentUserEmail = prefs.getString('currentUserEmail');
      final userKey =
          currentUserEmail != null ? 'user_$currentUserEmail' : null;

      setState(() {
        _currentUserId = prefs.getString('userId');
        _currentUserStatus = prefs.getString('$userKey.status') ??
            prefs.getString('userStatus') ??
            'Student';
        _userInterests = prefs.getStringList('$userKey.interests') ??
            prefs.getStringList('userInterests') ??
            [];
        _isLoading = true;
      });

      debugPrint('User Status: $_currentUserStatus');
      debugPrint('User Interests: $_userInterests');

      if (_currentUserId == null) {
        debugPrint('No user ID - skipping notifications');
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
        return;
      }

      // Load and filter notifications
      final allNotifications =
          await _notificationService.getNotificationsForUser(_currentUserId!);
      debugPrint('Total notifications: ${allNotifications.length}');

      final filteredNotifications =
          allNotifications.where(_shouldShowNotification).toList();
      debugPrint('Filtered notifications: ${filteredNotifications.length}');

      setState(() {
        _notifications = filteredNotifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshNotifications() async {
    debugPrint('Refreshing notifications...');
    setState(() => _isLoading = true);
    await _loadUserDataAndNotifications();
  }

  void _navigateToPost(models.Notification notification) async {
    if (_currentUserId == null) return;

    // Mark as read first
    await _notificationService.markAsRead(notification.id, _currentUserId!);

    if (notification.notificationType == 'opportunity_report') {
      // Verify this is the company rep who created the opportunity
      if (notification.userId == _currentUserId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OpportunityReportPage(
              opportunityCategory: notification.category ?? 'Other',
            ),
          ),
        );
      } else {
        if (kDebugMode) {
          print('Blocked unauthorized access to opportunity report');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You do not have access to this report')),
        );
      }
    } else {
      // Handle standard notifications
      switch (notification.postType) {
        case models.PostType.material:
          Navigator.pushNamed(context, RoutsManager.materialPostsScreen);
          break;
        case models.PostType.qna:
          Navigator.pushNamed(context, RoutsManager.q_and_answer_Screen);
          break;
        case models.PostType.opportunity:
          Navigator.pushNamed(context, RoutsManager.opportunitiesScreen);
          break;
      }
    }

    // Refresh notifications
    await _loadUserDataAndNotifications();
  }

  Future<void> _clearAllNotifications() async {
    debugPrint('Clearing all notifications');
    await _notificationService.clearNotifications();
    if (mounted) {
      setState(() => _notifications = []);
    }
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId == null) return;
    debugPrint('Marking all notifications as read');
    await _notificationService.markAllAsRead(_currentUserId!);
    await _loadUserDataAndNotifications();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getPostTypeLabel(models.PostType postType) {
    switch (postType) {
      case models.PostType.material:
        return 'Material Post';
      case models.PostType.qna:
        return 'Q&A Post';
      case models.PostType.opportunity:
        return 'Opportunity';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backGroundColor,
        title: Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshNotifications,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'mark_all_read') _markAllAsRead();
              if (value == 'clear_all') _clearAllNotifications();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all notifications'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: ColorsManager.darkGrey))
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              color: ColorsManager.darkGrey,
              child: _notifications.isEmpty
                  ? Center(
                      child: Text(
                        "No new notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 20),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
            ),
    );
  }

  Widget _buildNotificationCard(models.Notification notification) {
    return Card(
      color: notification.isRead
          ? ColorsManager.darkGrey.withOpacity(0.7)
          : ColorsManager.darkGrey,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: notification.isRead ? Colors.transparent : Colors.blue,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToPost(notification),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: notification.userImage != null &&
                            notification.userImage!.isNotEmpty
                        ? FileImage(File(notification.userImage!))
                            as ImageProvider
                        : AssetImage("assets/images/profile_img.png")
                            as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        if (notification.jobTitle != null &&
                            notification.jobTitle!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              notification.jobTitle!,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        SizedBox(height: 8),
                        Text(
                          notification.postPreview,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (notification.category != null) ...[
                          SizedBox(height: 8),
                          Chip(
                            label: Text(
                              notification.category!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeAgo(notification.timestamp),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getPostTypeLabel(notification.postType),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
