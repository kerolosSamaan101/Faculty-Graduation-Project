import 'package:flutter/material.dart';
import '../../../../data/courses_data.dart';
import 'course_details_screen.dart';
import 'course_selection_screen/course_selection_screen.dart';
import 'track_level_screen.dart';
import '../../../../core/utils/colors_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialTab extends StatelessWidget {
  const MaterialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorsManager.backGroundColor,
        appBar: AppBar(
          backgroundColor: ColorsManager.backGroundColor,
          elevation: 0,
          title: Text(
            'Learning Materials',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorsManager.darkGrey,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ColorsManager.darkGrey,
            ),
            labelColor: ColorsManager.backGroundColor,
            unselectedLabelColor: ColorsManager.darkGrey,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.school),
                text: 'Academic',
              ),
              Tab(
                icon: Icon(Icons.computer),
                text: 'CS Tracks',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AcademicTab(),
            _CSTracksTab(),
          ],
        ),
      ),
    );
  }
}

class _AcademicTab extends StatefulWidget {
  const _AcademicTab();

  @override
  _AcademicTabState createState() => _AcademicTabState();
}

class _AcademicTabState extends State<_AcademicTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _filteredCourses = courses;
    _searchController.addListener(_filterCourses);
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = courses.where((course) {
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
    return Column(
      children: [
        SizedBox(height: 6),
        // Modern Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Material(
            elevation: 1,
            shadowColor: ColorsManager.darkGrey,
            borderRadius: BorderRadius.circular(30),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: TextStyle(
                  color: ColorsManager.darkGrey.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ColorsManager.darkGrey,
                ),
                filled: true,
                fillColor: ColorsManager.darkGrey.withOpacity(0.000001),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: ColorsManager.darkGrey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterCourses();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),

        // Course Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredCourses.length} ${_filteredCourses.length == 1 ? 'Course' : 'Courses'}',
                style: TextStyle(
                  color: ColorsManager.darkGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_filteredCourses.length != courses.length)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterCourses();
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: ColorsManager.darkGrey,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Book Grid
        Expanded(
          child: _filteredCourses.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.75, // Adjusted for book shape
                    ),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) => _BookCourseCard(
                      course: _filteredCourses[index],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: ColorsManager.darkGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              color: ColorsManager.darkGrey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _filterCourses();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.darkGrey,
                foregroundColor: ColorsManager.backGroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Clear search'),
            ),
        ],
      ),
    );
  }
}

class _BookCourseCard extends StatelessWidget {
  final Course course;

  const _BookCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCourse(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Book Background (Full Size)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/book.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Info (on book cover area)
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 25),
                          // White Box for Course Name
                          Container(
                            padding: const EdgeInsets.only(
                              left: 10,
                            ),
                            child: Text(
                              course.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.darkGrey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Resource Counts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildResourceIndicator(
                                icon: Icons.video_library_rounded,
                                count: course.lectures.length,
                              ),
                              if (course.labs.isNotEmpty)
                                _buildResourceIndicator(
                                  icon: Icons.science_rounded,
                                  count: course.labs.length,
                                ),
                            ],
                          ),
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
    );
  }

  Widget _buildResourceIndicator({
    required IconData icon,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: ColorsManager.darkGrey,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorsManager.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(course: course),
      ),
    );
  }
}

class _CSTracksTab extends StatelessWidget {
  const _CSTracksTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: csTracks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _TrackCard(
          track: csTracks[index],
        ),
      ),
    );
  }
}

class _TrackCard extends StatefulWidget {
  final NonAcademicTrack track;

  const _TrackCard({required this.track});

  @override
  __TrackCardState createState() => __TrackCardState();
}

class __TrackCardState extends State<_TrackCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final trackColor = _getTrackColor(widget.track.name);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.darkGrey.withOpacity(.0000000000000001),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: trackColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: trackColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTrackIcon(widget.track.name),
                  color: trackColor,
                  size: 28,
                ),
              ),
              title: Text(
                widget.track.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.darkGrey,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: trackColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: trackColor,
                  size: 24,
                ),
              ),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  children: widget.track.levels.entries
                      .map(
                        (level) => _LevelCard(
                          level: level.key,
                          courses: level.value,
                          trackColor: trackColor,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTrackColor(String name) {
    switch (name) {
      case 'Machine Learning & Deep Learning':
        return const Color(0xff9C27B0); // Deep purple
      case 'Flutter':
        return const Color(0xFF00CED1); // Blue
      case 'Game Development':
        return const Color.fromARGB(255, 46, 147, 39); // Green
      case 'Software Testing':
        return const Color(0xFFEF6C00); // Orange
      case 'Cyber Security':
        return const Color(0xFFC62828); // Red
      default:
        return ColorsManager.darkGrey;
    }
  }

  IconData _getTrackIcon(String name) {
    switch (name) {
      case 'Machine Learning & Deep Learning':
        return Icons.smart_toy;
      case 'Flutter':
        return Icons.phone_android;
      case 'Game Development':
        return Icons.sports_esports;
      case 'Software Testing':
        return Icons.bug_report;
      case 'Cyber Security':
        return Icons.security;
      default:
        return Icons.developer_mode;
    }
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final Map<String, String> courses;
  final Color trackColor;

  const _LevelCard({
    required this.level,
    required this.courses,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: ColorsManager.backGroundColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getLevelIcon(),
            color: levelColor,
            size: 20,
          ),
        ),
        title: Text(
          level,
          style: TextStyle(
            color: levelColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        children: courses.entries
            .map(
              (course) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: trackColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.link,
                    color: trackColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  course.key,
                  style: TextStyle(
                    color: ColorsManager.darkGrey,
                    fontSize: 15,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: trackColor,
                  size: 16,
                ),
                onTap: () => _launchUrl(course.value),
              ),
            )
            .toList(),
      ),
    );
  }

  Color _getLevelColor() {
    switch (level) {
      case 'Beginner':
        return const Color(0xFF388E3C); // Darker green
      case 'Intermediate':
        return const Color(0xFFF57C00); // Darker orange
      case 'Advanced':
        return const Color(0xFFD32F2F); // Darker red
      default:
        return ColorsManager.darkGrey;
    }
  }

  IconData _getLevelIcon() {
    switch (level) {
      case 'Beginner':
        return Icons.play_arrow;
      case 'Intermediate':
        return Icons.trending_up;
      case 'Advanced':
        return Icons.star;
      default:
        return Icons.help;
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
