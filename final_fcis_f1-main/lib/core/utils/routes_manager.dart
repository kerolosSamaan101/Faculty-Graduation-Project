import 'package:FCIS_F1/presentation/home/tabs/q_and_a_tab/q_and_answer_tab.dart';
import 'package:FCIS_F1/presentation/registration_screens/login_screen.dart';
import 'package:FCIS_F1/presentation/registration_screens/sign_up_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/courses_data.dart';
import '../../presentation/home/tabs/material_posts_tab/material_posts_tab.dart';
import '../../presentation/home/tabs/material_tab/material_tab.dart';
import '../../presentation/home/tabs/notifications_tab/notification_tab.dart';
import '../../presentation/home/tabs/opportioneties_tab/opportunities_tab.dart';
import '../../presentation/home/tabs/opportioneties_tab/opportunity_report_page.dart';
import '../../presentation/home/tabs/opportioneties_tab/opportunity_form_page.dart';
import '../../presentation/home_screen.dart';
import '../../presentation/profile/profile_page.dart';

class RoutsManager {
  static const String mainScrean = "/home";
  static const String materialScreen = "/material";
  static const String materialPostsScreen = "/materialPosts";
  static const String notificationsScreen = "/notificationsScreen";
  static const String opportunitiesScreen = "/opportunitiesScreen";
  static const String q_and_answer_Screen = "/q_and_answer_Screen";
  static const String opportunityFormPage = "/OpportunityFormPage";
  static const String loginScreen = "/LoginScreen";
  static const String signUpScreen = "/signUpScreen";
  static const String profileScreen = "/profileScreen";
  static const String opportunityReportPage = "/opportunityReportPage";

  static Route<dynamic>? router(RouteSettings settings) {
    switch (settings.name) {
      case mainScrean:
        {
          return MaterialPageRoute(
            builder: (context) => HomeScreen(),
          );
        }

      case loginScreen:
        {
          return MaterialPageRoute(
            builder: (context) => LoginScreen(),
          );
        }

      case signUpScreen:
        {
          return MaterialPageRoute(
            builder: (context) => SignUpPage(),
          );
        }

      case profileScreen:
        {
          return MaterialPageRoute(
            builder: (context) => ProfilePage(),
          );
        }

      case materialScreen:
        {
          return MaterialPageRoute(
            builder: (context) => MaterialTab(),
          );
        }
      case materialPostsScreen:
        {
          return MaterialPageRoute(
            builder: (context) => MaterialPostScreen(),
          );
        }

      case notificationsScreen:
        {
          return MaterialPageRoute(
            builder: (context) => NotificationTab(),
          );
        }

      case opportunitiesScreen:
        {
          return MaterialPageRoute(
            builder: (context) => OpportunitiesPage(),
          );
        }

      case opportunityFormPage:
        {
          return MaterialPageRoute(
            builder: (context) => OpportunityFormPage(),
          );
        }
      case opportunityReportPage:
        {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OpportunityReportPage(
              opportunityCategory: args['category'],
            ),
          );
        }

      case q_and_answer_Screen:
        {
          return MaterialPageRoute(
            builder: (context) => QAndAnswerTab(),
          );
        }
    }
  }
}
