import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  String fullName;
  String email;
  String university;
  String college;
  String academicYear;
  String phoneNumber;
  String linkedIn;
  String location;
  String bio;
  String skills;
  String status;
  List<String> interests;
  String profileImagePath;

  UserData({
    required this.fullName,
    required this.email,
    required this.university,
    required this.college,
    required this.academicYear,
    required this.phoneNumber,
    required this.linkedIn,
    required this.location,
    required this.bio,
    required this.skills,
    required this.status,
    required this.interests,
    required this.profileImagePath,
  });

  // تحويل الكائن إلى خريطة (Map)
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'university': university,
      'college': college,
      'academicYear': academicYear,
      'phoneNumber': phoneNumber,
      'linkedIn': linkedIn,
      'location': location,
      'bio': bio,
      'skills': skills,
      'status': status,
      'interests': interests,
      'profileImagePath': profileImagePath,
    };
  }

  // إنشاء كائن UserData من خريطة (Map)
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      fullName: map['fullName'],
      email: map['email'],
      university: map['university'],
      college: map['college'],
      academicYear: map['academicYear'],
      phoneNumber: map['phoneNumber'],
      linkedIn: map['linkedIn'],
      location: map['location'],
      bio: map['bio'],
      skills: map['skills'],
      status: map['status'],
      interests: List<String>.from(map['interests']),
      profileImagePath: map['profileImagePath'],
    );
  }

  // تحويل الكائن إلى JSON
  String toJson() => json.encode(toMap());

  // إنشاء كائن UserData من JSON
  factory UserData.fromJson(String source) => UserData.fromMap(json.decode(source));

  // حفظ بيانات المستخدم في SharedPreferences
  static Future<void> saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', userData.toJson());
  }

  // استرجاع بيانات المستخدم من SharedPreferences
  static Future<UserData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      return UserData.fromJson(userDataString);
    }
    return null;
  }

  // حذف بيانات المستخدم من SharedPreferences
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}
