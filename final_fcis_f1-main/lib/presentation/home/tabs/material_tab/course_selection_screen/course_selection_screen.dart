import 'package:flutter/material.dart';
import '../../../../../core/utils/colors_manager.dart';
import '../../../../../data/courses_data.dart';
import '../components/courses_list_widget.dart';

class CourseSelectionPage extends StatefulWidget {
  final List<Course> courses;

  const CourseSelectionPage({super.key, required this.courses});

  @override
  _CourseSelectionPageState createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  TextEditingController _searchController = TextEditingController();
  List<Course> filteredCourses = [];

  @override
  void initState() {
    super.initState();
    filteredCourses = widget.courses;
    _searchController.addListener(_filterCourses);
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredCourses = widget.courses.where((course) {
        return course.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Academic Courses",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choose Your Course",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: ColorsManager.backGroundColor),
                fillColor: ColorsManager.darkGrey,
                filled: true,
                prefixIcon: Icon(Icons.search, color: ColorsManager.backGroundColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),

          // Courses Grid (Pass filtered list)
          Expanded(child: CoursesListWidget(courses: filteredCourses)),
        ],
      ),
    );
  }
}