import 'dart:io';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/text_formatting_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/colors_manager.dart';
import '../../../../core/utils/routes_manager.dart';
import '../../../../presentation/home/tabs/material_posts_tab/components/models.dart';
import '../../../../presentation/home/tabs/material_posts_tab/components/post_storage_service.dart';
import 'dart:async'; // For TimeoutException
import '../../../../presentation/home/tabs/material_posts_tab/components/notification_service.dart';
import '../../../../presentation/home/tabs/material_posts_tab/components/translation_service.dart';

class MaterialPostScreen extends StatefulWidget {
  @override
  _MaterialPostScreenState createState() => _MaterialPostScreenState();
}

class _MaterialPostScreenState extends State<MaterialPostScreen> {
  final TranslationService _translationService = TranslationService();
  final TextEditingController _postController = TextEditingController();
  final PostStorageService _postStorage = PostStorageService();
  final Uuid _uuid = Uuid();
  final Dio dio = Dio();
  final NotificationService _notificationService = NotificationService();
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserImage;
  String? _currentUserStatus;
  List<String> _userInterests = [];
  List<Post> posts = [];
  Map<String, bool> isExpanded = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndPosts();
  }

  Future<void> _loadUserDataAndPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('userId');
        _currentUserName = prefs.getString('userName') ?? 'Anonymous';
        _currentUserImage = prefs.getString('userImage');
        _currentUserStatus = prefs.getString('userStatus') ?? 'Student';
        _userInterests = prefs.getStringList('userInterests') ?? [];
        _isLoading = true;
      });

      final loadedPosts =
          await _postStorage.getAllPostsSorted(PostType.material);
      _filterPostsByRules(loadedPosts);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts: $e')),
      );
    }
  }

  void _filterPostsByRules(List<Post> loadedPosts) {
    final filteredPosts = loadedPosts.where((post) {
      // Only filter by interest matching
      return post.category != null &&
          (_userInterests.contains(post.category) ||
              (post.category == 'Other' && _userInterests.contains('Other')));
    }).toList();

    setState(() {
      posts = filteredPosts;
      for (var post in posts) {
        isExpanded[post.id] = false;
      }
      _isLoading = false;
    });
  }

  Future<int> predictText(String text) async {
    final translatedText =
        await _translationService.translateCodeMixedText(text);
    try {
      final response = await dio.post(
        "http://192.168.1.17:5000/predict",
        data: {"text": translatedText}, // Use translated text for prediction
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.data['prediction'];
    } catch (e) {
      print("Prediction error: $e");
      throw Exception("Failed to check for hate speech");
    }
  }

  Future<String> predictTopic(String text) async {
    final translatedText =
        await _translationService.translateCodeMixedText(text);
    final String url = "http://192.168.1.17:5001/predict";
    try {
      final response = await dio.post(
        url,
        data: {"text": translatedText}, // Use translated text for prediction
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final prediction = response.data['prediction'];
        switch (prediction) {
          case 0:
            return "Game Development";
          case 1:
            return "Cyber Security";
          case 2:
            return "Software Testing";
          case 3:
            return "Flutter";
          case 4:
            return "ML & DL";
          default:
            return "Other";
        }
      }
      return "Other";
    } catch (e) {
      print("Topic prediction error: $e");
      return "Other";
    }
  }

  void _showHateSpeechDialog(String text,
      {bool isComment = false, String? postId}) {
    final editController = TextEditingController(text: text);
    bool isChecking = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text("Content Review"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Our system detected potentially harmful language in your ${isComment ? 'comment' : 'post'}."),
            SizedBox(height: 10),
            Text("Please review and edit your content before posting:"),
            SizedBox(height: 15),
            TextField(
              controller: editController,
              maxLines: 3,
              textDirection:
                  TextFormattingUtils.containsArabic(editController.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
              onChanged: (text) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Edit your ${isComment ? 'comment' : 'post'}...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            if (isChecking) Center(child: CircularProgressIndicator()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: isChecking
                ? null
                : () async {
                    final editedText = editController.text.trim();
                    if (editedText.isEmpty) return;

                    setState(() => isChecking = true);

                    try {
                      final prediction = await predictText(editedText).timeout(
                          const Duration(seconds: 10),
                          onTimeout: () => -1);

                      if (prediction == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Verification timed out")),
                        );
                        return;
                      }

                      if (prediction == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Content still contains issues")),
                        );
                        setState(() => isChecking = false);
                        return;
                      }

                      Navigator.pop(context);
                      if (isComment && postId != null) {
                        await _postStorage.addCommentToPost(
                          postId: postId,
                          comment: Comment(
                            id: _uuid.v4(),
                            text: editedText,
                            userId: _currentUserId!,
                            userName: _currentUserName!,
                            userImage: _currentUserImage,
                            timestamp: DateTime.now(),
                          ),
                          type: PostType.material,
                        );
                        _loadUserDataAndPosts();
                      } else {
                        final category = await predictTopic(editedText).timeout(
                            const Duration(seconds: 5),
                            onTimeout: () => "Other");

                        final newPost = Post(
                          id: _uuid.v4(),
                          content: editedText,
                          userId: _currentUserId!,
                          userName: _currentUserName!,
                          userImage: _currentUserImage,
                          userStatus: _currentUserStatus,
                          timestamp: DateTime.now(),
                          type: PostType.material,
                          category: category,
                        );

                        await _postStorage.addPost(
                            post: newPost, type: PostType.material);
                        _postController.clear();
                        _loadUserDataAndPosts();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error verifying content")),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text("RE-CHECK AND POST"),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost(String text, {bool isRetry = false}) async {
    if (_currentUserId == null || text.isEmpty || !mounted) return;

    final loadingSnackBar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Checking content for inappropriate language...'),
          ],
        ),
        duration: Duration(minutes: 1),
      ),
    );

    try {
      int prediction;
      try {
        prediction = await predictText(text)
            .timeout(const Duration(seconds: 10), onTimeout: () => -1);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Couldn't verify content. Please be respectful.")),
        );
        prediction = 0;
      }

      if (prediction == -1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Content check timed out. Please try again.")),
        );
        return;
      }

      if (prediction == 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showHateSpeechDialog(text);
        return;
      }

      String category;
      try {
        category = await predictTopic(text)
            .timeout(const Duration(seconds: 5), onTimeout: () => "Other");
      } catch (e) {
        category = "Other";
      }

      final newPost = Post(
        id: _uuid.v4(),
        content: text,
        userId: _currentUserId!,
        userName: _currentUserName!,
        userImage: _currentUserImage,
        userStatus: _currentUserStatus,
        timestamp: DateTime.now(),
        type: PostType.material,
        category: category,
      );

      await _postStorage.addPost(post: newPost, type: PostType.material);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _postController.clear();
      _loadUserDataAndPosts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create post. Please try again.")),
      );
    }
  }

  void _addComment(String postId) {
    final commentController = TextEditingController();
    bool isPosting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: ColorsManager.backGroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add a Comment",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed:
                              isPosting ? null : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      textDirection: TextFormattingUtils.containsArabic(
                              commentController.text)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      onChanged: (text) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Write your comment...",
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isPosting
                          ? null
                          : () async {
                              final text = commentController.text.trim();
                              if (text.isEmpty) return;

                              setState(() => isPosting = true);

                              try {
                                int prediction;
                                try {
                                  prediction = await predictText(text).timeout(
                                      const Duration(seconds: 10),
                                      onTimeout: () => -1);
                                } catch (e) {
                                  prediction = 0;
                                }

                                if (prediction == -1) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Content check timed out. Please try again.")),
                                  );
                                  return;
                                }

                                if (prediction == 1) {
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  _showHateSpeechDialog(text,
                                      isComment: true, postId: postId);
                                  return;
                                }

                                await _postStorage.addCommentToPost(
                                  postId: postId,
                                  comment: Comment(
                                    id: _uuid.v4(),
                                    text: text,
                                    userId: _currentUserId!,
                                    userName: _currentUserName!,
                                    userImage: _currentUserImage,
                                    timestamp: DateTime.now(),
                                  ),
                                  type: PostType.material,
                                );

                                if (!mounted) return;
                                _loadUserDataAndPosts();
                                Navigator.pop(context);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Failed to post comment")),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => isPosting = false);
                                }
                              }
                            },
                      child: isPosting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Post Comment"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleLike(Post post, Comment? comment, bool isLike) async {
    if (_currentUserId == null) return;

    await _postStorage.toggleReaction(
      postId: post.id,
      userId: _currentUserId!,
      isLike: isLike,
      comment: comment,
      type: PostType.material,
    );
    _loadUserDataAndPosts();
  }

  List<InlineSpan> _parseTextWithLinks(String text) {
    return TextFormattingUtils.parseTextWithLinks(
      text,
      baseStyle: TextStyle(color: Colors.white),
      linkStyle: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildComment(Post post, Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: comment.userImage != null
                  ? FileImage(File(comment.userImage!)) as ImageProvider
                  : AssetImage("assets/images/profile_img.png"),
              radius: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.userName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  TextFormattingUtils.buildMixedDirectionText(
                    comment.text,
                    style: TextStyle(color: Colors.black),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up,
                            color: comment.likedBy.contains(_currentUserId)
                                ? Colors.blue
                                : ColorsManager.darkGrey,
                            size: 20),
                        onPressed: () => _toggleLike(post, comment, true),
                      ),
                      Text("${comment.likedBy.length}",
                          style: TextStyle(color: ColorsManager.darkGrey)),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.thumb_down,
                            color: comment.dislikedBy.contains(_currentUserId)
                                ? Colors.red
                                : ColorsManager.darkGrey,
                            size: 20),
                        onPressed: () => _toggleLike(post, comment, false),
                      ),
                      Text("${comment.dislikedBy.length}",
                          style: TextStyle(color: ColorsManager.darkGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      color: ColorsManager.darkGrey,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                width: 185,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(10),
                  ),
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: post.userImage != null &&
                              post.userImage!.isNotEmpty
                          ? FileImage(File(post.userImage!)) as ImageProvider
                          : AssetImage("assets/images/profile_img.png")
                              as ImageProvider,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.userName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text(
                            post.jobTitle ?? post.userStatus ?? "User",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.comment,
                              size: 20, color: Colors.white70),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () => _addComment(post.id),
                        ),
                        Text("${post.comments.length}",
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                    SizedBox(width: 4),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up,
                              size: 20,
                              color: post.likedBy.contains(_currentUserId)
                                  ? Colors.blue
                                  : Colors.white70),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () => _toggleLike(post, null, true),
                        ),
                        Text("${post.likedBy.length}",
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                    SizedBox(width: 4),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_down,
                              size: 20,
                              color: post.dislikedBy.contains(_currentUserId)
                                  ? Colors.red
                                  : Colors.white70),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () => _toggleLike(post, null, false),
                        ),
                        Text("${post.dislikedBy.length}",
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormattingUtils.buildMixedDirectionText(
              post.content,
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (post.category != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Chip(
                label: Text(
                  post.category!,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ],
          if (post.comments.isNotEmpty) ...[
            Divider(color: Colors.white54),
            _buildComment(post, post.comments.last),
            if (post.comments.length > 1) ...[
              IconButton(
                icon: Icon(
                  isExpanded[post.id] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded[post.id] = !(isExpanded[post.id] ?? false);
                  });
                },
              ),
              if (isExpanded[post.id] ?? false)
                ...post.comments
                    .sublist(0, post.comments.length - 1)
                    .map((comment) => _buildComment(post, comment))
                    .toList(),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Chip(
        label:
            Text(label, style: TextStyle(color: ColorsManager.backGroundColor)),
        backgroundColor: ColorsManager.darkGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add New Post",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _postController,
                maxLines: 5,
                textDirection:
                    TextFormattingUtils.containsArabic(_postController.text)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                onChanged: (text) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Write something...",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String text = _postController.text.trim();
                  if (text.isEmpty) return;
                  try {
                    int prediction = await predictText(text);
                    if (prediction == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Content contains hate speech")),
                      );
                      return;
                    }
                    await _createPost(text);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to create post")),
                    );
                  }
                },
                child: Text("Post"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backGroundColor,
        title: Text("Material Posts",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // Add Post Button
          Container(
            decoration: BoxDecoration(
              color: ColorsManager.darkGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.add,
                  color: ColorsManager.backGroundColor, size: 28),
              onPressed: _showPostDialog,
            ),
          ),
          SizedBox(width: 10),

          // Profile Avatar with fallback
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              // Clear any viewed profile data before navigating
              await prefs.remove('viewedProfileEmail');
              await prefs.remove('viewedProfileUserId');
              await prefs.remove('viewedProfileContribution');
              if (mounted) {
                Navigator.pushNamed(context, RoutsManager.profileScreen);
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage:
                  _currentUserImage != null && _currentUserImage!.isNotEmpty
                      ? FileImage(File(_currentUserImage!)) as ImageProvider
                      : AssetImage("assets/images/profile_img.png")
                          as ImageProvider,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 14),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: ColorsManager.darkGrey))
                : posts.isEmpty
                    ? Center(
                        child: Text(
                          "No posts yet. Be the first to share!",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUserDataAndPosts,
                        color: ColorsManager.darkGrey,
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 20),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return _buildPostCard(posts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
