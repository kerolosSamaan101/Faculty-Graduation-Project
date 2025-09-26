import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'models.dart' as models;
import 'notification_service.dart';
import 'package:flutter/foundation.dart';

class PostStorageService {
  // Keys for storing all posts
  static const String _allMaterialPostsKey = 'all_material_posts';
  static const String _allQnaPostsKey = 'all_qna_posts';
  static const String _allOpportunityPostsKey = 'all_opportunity_posts';
  final Uuid _uuid = Uuid();
  final NotificationService _notificationService = NotificationService();

  // Get all posts of a specific type
  Future<List<models.Post>> getAllPosts(models.PostType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKeyForType(type);
    final postsJson = prefs.getStringList(key) ?? [];

    if (kDebugMode) {
      print('Loading ${type.toString()} posts from storage');
      print('Found ${postsJson.length} posts');
    }

    return postsJson
        .map((json) {
          try {
            return models.Post.fromMap(jsonDecode(json));
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing post: $e');
              print('Problematic JSON: $json');
            }
            return null;
          }
        })
        .whereType<models.Post>()
        .toList();
  }

  // Get all posts sorted by timestamp (newest first)
  Future<List<models.Post>> getAllPostsSorted(models.PostType type) async {
    final posts = await getAllPosts(type);
    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return posts;
  }

  // Add a new post with notification
  Future<void> addPost({
    required models.Post post,
    required models.PostType type,
  }) async {
    try {
      final posts = await getAllPosts(type);
      posts.insert(0, post);
      await _saveAllPosts(posts, type);

      if (kDebugMode) {
        print('Successfully added new ${type.toString()} post');
        print('Post ID: ${post.id}');
        print('Post Category: ${post.category}');
      }

      // Create notification for all post types
      if (post.userId != null) {
        final notification = await _notificationService.createPostNotification(
          postId: post.id,
          postType: type,
          userId: post.userId!,
          userName: post.userName,
          content: post.content,
          userImage: post.userImage,
          jobTitle: post.jobTitle,
          userStatus: post.userStatus,
          category: post.category,
        );

        if (kDebugMode) {
          print('Created notification for post ${post.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding post: $e');
      }
      rethrow;
    }
  }

  // Update an existing post
  Future<void> updatePost({
    required models.Post updatedPost,
    required models.PostType type,
  }) async {
    try {
      final posts = await getAllPosts(type);
      final index = posts.indexWhere((post) => post.id == updatedPost.id);

      if (index != -1) {
        posts[index] = updatedPost;
        await _saveAllPosts(posts, type);

        if (kDebugMode) {
          print('Successfully updated post ${updatedPost.id}');
        }
      } else {
        if (kDebugMode) {
          print('Post ${updatedPost.id} not found for update');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating post: $e');
      }
      rethrow;
    }
  }

  // Delete a post and its associated notifications
  Future<void> deletePost({
    required String postId,
    required models.PostType type,
  }) async {
    try {
      final posts = await getAllPosts(type);
      posts.removeWhere((post) => post.id == postId);
      await _saveAllPosts(posts, type);

      if (kDebugMode) {
        print('Successfully deleted post $postId');
      }

      // Remove all notifications for this post
      final postNotifications =
          await _notificationService.getNotificationsForPost(postId);

      if (kDebugMode) {
        print('Found ${postNotifications.length} notifications to remove');
      }

      for (final notification in postNotifications) {
        await _notificationService.removeNotification(notification.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting post: $e');
      }
      rethrow;
    }
  }

  // Get posts by a specific user
  Future<List<models.Post>> getUserPosts({
    required String userId,
    required models.PostType type,
  }) async {
    final allPosts = await getAllPosts(type);
    return allPosts.where((post) => post.userId == userId).toList();
  }

  // Add a comment to a post
  Future<void> addCommentToPost({
    required String postId,
    required models.Comment comment,
    required models.PostType type,
  }) async {
    try {
      final posts = await getAllPosts(type);
      final postIndex = posts.indexWhere((post) => post.id == postId);

      if (postIndex != -1) {
        final updatedPost = posts[postIndex].copyWith(
          comments: [...posts[postIndex].comments, comment],
        );
        posts[postIndex] = updatedPost;
        await _saveAllPosts(posts, type);

        if (kDebugMode) {
          print('Successfully added comment to post $postId');
        }

        // Create notification for Q&A comments only
        if (type == models.PostType.qna) {
          // Check if notification already exists for this comment
          final existingNotifications =
              await _notificationService.getNotificationsForPost(postId);

          final isDuplicate = existingNotifications.any((n) =>
              n.postPreview == comment.text &&
              n.userId == comment.userId &&
              n.timestamp.difference(comment.timestamp).inSeconds < 5);

          if (!isDuplicate) {
            final notification =
                await _notificationService.createPostNotification(
              postId: postId,
              postType: type,
              userId: comment.userId,
              userName: comment.userName,
              content: comment.text,
              userImage: comment.userImage,
              category: posts[postIndex].category,
            );
            await _notificationService.addNotification(notification);

            if (kDebugMode) {
              print('Created notification for comment on post $postId');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Post $postId not found for comment addition');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding comment: $e');
      }
      rethrow;
    }
  }

  // Toggle like/dislike on a post or comment
  Future<void> toggleReaction({
    required String postId,
    required String userId,
    required bool isLike,
    models.Comment? comment,
    required models.PostType type,
  }) async {
    try {
      final posts = await getAllPosts(type);
      final postIndex = posts.indexWhere((post) => post.id == postId);

      if (postIndex != -1) {
        final post = posts[postIndex];
        models.Post updatedPost;

        if (comment == null) {
          // Reacting to the post itself
          updatedPost = _updatePostReaction(post, userId, isLike);
        } else {
          // Reacting to a comment
          updatedPost = _updateCommentReaction(post, comment, userId, isLike);
        }

        posts[postIndex] = updatedPost;
        await _saveAllPosts(posts, type);

        if (kDebugMode) {
          print('Successfully toggled ${isLike ? 'like' : 'dislike'} '
              'on ${comment == null ? 'post' : 'comment'}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling reaction: $e');
      }
      rethrow;
    }
  }

  // Toggle solved status for Q&A posts
  Future<void> toggleSolvedStatus({
    required String postId,
    required String userId,
  }) async {
    try {
      final posts = await getAllPosts(models.PostType.qna);
      final postIndex = posts.indexWhere((post) => post.id == postId);

      if (postIndex != -1 && posts[postIndex].userId == userId) {
        final updatedPost = posts[postIndex].copyWith(
          isSolved: !posts[postIndex].isSolved,
        );
        posts[postIndex] = updatedPost;
        await _saveAllPosts(posts, models.PostType.qna);

        if (kDebugMode) {
          print('Toggled solved status for post $postId to '
              '${updatedPost.isSolved ? 'solved' : 'unsolved'}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling solved status: $e');
      }
      rethrow;
    }
  }

  // Clear all posts and notifications (for testing or first run)
  Future<void> clearAllPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_allMaterialPostsKey);
      await prefs.remove(_allQnaPostsKey);
      await prefs.remove(_allOpportunityPostsKey);
      await _notificationService.clearNotifications();

      if (kDebugMode) {
        print('Cleared all posts and notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all posts: $e');
      }
      rethrow;
    }
  }

  // Private helper methods
  String _getStorageKeyForType(models.PostType type) {
    switch (type) {
      case models.PostType.material:
        return _allMaterialPostsKey;
      case models.PostType.qna:
        return _allQnaPostsKey;
      case models.PostType.opportunity:
        return _allOpportunityPostsKey;
    }
  }

  Future<void> _saveAllPosts(
      List<models.Post> posts, models.PostType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKeyForType(type);
      final postsJson = posts.map((post) => jsonEncode(post.toMap())).toList();
      await prefs.setStringList(key, postsJson);

      if (kDebugMode) {
        print('Saved ${posts.length} ${type.toString()} posts to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving posts: $e');
      }
      rethrow;
    }
  }

  models.Post _updatePostReaction(
      models.Post post, String userId, bool isLike) {
    if (isLike) {
      // Handle like action
      final newLikedBy = List<String>.from(post.likedBy);
      final newDislikedBy = List<String>.from(post.dislikedBy);

      if (newLikedBy.contains(userId)) {
        newLikedBy.remove(userId); // Unlike if already liked
      } else {
        newLikedBy.add(userId); // Add like
        newDislikedBy.remove(userId); // Remove any existing dislike
      }

      return post.copyWith(
        likedBy: newLikedBy,
        dislikedBy: newDislikedBy,
      );
    } else {
      // Handle dislike action
      final newLikedBy = List<String>.from(post.likedBy);
      final newDislikedBy = List<String>.from(post.dislikedBy);

      if (newDislikedBy.contains(userId)) {
        newDislikedBy.remove(userId); // Remove dislike if already disliked
      } else {
        newDislikedBy.add(userId); // Add dislike
        newLikedBy.remove(userId); // Remove any existing like
      }

      return post.copyWith(
        likedBy: newLikedBy,
        dislikedBy: newDislikedBy,
      );
    }
  }

  models.Post _updateCommentReaction(
      models.Post post, models.Comment comment, String userId, bool isLike) {
    final commentIndex = post.comments.indexWhere((c) => c.id == comment.id);
    if (commentIndex == -1) return post;

    final newComments = List<models.Comment>.from(post.comments);
    final oldComment = newComments[commentIndex];

    models.Comment updatedComment;

    if (isLike) {
      // Handle like action
      final newLikedBy = List<String>.from(oldComment.likedBy);
      final newDislikedBy = List<String>.from(oldComment.dislikedBy);

      if (newLikedBy.contains(userId)) {
        newLikedBy.remove(userId); // Unlike if already liked
      } else {
        newLikedBy.add(userId); // Add like
        newDislikedBy.remove(userId); // Remove any existing dislike
      }

      updatedComment = oldComment.copyWith(
        likedBy: newLikedBy,
        dislikedBy: newDislikedBy,
      );
    } else {
      // Handle dislike action
      final newLikedBy = List<String>.from(oldComment.likedBy);
      final newDislikedBy = List<String>.from(oldComment.dislikedBy);

      if (newDislikedBy.contains(userId)) {
        newDislikedBy.remove(userId); // Remove dislike if already disliked
      } else {
        newDislikedBy.add(userId); // Add dislike
        newLikedBy.remove(userId); // Remove any existing like
      }

      updatedComment = oldComment.copyWith(
        likedBy: newLikedBy,
        dislikedBy: newDislikedBy,
      );
    }

    newComments[commentIndex] = updatedComment;
    return post.copyWith(comments: newComments);
  }
}
