import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/post_storage_service.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/models.dart';
import 'package:flutter/material.dart';

class ContributionCalculator {
  static Future<double> calculateUserContribution(
      String userId, PostStorageService postStorage) async {
    try {
      // Get all posts once and reuse
      final materialPosts = await postStorage.getAllPosts(PostType.material);
      final qnaPosts = await postStorage.getAllPosts(PostType.qna);

      // Calculate material posts (1 point each)
      final materialCount =
          materialPosts.where((post) => post.userId == userId).length;

      // Calculate Q&A contributions
      int commentCount = 0;
      int likeCount = 0;

      for (final post in qnaPosts) {
        final userComments =
            post.comments.where((comment) => comment.userId == userId);
        commentCount += userComments.length;
        likeCount += userComments.fold(
            0, (sum, comment) => sum + comment.likedBy.length);
      }

      return (materialCount * 1) + (commentCount * 0.75) + (likeCount * 0.25);
    } catch (e) {
      debugPrint('Error calculating contribution: $e');
      return 0.0;
    }
  }
}
