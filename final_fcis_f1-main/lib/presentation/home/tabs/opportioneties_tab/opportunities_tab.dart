import 'dart:convert';
import 'dart:io';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:FCIS_F1/core/utils/colors_manager.dart';
import 'package:FCIS_F1/core/utils/routes_manager.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/models.dart'
    as models;
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/notification_service.dart';
import 'opportunity_form_page.dart';

class OpportunitiesPage extends StatefulWidget {
  @override
  _OpportunitiesPageState createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  String selectedFilter = 'All';
  String? userName;
  String? userPosition;
  String? userImageUrl;
  String? userStatus;
  String? _currentUserId;
  List<String> userInterests = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final double _appBarElevation = 4.0;
  final Uuid _uuid = Uuid();

  List<Map<String, dynamic>> jobPosts = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndOpportunities();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndOpportunities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('userId');
      final currentUserEmail = prefs.getString('currentUserEmail');

      if (currentUserEmail != null) {
        final userKey = 'user_$currentUserEmail';

        setState(() {
          userName = prefs.getString('$userKey.fullName') ?? 'User Name';
          userPosition = prefs.getString('$userKey.jobTitle')?.trim();
          userStatus = prefs.getString('$userKey.status')?.trim();
          userImageUrl = prefs.getString('$userKey.profileImagePath');
          userInterests = prefs.getStringList('$userKey.interests') ?? [];
        });
      }

      final savedOpportunities = prefs.getStringList('opportunities') ?? [];
      setState(() {
        jobPosts = savedOpportunities
            .map((json) {
              try {
                final decoded = jsonDecode(json);
                return Map<String, dynamic>.from(decoded);
              } catch (e) {
                return <String, dynamic>{};
              }
            })
            .where((post) => post.isNotEmpty)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load opportunities: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveOpportunities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'opportunities',
      jobPosts.map((post) => jsonEncode(post)).toList(),
    );
  }

