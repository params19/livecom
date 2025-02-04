import 'package:flutter/material.dart';
import 'package:livecom/pages/chat_page.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/pages/login_page.dart';
import 'package:livecom/pages/splashscreen.dart';

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
        '/': (context) => ChatPage(),
        "/splash": (context) => const SplashScreen(),
        "/home": (context) => const HomePage(),
        "/login": (context) => LoginPage(),
        "/chat" : (context) => ChatPage(),
      },
    );
  }
}
