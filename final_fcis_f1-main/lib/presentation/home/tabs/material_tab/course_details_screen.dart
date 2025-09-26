import 'package:FCIS_F1/core/utils/colors_manager.dart';
import 'package:flutter/material.dart';

import '../../../../data/courses_data.dart';
import 'content_list_screen.dart';

class CourseDetailsPage extends StatelessWidget {
  final Course course;

  CourseDetailsPage({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        course.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      )),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentListPage(
                        title: "Lectures",
                        content: course.lectures,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: ColorsManager.darkGrey,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                      child: Text(
                    "Lectures",
                    style: TextStyle(
                        color: ColorsManager.backGroundColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (course.labs.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContentListPage(
                          title: "Labs",
                          content: course.labs,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: ColorsManager.darkGrey,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                        child: Text(
                      "Labs",
                      style: TextStyle(
                          color: ColorsManager.backGroundColor,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
