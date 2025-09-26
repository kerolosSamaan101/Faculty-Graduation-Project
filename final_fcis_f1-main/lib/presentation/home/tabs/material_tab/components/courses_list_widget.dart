import 'package:flutter/material.dart';
import '../../../../../data/courses_data.dart';
import '../course_details_screen.dart';
import 'material_item_widget.dart';

class CoursesListWidget extends StatelessWidget {
  final List<Course> courses;

  const CoursesListWidget({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.7,
        child: courses.isEmpty
            ? const Text("No courses found", style: TextStyle(fontSize: 18))
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 5,
            childAspectRatio: 0.75,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsPage(course: courses[index]),
                ),
              );
            },
            child: MaterialItemWidget(courseName: courses[index].name),
          ),
        ),
      ),
    );
  }
}