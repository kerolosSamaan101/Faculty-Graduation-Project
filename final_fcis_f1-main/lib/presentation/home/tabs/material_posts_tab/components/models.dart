import 'package:flutter/material.dart';

enum PostType {
  material, // For Material Posts tab
  qna, // For Q&A tab
  opportunity // For Opportunities tab
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.material:
        return 'Material Post';
      case PostType.qna:
        return 'Q&A Post';
      case PostType.opportunity:
        return 'Opportunity Post';
    }
  }

  bool get canMarkAsSolved => this == PostType.qna;
}

const List<String> opportunityCategories = [
  'Software Testing',
  'Flutter',
  'Cyber Security',
  'ML & DL',
  'Game Development',
  'Other'
];

const List<String> interestOptions = [
  'Software Testing',
  'Flutter',
  'Cyber Security',
  'ML & DL',
  'Game Development',
  'Other'
];

class Post {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final String? userImage;
  final String? jobTitle;
  final String? userStatus;
  final DateTime timestamp;
  bool isSolved;
  final List<String> likedBy;
  final List<String> dislikedBy;
  final List<Comment> comments;
  final PostType type;

  // Opportunity-specific fields
  final String? companyName;
  final String? website;
  final String? contactEmail;
  final String? description;
  final String? skills;
  final String? qualifications;
  final String? location;
  final String? salary;
  final String? jobType;
  final String? category;

  Post({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    this.userImage,
    this.jobTitle,
    this.userStatus,
    required this.timestamp,
    this.isSolved = false,
    List<String>? likedBy,
    List<String>? dislikedBy,
    List<Comment>? comments,
    this.type = PostType.material,
    // Opportunity fields
    this.companyName,
    this.website,
    this.contactEmail,
    this.description,
    this.skills,
    this.qualifications,
    this.location,
    this.salary,
    this.jobType,
    this.category,
  })  : likedBy = likedBy ?? [],
        dislikedBy = dislikedBy ?? [],
        comments = comments ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'jobTitle': jobTitle,
      'userStatus': userStatus,
      'timestamp': timestamp.toIso8601String(),
      'isSolved': isSolved,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'type': type.toString().split('.').last,
      // Opportunity fields
      'companyName': companyName,
      'website': website,
      'contactEmail': contactEmail,
      'description': description,
      'skills': skills,
      'qualifications': qualifications,
      'location': location,
      'salary': salary,
      'jobType': jobType,
      'category': category,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      jobTitle: map['jobTitle'],
      userStatus: map['userStatus'],
      timestamp: DateTime.parse(map['timestamp']),
      isSolved: map['isSolved'] ?? false,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      dislikedBy: List<String>.from(map['dislikedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((commentMap) => Comment.fromMap(commentMap))
          .toList(),
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PostType.material,
      ),
      // Opportunity fields
      companyName: map['companyName'],
      website: map['website'],
      contactEmail: map['contactEmail'],
      description: map['description'],
      skills: map['skills'],
      qualifications: map['qualifications'],
      location: map['location'],
      salary: map['salary'],
      jobType: map['jobType'],
      category: map['category'],
    );
  }

  bool get isQuestionSolved => type == PostType.qna && isSolved;

  Post copyWith({
    String? id,
    String? content,
    String? userId,
    String? userName,
    String? userImage,
    String? jobTitle,
    String? userStatus,
    DateTime? timestamp,
    bool? isSolved,
    List<String>? likedBy,
    List<String>? dislikedBy,
    List<Comment>? comments,
    PostType? type,
    // Opportunity fields
    String? companyName,
    String? website,
    String? contactEmail,
    String? description,
    String? skills,
    String? qualifications,
    String? location,
    String? salary,
    String? jobType,
    String? category,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      jobTitle: jobTitle ?? this.jobTitle,
      userStatus: userStatus ?? this.userStatus,
      timestamp: timestamp ?? this.timestamp,
      isSolved: isSolved ?? this.isSolved,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
      comments: comments ?? this.comments,
      type: type ?? this.type,
      // Opportunity fields
      companyName: companyName ?? this.companyName,
      website: website ?? this.website,
      contactEmail: contactEmail ?? this.contactEmail,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      qualifications: qualifications ?? this.qualifications,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
    );
  }
}

class Comment {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final String? userImage;
  final DateTime timestamp;
  final List<String> likedBy;
  final List<String> dislikedBy;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.timestamp,
    List<String>? likedBy,
    List<String>? dislikedBy,
  })  : likedBy = likedBy ?? [],
        dislikedBy = dislikedBy ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'timestamp': timestamp.toIso8601String(),
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      timestamp: DateTime.parse(map['timestamp']),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      dislikedBy: List<String>.from(map['dislikedBy'] ?? []),
    );
  }

  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isDislikedBy(String userId) => dislikedBy.contains(userId);

  Comment copyWith({
    String? id,
    String? text,
    String? userId,
    String? userName,
    String? userImage,
    DateTime? timestamp,
    List<String>? likedBy,
    List<String>? dislikedBy,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      timestamp: timestamp ?? this.timestamp,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
    );
  }
}

class Notification {
  final String id;
  final String postId;
  final PostType postType;
  final String userId;
  final String userName;
  final String? userImage;
  final String? jobTitle;
  final String? userStatus;
  final String postPreview;
  final DateTime timestamp;
  bool isRead;
  final String? category;
  final String? notificationType; // Add this field

  Notification({
    required this.id,
    required this.postId,
    required this.postType,
    required this.userId,
    required this.userName,
    this.userImage,
    this.jobTitle,
    this.userStatus,
    required this.postPreview,
    required this.timestamp,
    this.isRead = false,
    this.category,
    this.notificationType,
  });

  // Update the toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'postType': postType.toString().split('.').last,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'jobTitle': jobTitle,
      'userStatus': userStatus,
      'postPreview': postPreview,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'category': category,
      'notificationType': notificationType, // Add this
    };
  }

  // Update the fromMap factory
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      postType: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == map['postType'],
        orElse: () => PostType.material,
      ),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      jobTitle: map['jobTitle'],
      userStatus: map['userStatus'],
      postPreview: map['postPreview'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      category: map['category'],
      notificationType: map['notificationType'], // Add this
    );
  }

  // Update copyWith
  Notification copyWith({
    String? id,
    String? postId,
    PostType? postType,
    String? userId,
    String? userName,
    String? userImage,
    String? jobTitle,
    String? userStatus,
    String? postPreview,
    DateTime? timestamp,
    bool? isRead,
    String? category,
    String? notificationType, // Add this
  }) {
    return Notification(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      postType: postType ?? this.postType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      jobTitle: jobTitle ?? this.jobTitle,
      userStatus: userStatus ?? this.userStatus,
      postPreview: postPreview ?? this.postPreview,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      category: category ?? this.category,
      notificationType: notificationType ?? this.notificationType, // Add this
    );
  }
}