  // In the _OpportunitiesPageState class
  Future<void> _submitOpportunity(Map<String, dynamic> newPost) async {
    try {
      final opportunityId = _uuid.v4();
      final category = newPost['category'] ?? 'Other';
      final jobTitle = newPost['jobTitle'] ?? 'Opportunity';

      // Add to job posts
      setState(() {
        jobPosts.insert(0, {
          ...newPost,
          'id': opportunityId,
          'userName': userName ?? 'User Name',
          'userPosition': getUserPositionText(),
          'userImageUrl': userImageUrl ?? '',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });

      final notificationService = NotificationService();

      // Create regular opportunity notification
      await notificationService.createOpportunityNotification(
        postId: opportunityId,
        userId: _currentUserId!,
        userName: userName ?? 'Company',
        jobTitle: jobTitle,
        userImage: userImageUrl,
        userStatus: userStatus,
        category: category,
      );

      // Create opportunity report
      await notificationService.createOpportunityReport(
        postId: opportunityId,
        userId: _currentUserId!,
        userName: userName ?? 'Company',
        userImage: userImageUrl,
        jobTitle: getUserPositionText(),
        userStatus: userStatus,
        category: category,
      );

      await _saveOpportunities();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('force_notification_refresh', true);
    } catch (e) {
      debugPrint('Error creating opportunity: $e');
    }
  }

  String getUserPositionText() {
    if (userPosition != null && userPosition!.isNotEmpty) {
      return userPosition!;
    } else if (userStatus != null && userStatus!.isNotEmpty) {
      return userStatus!;
    } else {
      return '';
    }
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            selectedFilter = selected ? value : 'All';
          });
        },
        selectedColor: ColorsManager.darkGrey,
        labelStyle: TextStyle(
          color: selectedFilter == value
              ? ColorsManager.backGroundColor
              : Colors.black,
        ),
        backgroundColor: ColorsManager.backGroundColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: ColorsManager.backGroundColor,
            fontSize: 12,
          ),
        ),
        backgroundColor: ColorsManager.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }

  Widget _buildFieldRow(String label, String? value, {bool isLink = false}) {
    if (value == null || value.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorsManager.darkGrey,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: isLink
                ? InkWell(
                    onTap: () async {
                      final uri = Uri.parse(
                          value.startsWith('http') ? value : 'https://$value');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> post) {
    final isCurrentUserPost = post['userName'] == userName;
    final postedDate = DateTime.tryParse(post['timestamp'] ?? '');
    final formattedDate = postedDate != null
        ? '${postedDate.day}/${postedDate.month}/${postedDate.year}'
        : '';

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: ColorsManager.darkGrey,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        focusColor: ColorsManager.darkGrey,
        onTap: () {
          // Potential expansion for detailed view
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: post['userImageUrl'] != null &&
                            post['userImageUrl'].toString().isNotEmpty
                        ? (post['userImageUrl'].toString().startsWith('http')
                                ? NetworkImage(post['userImageUrl'].toString())
                                : FileImage(
                                    File(post['userImageUrl'].toString())))
                            as ImageProvider<Object>?
                        : AssetImage('assets/images/profile_img.png')
                            as ImageProvider<Object>?,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['userName']?.toString() ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        if (post['userPosition']?.toString()?.isNotEmpty ??
                            false)
                          Text(
                            post['userPosition']?.toString() ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        if (formattedDate.isNotEmpty)
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isCurrentUserPost)
                    Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 18,
                    ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                post['jobTitle']?.toString() ?? 'Opportunity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      post['jobType']?.toString() ?? 'Unknown',
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: ColorsManager.darkGrey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                  if (post['location']?.toString()?.isNotEmpty ?? false)
                    Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 14),
                          SizedBox(width: 4),
                          Text(
                            post['location']?.toString() ?? '',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      backgroundColor: ColorsManager.darkGrey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                ],
              ),
              SizedBox(height: 16),
              _buildFieldRow('Company', post['companyName']),
              _buildFieldRow('Website', post['website'], isLink: true),
              _buildFieldRow('Contact', post['contactEmail']),
              _buildFieldRow('Salary', post['salary']),
              if (post['description']?.toString()?.isNotEmpty ?? false) ...[
                SizedBox(height: 8),
                Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.darkGrey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  post['description']?.toString() ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
              if (post['skills']?.toString()?.isNotEmpty ?? false) ...[
                SizedBox(height: 8),
                Text(
                  'Skills:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.darkGrey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  post['skills']?.toString() ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
              if (post['qualifications']?.toString()?.isNotEmpty ?? false) ...[
                SizedBox(height: 8),
                Text(
                  'Qualifications:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.darkGrey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  post['qualifications']?.toString() ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPosts = selectedFilter == 'All'
        ? jobPosts
        : jobPosts.where((post) => post['jobType'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      appBar: AppBar(
        elevation: _appBarElevation,
        backgroundColor: ColorsManager.backGroundColor,
        title: Text(
          "Opportunities",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          if (userStatus == 'Company Representative')
            Container(
              decoration: BoxDecoration(
                  color: ColorsManager.darkGrey,
                  borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: ColorsManager.backGroundColor,
                  size: 24,
                ),
                // In the onPressed handler for the add button:
                onPressed: () async {
                  final newPost = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OpportunityFormPage()),
                  );
                  if (newPost != null) {
                    await _submitOpportunity(newPost);
                  }
                },
              ),
            ),
          SizedBox(width: 8),
          FutureBuilder<int>(
            future: NotificationService()
                .getUnreadNotificationCount(_currentUserId ?? ''),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return InkWell(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('viewedProfileEmail');
                  await prefs.remove('viewedProfileUserId');
                  await prefs.remove('viewedProfileContribution');
                  if (mounted) {
                    Navigator.pushNamed(context, RoutsManager.profileScreen);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: userImageUrl != null &&
                                userImageUrl!.isNotEmpty
                            ? FileImage(File(userImageUrl!)) as ImageProvider
                            : AssetImage('assets/images/profile_img.png')
                                as ImageProvider,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Filter:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColorsManager.darkGrey,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'All'),
                        _buildFilterChip('Full-Time', 'Full-Time'),
                        _buildFilterChip('Part-Time', 'Part-Time'),
                        _buildFilterChip('Internship', 'Internship'),
                        _buildFilterChip('Remote', 'Remote'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: ColorsManager.darkGrey,
                    ),
                  )
                : filteredPosts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64,
                              color: ColorsManager.darkGrey.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No opportunities available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check back later or create one if you can',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUserDataAndOpportunities,
                        color: ColorsManager.darkGrey,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            return _buildOpportunityCard(filteredPosts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
