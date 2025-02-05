import 'package:flutter/material.dart';
import 'package:livecom/pages/chat_page.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/pages/login_page.dart';
import 'package:livecom/pages/profile_page.dart';
import 'package:livecom/pages/search_user_page.dart';
import 'package:livecom/pages/splashscreen.dart';
import 'package:livecom/pages/update_profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Livecom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => SearchUserPage(),
        "/splash": (context) => const SplashScreen(),
        "/home": (context) => const HomePage(),
        "/login": (context) => LoginPage(),
        "/chat": (context) => ChatPage(),
        "/profile": (context) => ProfilePage(),
        "/update_profile": (context) => UpadteProfilePage(),
        "/search_user": (context) => SearchUserPage(),
      },
    );
  }
}
