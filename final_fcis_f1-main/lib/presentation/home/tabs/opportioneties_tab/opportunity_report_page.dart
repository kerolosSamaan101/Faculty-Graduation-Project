import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FCIS_F1/presentation/profile/contribution_calculator.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/post_storage_service.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:FCIS_F1/core/utils/colors_manager.dart';
import 'package:FCIS_F1/core/utils/routes_manager.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/models.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/notification_service.dart';

class OpportunityReportPage extends StatefulWidget {
  final String opportunityCategory;

  const OpportunityReportPage({
    Key? key,
    required this.opportunityCategory,
  }) : super(key: key);

  @override
  _OpportunityReportPageState createState() => _OpportunityReportPageState();
}

class _OpportunityReportPageState extends State<OpportunityReportPage> {
  List<Map<String, dynamic>> _matchingCandidates = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final PostStorageService _postStorageService = PostStorageService();

  @override
  void initState() {
    super.initState();
    _loadMatchingCandidates();
  }

  Future<void> _loadMatchingCandidates() async {
    try {
      setState(() {
        _isLoading = true;
        _matchingCandidates = [];
      });

      final prefs = await SharedPreferences.getInstance();

      // Clear any previous profile view data
      await prefs.remove('viewedProfileEmail');
      await prefs.remove('viewedProfileUserId');
      await prefs.remove('viewedProfileContribution');

      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      final currentUserEmail = prefs.getString('currentUserEmail');
      final category = widget.opportunityCategory.toLowerCase();

      List<Map<String, dynamic>> candidates = [];

      for (var email in registeredUsers) {
        if (email == currentUserEmail) continue;

        final userKey = 'user_$email';

        // 1. Check status
        final status = prefs.getString('$userKey.status') ?? 'Student';
        if (status != 'Student' && status != 'Graduate') continue;

        // 2. Check interests (with better matching)
        final interests = prefs.getStringList('$userKey.interests') ?? [];
        final hasInterest = interests.any((interest) =>
            interest.toLowerCase() == category ||
            (category == 'other' && interest.toLowerCase() == 'other'));

        if (!hasInterest) continue;

        // 3. Load ALL user data regardless of profile completeness
        final candidate = {
          'email': email,
          'name':
              prefs.getString('$userKey.fullName') ?? email.split('@').first,
          'image': prefs.getString('$userKey.profileImagePath'),
          'status': status,
          'userId': prefs.getString('$userKey.userId') ?? email,
          // Force contribution to 0 initially
          'contribution': 0.0,
          // Include all profile data fields
          'hasProfileData': _hasProfileContent(prefs, userKey),
        };

        // 4. Calculate contribution separately
        try {
          candidate['contribution'] =
              await ContributionCalculator.calculateUserContribution(
            candidate['userId'] as String,
            _postStorageService,
          ).timeout(Duration(seconds: 3), onTimeout: () => 0.0);
        } catch (e) {
          debugPrint(
              'Error calculating contribution for ${candidate['email']}: $e');
        }

        candidates.add(candidate);
      }

      // Sort by contribution
      candidates.sort((a, b) => b['contribution'].compareTo(a['contribution']));

      setState(() {
        _matchingCandidates = candidates;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in _loadMatchingCandidates: $e');
      setState(() {
        _isLoading = false;
        _matchingCandidates = [];
      });
    }
  }

  bool _hasProfileContent(SharedPreferences prefs, String userKey) {
    return (prefs.getStringList('$userKey.courses')?.isNotEmpty ?? false) ||
        (prefs.getStringList('$userKey.certifications')?.isNotEmpty ?? false) ||
        (prefs.getStringList('$userKey.volunteering')?.isNotEmpty ?? false) ||
        (prefs.getStringList('$userKey.projects')?.isNotEmpty ?? false);
  }

  void _showNoCandidatesMessage(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = message;
        _matchingCandidates = [];
      });
    }
  }

  Future<void> _calculateAndAddContribution(
      Map<String, dynamic> candidate) async {
    try {
      final contribution =
          await ContributionCalculator.calculateUserContribution(
        candidate['email'],
        _postStorageService,
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint(
            'Contribution calculation timed out for ${candidate['email']}');
        return 0.0;
      });
      candidate['contribution'] = contribution;
    } catch (e) {
      debugPrint(
          'Error calculating contribution for ${candidate['email']}: $e');
      candidate['contribution'] = 0.0;
    }
  }

  void _viewCandidateProfile(Map<String, dynamic> candidate) async {
    final prefs = await SharedPreferences.getInstance();

    // Store all candidate data including contribution rate
    await prefs.setString('viewedProfileEmail', candidate['email']);
    await prefs.setString('viewedProfileUserId', candidate['userId']);
    await prefs.setDouble(
        'viewedProfileContribution', candidate['contribution']);

    Navigator.pushNamed(context, RoutsManager.profileScreen);
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      appBar: AppBar(
        title: Text(
          'Matching Candidates for ${widget.opportunityCategory}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorsManager.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: ColorsManager.darkGrey))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: TextStyle(color: ColorsManager.darkGrey)))
              : _matchingCandidates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: ColorsManager.darkGrey),
                          SizedBox(height: 16),
                          Text(
                            'No matching candidates found',
                            style: TextStyle(
                                color: ColorsManager.darkGrey, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No students/graduates have ${widget.opportunityCategory} in their interests',
                            style: TextStyle(
                                color: ColorsManager.darkGrey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMatchingCandidates,
                      color: ColorsManager.darkGrey,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: _matchingCandidates.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final candidate = _matchingCandidates[index];
                          return _buildCandidateCard(candidate);
                        },
                      ),
                    ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ColorsManager.darkGrey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _viewCandidateProfile(candidate),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: candidate['image'] != null
                        ? FileImage(File(candidate['image']))
                        : AssetImage('assets/images/profile_img.png')
                            as ImageProvider,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.darkGrey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${candidate['status']} • ${candidate['contribution'].toStringAsFixed(1)} Contribution',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (candidate['university'] != null &&
                          candidate['university'].isNotEmpty)
                        Text(
                          candidate['university'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: (candidate['contribution'] / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorsManager.darkGrey,
              ),
            ),
            SizedBox(height: 12),
            if (candidate['skills'] != null &&
                candidate['skills'].isNotEmpty) ...[
              Text(
                'Skills:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.darkGrey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                candidate['skills'],
                style: TextStyle(
                  color: ColorsManager.darkGrey,
                ),
              ),
              SizedBox(height: 8),
            ],
            if (candidate['linkedIn'] != null &&
                candidate['linkedIn'].isNotEmpty) ...[
              InkWell(
                onTap: () => _launchUrl(candidate['linkedIn'].startsWith('http')
                    ? candidate['linkedIn']
                    : 'https://${candidate['linkedIn']}'),
                child: Text(
                  'LinkedIn: ${candidate['linkedIn']}',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            if (candidate['phone'] != null &&
                candidate['phone'].isNotEmpty) ...[
              Text(
                'Phone: ${candidate['phone']}',
                style: TextStyle(
                  color: ColorsManager.darkGrey,
                ),
              ),
            ],
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _viewCandidateProfile(candidate),
                child: Text(
                  'View Full Profile',
                  style: TextStyle(
                    color: ColorsManager.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
