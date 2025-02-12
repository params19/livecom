import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData {
  static SharedPreferences? preferences;

  // initialize
  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  // save the userId
  static Future<void> saveUserid(String id) async {
    print("Save User ID to local");
    await preferences!.setString("userId", id);
  }

  // read the userId
  static String getUserId() {
    return preferences!.getString("userId") ?? "";
  }

  // save the user name
  static Future<void> saveUserName(String name) async {
    print("Save User name to Local: $name");

    await preferences!.setString("name", name);
  }

  // read the user name
  static String getUserName() {
    return preferences!.getString("name") ?? "";
  }

  // save the user phone
  static Future<void> saveUserPhone(String phone) async {
    print("Save User Phone Number to Local:$phone");

    await preferences!.setString("phone", phone);
  }

  // read the user phone
  static String getUserPhone() {
    return preferences!.getString("phone") ?? "";
  }

  // save the user profile picture
  static Future<void> saveUserProfile(String profile) async {
    print("Save User Profile to Local");
    await preferences!.setString("Profile", profile);
  }

  // read the user profile picture
  static String getUserProfile() {
    return preferences!.getString("Profile") ?? "";
  }

  // clear all the saved data
  static clearAllData() async {
    final bool data = await preferences!.clear();
    print("Cleared all data from local :$data");
  }
}