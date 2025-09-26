import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatelessWidget {
  final String profileImage = "assets/profile.jpg";
  final String name = "Menna Ibrahim";
  final String jobTitle = "Flutter Developer";
  final String postContent =
      "I've created a YouTube playlist to help you get started with Flutter, covering everything from the basics to advanced topics.\n";
  final String postLink =
      "https://www.youtube.com/playlist?list=PL4cUxeGkcC9JLYyp2Aoh6hcWuxFDX6PBJ";
  final String postEnd =
      "Perfect for students and developers looking to build mobile apps.";

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟡 معلومات المستخدم
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(profileImage),
                  radius: 24,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(jobTitle, style: TextStyle(color: Colors.white60)),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_horiz, color: Colors.white60), // ثلاث نقاط
              ],
            ),
            SizedBox(height: 10),

            // 🟡 نص البوست مع رابط قابل للنقر
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 14),
                children: [
                  TextSpan(text: postContent),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        if (await canLaunch(postLink)) {
                          await launch(postLink);
                        }
                      },
                      child: Text(
                        postLink,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  TextSpan(text: "\n$postEnd"),
                ],
              ),
            ),
            SizedBox(height: 10),

            // 🟡 أيقونات التفاعل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.white60, size: 18),
                    SizedBox(width: 4),
                    Text("10", style: TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.white60, size: 18),
                    SizedBox(width: 4),
                    Text("0", style: TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.share, color: Colors.white60, size: 18),
                    SizedBox(width: 4),
                    Text("0", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
