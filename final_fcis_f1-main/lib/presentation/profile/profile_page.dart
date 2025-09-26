import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/colors_manager.dart';
import '../../core/utils/routes_manager.dart';
import '../home/tabs/material_posts_tab/components/models.dart';
import '../home/tabs/material_posts_tab/components/post_storage_service.dart';
import 'contribution_calculator.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User Info
  String? fullName;
  String? email;
  String? university;
  String? college;
  String? academicYear;
  String? jobTitle;
  String? phoneNumber;
  String? linkedIn;
  String? location;
  String? bio;
  String? status;
  List<String>? interests;
  List<String>? skills;
  String? profileImagePath;
  String? _currentUserId;
  double? _viewedProfileContribution;

  // Contribution metrics
  double? contributionRate;
  int? materialPostsCount;
  int? qnaCommentsCount;
  int? commentLikesCount;
  bool _isLoadingMetrics = false;

  // Profile sections
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> certifications = [];
  List<Map<String, dynamic>> volunteering = [];
  List<Map<String, dynamic>> projects = [];

  // Form controllers
  final _bioController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _courseProviderController = TextEditingController();
  final _courseSkillsController = TextEditingController();
  final _certificationNameController = TextEditingController();
  final _certificationOrgController = TextEditingController();
  final _certificationSkillsController = TextEditingController();
  final _certificationLinkController = TextEditingController();
  final _volunteeringOrgController = TextEditingController();
  final _volunteeringRoleController = TextEditingController();
  final _volunteeringSkillsController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectRepoLinkController = TextEditingController();
  final _projectDemoLinkController = TextEditingController();
  final _projectSkillsController = TextEditingController();

  // UI state
  bool _isEditingBio = false;
  bool _isViewingOthersProfile = false;
  int _selectedTabIndex = 0;
  final _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _migrateOldData();
      await loadUserData();
    });
    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _bioController.dispose();
    _courseNameController.dispose();
    _courseProviderController.dispose();
    _courseSkillsController.dispose();
    _certificationNameController.dispose();
    _certificationOrgController.dispose();
    _certificationSkillsController.dispose();
    _certificationLinkController.dispose();
    _volunteeringOrgController.dispose();
    _volunteeringRoleController.dispose();
    _volunteeringSkillsController.dispose();
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectRepoLinkController.dispose();
    _projectDemoLinkController.dispose();
    _projectSkillsController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final viewedProfileEmail = prefs.getString('viewedProfileEmail');
      final viewedProfileUserId = prefs.getString('viewedProfileUserId');
      final currentUserEmail = prefs.getString('currentUserEmail');
      final currentUserStatus = prefs.getString('userStatus');

      _isViewingOthersProfile = viewedProfileEmail != null ||
          (viewedProfileUserId != null &&
              viewedProfileUserId != _currentUserId);

      if (currentUserStatus == 'Company Representative' &&
          _isViewingOthersProfile) {
        _isViewingOthersProfile = true; // Force view-only mode
      }
      _viewedProfileContribution = prefs.getDouble('viewedProfileContribution');

      String? profileEmailToLoad =
          _isViewingOthersProfile ? viewedProfileEmail : currentUserEmail;
      _currentUserId = _isViewingOthersProfile
          ? viewedProfileUserId ?? prefs.getString('userId')
          : prefs.getString('userId');

      if (profileEmailToLoad != null) {
        final userKey = 'user_$profileEmailToLoad';

        setState(() {
          // Handle all possible null cases and type mismatches
          fullName = prefs.getString('$userKey.fullName');
          email = profileEmailToLoad;
          university = prefs.getString('$userKey.university') ?? '';
          college = prefs.getString('$userKey.college') ?? '';
          academicYear = prefs.getString('$userKey.academicYear') ?? '';
          jobTitle = prefs.getString('$userKey.jobTitle') ?? '';
          phoneNumber = prefs.getString('$userKey.phoneNumber') ?? '';
          linkedIn = prefs.getString('$userKey.linkedIn') ?? '';
          location = prefs.getString('$userKey.location') ?? '';
          bio = prefs.getString('$userKey.bio') ?? '';
          status = prefs.getString('$userKey.status') ?? '';

          // Safely handle lists
          interests = _safeGetStringList(prefs, '$userKey.interests');
          skills = _safeGetStringList(prefs, '$userKey.skills');
          profileImagePath = prefs.getString('$userKey.profileImagePath');

          // Safely parse all sections
          courses = _safeParseListFromPrefs(prefs, '$userKey.courses');
          certifications =
              _safeParseListFromPrefs(prefs, '$userKey.certifications');
          volunteering =
              _safeParseListFromPrefs(prefs, '$userKey.volunteering');
          projects = _safeParseListFromPrefs(prefs, '$userKey.projects');
        });
        // Load contribution metrics after user data is loaded
        await _loadContributionMetrics();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        interests = [];
        skills = [];
        courses = [];
        certifications = [];
        volunteering = [];
        projects = [];
      });
    }
  }

  Future<void> _saveBio() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('currentUserEmail');
    if (currentUserEmail != null) {
      await prefs.setString('user_$currentUserEmail.bio', _bioController.text);
      setState(() {
        bio = _bioController.text;
        _isEditingBio = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  List<String> _safeGetStringList(SharedPreferences prefs, String key) {
    try {
      return prefs.getStringList(key) ?? [];
    } catch (e) {
      debugPrint('Error getting string list for key $key: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _safeParseListFromPrefs(
      SharedPreferences prefs, String key) {
    try {
      final list = prefs.getStringList(key);
      if (list == null) return [];

      return list.map((item) {
        try {
          final decoded = jsonDecode(item);
          return Map<String, dynamic>.from(decoded);
        } catch (e) {
          debugPrint('Error decoding item $item: $e');
          return <String, dynamic>{};
        }
      }).toList();
    } catch (e) {
      debugPrint('Error parsing list from prefs for key $key: $e');
      return [];
    }
  }

  Future<void> _migrateOldData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('currentUserEmail');

    if (currentUserEmail == null) return;

    final userKey = 'user_$currentUserEmail';

    try {
      // 1. Migrate old single string values to proper list format
      await _migrateStringToList(prefs, userKey, 'courses');
      await _migrateStringToList(prefs, userKey, 'certifications');
      await _migrateStringToList(prefs, userKey, 'volunteering');
      await _migrateStringToList(prefs, userKey, 'projects');

      // 2. Migrate old single string skills/interests to list format
      await _migrateStringToStringList(prefs, userKey, 'skills');
      await _migrateStringToStringList(prefs, userKey, 'interests');

      // 3. Clean up any deprecated keys
      await _cleanUpDeprecatedKeys(prefs, userKey);

      debugPrint('Data migration completed successfully');
    } catch (e) {
      debugPrint('Error during data migration: $e');
    }
  }

  Future<void> _migrateStringToList(
    SharedPreferences prefs,
    String userKey,
    String fieldKey,
  ) async {
    try {
      final dynamic oldValue = prefs.get('$userKey.$fieldKey');

      // If old value exists and is a String (not a List)
      if (oldValue != null && oldValue is String) {
        try {
          // Try to parse as JSON
          final parsed = jsonDecode(oldValue);
          if (parsed is List) {
            // If valid JSON array, save as proper string list
            await prefs.setStringList(
              '$userKey.$fieldKey',
              parsed.map((e) => jsonEncode(e)).toList(),
            );
          } else {
            // If single item, create new list with one item
            await prefs.setStringList(
              '$userKey.$fieldKey',
              [
                jsonEncode({'name': oldValue})
              ],
            );
          }
          await prefs.remove('$userKey.$fieldKey'); // Remove old key
        } catch (e) {
          // If JSON parsing fails, create default empty list
          await prefs.setStringList('$userKey.$fieldKey', []);
        }
      }
    } catch (e) {
      debugPrint('Error migrating $fieldKey: $e');
    }
  }

  Future<void> _migrateStringToStringList(
    SharedPreferences prefs,
    String userKey,
    String fieldKey,
  ) async {
    try {
      final dynamic oldValue = prefs.get('$userKey.$fieldKey');

      if (oldValue != null && oldValue is String) {
        // Convert comma-separated string to list
        final list = oldValue.split(',').map((e) => e.trim()).toList();
        await prefs.setStringList('$userKey.$fieldKey', list);
        await prefs.remove('$userKey.$fieldKey'); // Remove old key
      }
    } catch (e) {
      debugPrint('Error migrating $fieldKey: $e');
      await prefs.setStringList('$userKey.$fieldKey', []);
    }
  }

  Future<void> _cleanUpDeprecatedKeys(
    SharedPreferences prefs,
    String userKey,
  ) async {
    const deprecatedKeys = [
      'oldCourses',
      'oldCertifications',
      'oldVolunteering',
      'oldProjects',
      'tempSkills',
      'tempInterests'
    ];

    try {
      for (final key in deprecatedKeys) {
        if (prefs.containsKey('$userKey.$key')) {
          await prefs.remove('$userKey.$key');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning deprecated keys: $e');
    }
  }
// Add these methods to your _ProfilePageState class

  Future<int> _getUserMaterialPostsCount() async {
    if (_currentUserId == null) return 0;
    final postStorage = PostStorageService();
    final materialPosts = await postStorage.getAllPosts(PostType.material);
    return materialPosts.where((post) => post.userId == _currentUserId).length;
  }

  Future<int> _getUserQnACommentsCount() async {
    if (_currentUserId == null) return 0;
    final postStorage = PostStorageService();
    final qnaPosts = await postStorage.getAllPosts(PostType.qna);

    int commentCount = 0;
    for (final post in qnaPosts) {
      commentCount += post.comments
          .where((comment) => comment.userId == _currentUserId)
          .length;
    }
    return commentCount;
  }

  Future<int> _getUserCommentLikesCount() async {
    if (_currentUserId == null) return 0;
    final postStorage = PostStorageService();
    final qnaPosts = await postStorage.getAllPosts(PostType.qna);

    int likeCount = 0;
    for (final post in qnaPosts) {
      for (final comment in post.comments) {
        if (comment.userId == _currentUserId) {
          likeCount += comment.likedBy.length;
        }
      }
    }
    return likeCount;
  }

  Future<void> _loadContributionMetrics() async {
    if (_currentUserId == null) return;

    final postStorage = PostStorageService();

    setState(() {
      _isLoadingMetrics = true;
    });

    try {
      final materialCount = await _getUserMaterialPostsCount();
      final qnaCommentsCount = await _getUserQnACommentsCount();
      final commentLikesCount = await _getUserCommentLikesCount();
      final contribution = await _calculateContributionRate();

      setState(() {
        materialPostsCount = materialCount;
        this.qnaCommentsCount = qnaCommentsCount;
        this.commentLikesCount = commentLikesCount;
        contributionRate = contribution;
        _isLoadingMetrics = false;
      });
    } catch (e) {
      debugPrint('Error loading metrics: $e');
      setState(() => _isLoadingMetrics = false);
    }
  }

  Future<double> _calculateContributionRate() async {
    if (_viewedProfileContribution != null) {
      return _viewedProfileContribution!;
    }

    final postStorage = PostStorageService();
    return ContributionCalculator.calculateUserContribution(
        _currentUserId ?? '', postStorage);
  }

  List<Map<String, dynamic>> _parseListFromPrefs(
      SharedPreferences prefs, String key) {
    try {
      final list = prefs.getStringList(key) ?? [];
      return list.map((item) {
        try {
          return Map<String, dynamic>.from(jsonDecode(item));
        } catch (e) {
          debugPrint('Error parsing item: $e');
          return <String, dynamic>{};
        }
      }).toList();
    } catch (e) {
      debugPrint('Error reading from prefs: $e');
      return [];
    }
  }

  Future<void> _saveListToPrefs(
      String key, List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('currentUserEmail');
      if (currentUserEmail != null) {
        final stringList = items.map((item) => jsonEncode(item)).toList();
        await prefs.setStringList('user_$currentUserEmail.$key', stringList);
      }
    } catch (e) {
      debugPrint('Error saving list to prefs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data')),
      );
    }
  }

  Future<void> _saveSkills(List<String> skills) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('currentUserEmail');
      if (currentUserEmail != null) {
        await prefs.setStringList(
          'user_$currentUserEmail.skills',
          skills.where((skill) => skill.isNotEmpty).toList(),
        );
        setState(() => this.skills = skills);
      }
    } catch (e) {
      debugPrint('Error saving skills: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update skills')),
      );
    }
  }

  Future<void> pickImage() async {
    if (_isViewingOthersProfile) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUserEmail = prefs.getString('currentUserEmail');

      if (currentUserEmail != null) {
        await prefs.setString(
            'user_$currentUserEmail.profileImagePath', pickedFile.path);
        setState(() => profileImagePath = pickedFile.path);
      }
    }
  }

  Future<void> _addCourse() async {
    try {
      if (_courseNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course name is required')),
        );
        return;
      }

      final newSkills = _courseSkillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newCourse = {
        'name': _courseNameController.text,
        'provider': _courseProviderController.text,
        'skills': newSkills,
        'date': DateTime.now().toIso8601String(),
      };

      setState(() {
        courses = [...courses, newCourse];
        _clearCourseFields();
      });

      await _saveListToPrefs('courses', courses);

      if (newSkills.isNotEmpty) {
        await _saveSkills([...?skills, ...newSkills]);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course added successfully')),
      );
    } catch (e) {
      debugPrint('Error adding course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add course')),
      );
    }
  }

  void _clearCourseFields() {
    _courseNameController.clear();
    _courseProviderController.clear();
    _courseSkillsController.clear();
  }

  Future<void> _addCertification() async {
    try {
      if (_certificationNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Certification name is required')),
        );
        return;
      }

      final newSkills = _certificationSkillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newCert = {
        'name': _certificationNameController.text,
        'organization': _certificationOrgController.text,
        'link': _certificationLinkController.text,
        'skills': newSkills,
        'date': DateTime.now().toIso8601String(),
      };

      setState(() {
        certifications = [...certifications, newCert];
        _clearCertificationFields();
      });

      await _saveListToPrefs('certifications', certifications);

      if (newSkills.isNotEmpty) {
        await _saveSkills([...?skills, ...newSkills]);
      }
    } catch (e) {
      debugPrint('Error adding certification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add certification')),
      );
    }
  }

  void _clearCertificationFields() {
    _certificationNameController.clear();
    _certificationOrgController.clear();
    _certificationSkillsController.clear();
    _certificationLinkController.clear();
  }

  Future<void> _addVolunteering() async {
    try {
      if (_volunteeringOrgController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Organization name is required')),
        );
        return;
      }

      final newSkills = _volunteeringSkillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newVolunteering = {
        'organization': _volunteeringOrgController.text,
        'role': _volunteeringRoleController.text,
        'skills': newSkills,
        'date': DateTime.now().toIso8601String(),
      };

      setState(() {
        volunteering = [...volunteering, newVolunteering];
        _clearVolunteeringFields();
      });

      await _saveListToPrefs('volunteering', volunteering);

      if (newSkills.isNotEmpty) {
        await _saveSkills([...?skills, ...newSkills]);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Volunteering experience added successfully')),
      );
    } catch (e) {
      debugPrint('Error adding volunteering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add volunteering experience')),
      );
    }
  }

  void _clearVolunteeringFields() {
    _volunteeringOrgController.clear();
    _volunteeringRoleController.clear();
    _volunteeringSkillsController.clear();
  }

  Future<void> _addProject() async {
    try {
      if (_projectNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project name is required')),
        );
        return;
      }

      final newSkills = _projectSkillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newProject = {
        'name': _projectNameController.text,
        'description': _projectDescriptionController.text,
        'repoLink': _projectRepoLinkController.text,
        'demoLink': _projectDemoLinkController.text,
        'skills': newSkills,
        'date': DateTime.now().toIso8601String(),
      };

      setState(() {
        projects = [...projects, newProject];
        _clearProjectFields();
      });

      await _saveListToPrefs('projects', projects);

      if (newSkills.isNotEmpty) {
        await _saveSkills([...?skills, ...newSkills]);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project added successfully')),
      );
    } catch (e) {
      debugPrint('Error adding project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add project')),
      );
    }
  }

  void _clearProjectFields() {
    _projectNameController.clear();
    _projectDescriptionController.clear();
    _projectRepoLinkController.clear();
    _projectDemoLinkController.clear();
    _projectSkillsController.clear();
  }

  Future<void> _removeItem(String section, int index) async {
    setState(() {
      switch (section) {
        case 'courses':
          courses.removeAt(index);
          break;
        case 'certifications':
          certifications.removeAt(index);
          break;
        case 'volunteering':
          volunteering.removeAt(index);
          break;
        case 'projects':
          projects.removeAt(index);
          break;
      }
    });

    await _saveListToPrefs(
        section,
        section == 'courses'
            ? courses
            : section == 'certifications'
                ? certifications
                : section == 'volunteering'
                    ? volunteering
                    : projects);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserEmail');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userImage');
    await prefs.remove('jobTitle');
    await prefs.remove('userStatus');

    Navigator.of(context).pushNamedAndRemoveUntil(
      RoutsManager.loginScreen,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: TextStyle(color: ColorsManager.darkGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await logout();
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorsManager.darkGrey, ColorsManager.backGroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 6),
          GestureDetector(
            onTap: pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: ColorsManager.darkGrey.withOpacity(0.1),
                    backgroundImage: profileImagePath != null
                        ? FileImage(File(profileImagePath!))
                        : null,
                    child: profileImagePath == null
                        ? Icon(Icons.person, size: 50, color: Colors.white70)
                        : null,
                  ),
                ),
                if (!_isViewingOthersProfile)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsManager.backGroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit,
                        size: 20, color: ColorsManager.darkGrey),
                  ),
              ],
            ),
          ),
          SizedBox(height: 2),
          Text(
            fullName ?? 'Your Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (jobTitle != null && jobTitle!.isNotEmpty || status != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                jobTitle ?? status ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          SizedBox(height: 3),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Contribution Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  (_viewedProfileContribution ?? contributionRate)
                          ?.toStringAsFixed(1) ??
                      '0.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (materialPostsCount != null &&
                    qnaCommentsCount != null &&
                    commentLikesCount != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMetricChip(Icons.note_add, '${materialPostsCount}'),
                      _buildMetricChip(Icons.comment, '${qnaCommentsCount}'),
                      _buildMetricChip(Icons.thumb_up, '${commentLikesCount}'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    return Chip(
      elevation: 10,
      backgroundColor: Colors.white.withOpacity(0.1),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ColorsManager.darkGrey),
          SizedBox(width: 4),
          Text(text,
              style: TextStyle(color: ColorsManager.darkGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.darkGrey,
                        ),
                      ),
                      if (!_isViewingOthersProfile)
                        IconButton(
                          icon: Icon(_isEditingBio ? Icons.save : Icons.edit,
                              size: 22, color: ColorsManager.darkGrey),
                          onPressed: () {
                            if (_isEditingBio) {
                              _saveBio();
                            } else {
                              setState(() {
                                _isEditingBio = true;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (_isEditingBio)
                    TextField(
                      controller: _bioController,
                      focusNode: _focusNode,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tell others about yourself...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    )
                  else if (bio != null && bio!.isNotEmpty)
                    Text(
                      bio!,
                      style: TextStyle(fontSize: 16),
                    )
                  else
                    Text(
                      'No bio added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          _buildInfoCard(
            title: 'Education',
            icon: Icons.school,
            children: [
              _buildInfoRow(Icons.school, 'University', university),
              _buildInfoRow(Icons.account_balance, 'College', college),
              _buildInfoRow(
                  Icons.calendar_today, 'Academic Year', academicYear),
            ],
          ),
          _buildInfoCard(
            title: 'Contact',
            icon: Icons.contact_mail,
            children: [
              _buildInfoRow(Icons.email, 'Email', email),
              _buildInfoRow(Icons.phone, 'Phone', phoneNumber),
              _buildInfoRow(Icons.location_on, 'Location', location),
              if (linkedIn != null && linkedIn!.isNotEmpty)
                InkWell(
                  onTap: () => _launchURL(linkedIn!),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.link,
                            color: ColorsManager.darkGrey, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'LinkedIn Profile',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          _buildInfoCard(
            title: 'Interests',
            icon: Icons.interests,
            children: [
              if (interests != null && interests!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests!
                      .map((interest) => Chip(
                            label: Text(interest),
                            backgroundColor:
                                ColorsManager.darkGrey.withOpacity(0.1),
                            labelStyle:
                                TextStyle(color: ColorsManager.darkGrey),
                          ))
                      .toList(),
                )
              else
                Text('No interests added yet',
                    style: TextStyle(color: Colors.grey)),
            ],
          ),
          _buildInfoCard(
            title: 'Skills',
            icon: Icons.psychology,
            children: [
              if (skills != null && skills!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills!
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor:
                                ColorsManager.backGroundColor.withOpacity(0.1),
                            labelStyle:
                                TextStyle(color: ColorsManager.darkGrey),
                          ))
                      .toList(),
                )
              else
                Text('No skills added yet',
                    style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: ColorsManager.darkGrey),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.darkGrey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ColorsManager.darkGrey),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.darkGrey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value ?? 'Not provided',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                if (!_isViewingOthersProfile) _buildAddCourseForm(),
                if (courses.isEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No courses added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (courses.isNotEmpty)
                  ...courses
                      .asMap()
                      .entries
                      .map((entry) => _buildCourseCard(entry.value, entry.key))
                      .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCourseForm() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Add New Course',
            style: TextStyle(
                color: ColorsManager.darkGrey, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _courseNameController,
                  decoration: InputDecoration(
                    labelText: 'Course Name*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _courseProviderController,
                  decoration: InputDecoration(
                    labelText: 'Course Provider*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _courseSkillsController,
                  decoration: InputDecoration(
                    labelText: 'Skills Gained (comma separated)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.darkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: _addCourse,
                  child:
                      Text('Add Course', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                if (!_isViewingOthersProfile) _buildAddCertificationForm(),
                if (certifications.isEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No certifications added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (certifications.isNotEmpty)
                  ...certifications
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildCertificationCard(entry.value, entry.key))
                      .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCertificationForm() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Add New Certification',
            style: TextStyle(
                color: ColorsManager.darkGrey, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _certificationNameController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Certification Name*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _certificationOrgController,
                  decoration: InputDecoration(
                    labelText: 'Issuing Organization*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _certificationLinkController,
                  decoration: InputDecoration(
                    labelText: 'Certificate Link (Optional)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _certificationSkillsController,
                  decoration: InputDecoration(
                    labelText: 'Skills Gained (comma separated)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.darkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: _addCertification,
                  child: Text('Add Certification',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationCard(Map<String, dynamic> cert, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cert['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_isViewingOthersProfile)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem('certifications', index),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (cert['organization'] != null && cert['organization'].isNotEmpty)
              Text(
                'Organization: ${cert['organization']}',
                style: TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (cert['link'] != null && cert['link'].isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () => _launchURL(cert['link']),
                  child: Text(
                    'View Certificate',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 12),
            if (cert['skills'] != null && cert['skills'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills Gained:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (cert['skills'] as List)
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: ColorsManager.backGroundColor
                                  .withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteeringTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                if (!_isViewingOthersProfile) _buildAddVolunteeringForm(),
                if (volunteering.isEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volunteer_activism,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No volunteering experiences added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (volunteering.isNotEmpty)
                  ...volunteering
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildVolunteeringCard(entry.value, entry.key))
                      .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddVolunteeringForm() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Add Volunteering Experience',
            style: TextStyle(
                color: ColorsManager.darkGrey, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _volunteeringOrgController,
                  decoration: InputDecoration(
                    labelText: 'Organization*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _volunteeringRoleController,
                  decoration: InputDecoration(
                    labelText: 'Your Role*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _volunteeringSkillsController,
                  decoration: InputDecoration(
                    labelText: 'Skills Gained (comma separated)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.darkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: _addVolunteering,
                  child: Text('Add Volunteering',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                if (!_isViewingOthersProfile) _buildAddProjectForm(),
                if (projects.isEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.code, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No projects added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (projects.isNotEmpty)
                  ...projects
                      .asMap()
                      .entries
                      .map((entry) => _buildProjectCard(entry.value, entry.key))
                      .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddProjectForm() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Add New Project',
            style: TextStyle(
                color: ColorsManager.darkGrey, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _projectNameController,
                  decoration: InputDecoration(
                    labelText: 'Project Name*',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _projectDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _projectRepoLinkController,
                  decoration: InputDecoration(
                    labelText: 'Repository Link (Optional)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _projectDemoLinkController,
                  decoration: InputDecoration(
                    labelText: 'Demo Video Link (Optional)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _projectSkillsController,
                  decoration: InputDecoration(
                    labelText: 'Skills Used (comma separated)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.darkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: _addProject,
                  child: Text('Add Project',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16, top: 8, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isViewingOthersProfile)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem('courses', index),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (course['provider'] != null && course['provider'].isNotEmpty)
              Text(
                'Provider: ${course['provider']}',
                style: TextStyle(color: Colors.grey),
              ),
            SizedBox(height: 12),
            if (course['skills'] != null && course['skills'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills Gained:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (course['skills'] as List)
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: ColorsManager.backGroundColor
                                  .withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteeringCard(Map<String, dynamic> volunteer, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16, top: 8, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    volunteer['organization'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isViewingOthersProfile)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem('volunteering', index),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (volunteer['role'] != null && volunteer['role'].isNotEmpty)
              Text(
                'Role: ${volunteer['role']}',
                style: TextStyle(color: Colors.grey),
              ),
            SizedBox(height: 12),
            if (volunteer['skills'] != null && volunteer['skills'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills Gained:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (volunteer['skills'] as List)
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: ColorsManager.backGroundColor
                                  .withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16, top: 8, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isViewingOthersProfile)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem('projects', index),
                  ),
              ],
            ),
            SizedBox(height: 12),
            if (project['description'] != null &&
                project['description'].isNotEmpty)
              Text(
                project['description'],
                style: TextStyle(color: Colors.grey),
              ),
            SizedBox(height: 12),
            if ((project['repoLink'] != null &&
                    project['repoLink'].isNotEmpty) ||
                (project['demoLink'] != null && project['demoLink'].isNotEmpty))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Links:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (project['repoLink'] != null &&
                      project['repoLink'].isNotEmpty)
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Repository Link',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  if (project['demoLink'] != null &&
                      project['demoLink'].isNotEmpty)
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Demo Video',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 12),
            if (project['skills'] != null && project['skills'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills Used:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (project['skills'] as List)
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: ColorsManager.backGroundColor
                                  .withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  physics: ClampingScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 300,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildProfileHeader(),
                        ),
                        pinned: true,
                        floating: true,
                        forceElevated: innerBoxIsScrolled,
                      ),
                    ];
                  },
                  body: Column(
                    children: [
                      // Fixed TabBar that stays visible
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          labelColor: ColorsManager.darkGrey,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: ColorsManager.darkGrey,
                          isScrollable: true,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(icon: Icon(Icons.person)),
                            Tab(icon: Icon(Icons.school)),
                            Tab(icon: Icon(Icons.verified)),
                            Tab(icon: Icon(Icons.volunteer_activism)),
                            Tab(icon: Icon(Icons.code)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildBasicInfoTab(),
                            _buildCoursesTab(),
                            _buildCertificationsTab(),
                            _buildVolunteeringTab(),
                            _buildProjectsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
