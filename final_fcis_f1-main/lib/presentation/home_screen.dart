import 'package:FCIS_F1/core/utils/images_manager.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/material_posts_tab.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_tab/material_tab.dart';
import 'package:FCIS_F1/presentation/home/tabs/opportioneties_tab/opportunities_tab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FCIS_F1/presentation/home/tabs/material_posts_tab/components/notification_service.dart';

import '../core/utils/colors_manager.dart';
import '../core/utils/routes_manager.dart';
import 'home/tabs/notifications_tab/notification_tab.dart';
import 'home/tabs/q_and_a_tab/q_and_answer_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double iconSize = 50;
  final NotificationService _notificationService = NotificationService();
  String? _currentUserId;

  List<Widget> tabs = [
    QAndAnswerTab(),
    MaterialPostScreen(),
    OpportunitiesPage(),
    MaterialTab(),
    NotificationTab()
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backGroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backGroundColor,
        title: const Text(
          "FCIS F1",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagesManager.q_and_answerIcon,
              fit: BoxFit.fill,
            ),
            label: "q&a",
            backgroundColor: ColorsManager.backGroundColor,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagesManager.materialPostsIcon,
              fit: BoxFit.fill,
            ),
            label: "post material",
            backgroundColor: ColorsManager.backGroundColor,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagesManager.opportunitiesIcon,
              fit: BoxFit.fill,
            ),
            label: "opportunities",
            backgroundColor: ColorsManager.backGroundColor,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagesManager.materialsIcon,
              fit: BoxFit.fill,
            ),
            label: "materials",
            backgroundColor: ColorsManager.backGroundColor,
          ),
          BottomNavigationBarItem(
            icon: FutureBuilder<int>(
              future: _notificationService
                  .getUnreadNotificationCount(_currentUserId ?? ''),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      ImagesManager.notificationsIcon,
                      fit: BoxFit.fill,
                    ),
                    if (count > 0)
                      Positioned(
                        width: 22,
                        height: 22,
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorsManager.backGroundColor,
                              width: 0,
                            ),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: "notifications",
            backgroundColor: ColorsManager.backGroundColor,
          ),
        ],
      ),
      body: tabs[selectedIndex],
    );
  }
}
