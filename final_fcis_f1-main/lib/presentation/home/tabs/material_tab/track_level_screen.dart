import 'package:flutter/material.dart';

import '../../../../core/utils/colors_manager.dart';

class TrackLevelScreen extends StatelessWidget {
  final String trackName;
  final String levelName;
  final Map<String, String> courses;

  const TrackLevelScreen({
    required this.trackName,
    required this.levelName,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trackName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text(levelName,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]))
          ],
        ),
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorsManager.backGroundColor,
                  ColorsManager.darkGrey.withOpacity(0.1)
                ]
            )
        ),
        child: ListView.separated(
          physics: BouncingScrollPhysics(),
          itemCount: courses.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) {
            final courseName = courses.keys.elementAt(index);
            final courseUrl = courses.values.elementAt(index);

            return _CourseCard(
              title: courseName,
              url: courseUrl,
              icon: _getTrackIcon(trackName),
            );
          },
        ),
      ),
    );
  }

  IconData _getTrackIcon(String trackName) {
    switch(trackName) {
      case 'AI & Machine Learning':
        return Icons.smart_toy;
      case 'Web Development':
        return Icons.code;
      default:
        return Icons.computer;
    }
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String url;
  final IconData icon;

  const _CourseCard({required this.title, required this.url, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _launchURL(context, url),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: ColorsManager.backGroundColor   ,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(icon, size: 28, color: ColorsManager.backGroundColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(url,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[400])
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    // Existing launch logic
  }
}