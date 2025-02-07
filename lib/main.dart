import 'package:flutter/material.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/controllers/local_saved_data.dart';
import 'package:livecom/pages/chat_page.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/pages/login_page.dart';
import 'package:livecom/pages/profile_page.dart';
import 'package:livecom/pages/search_user_page.dart';
import 'package:livecom/pages/splashscreen.dart';
import 'package:livecom/pages/update_profile_page.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

final navigatorKey=GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalSavedData.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Livecom',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => CheckUserSession(),
          "/splash": (context) => const SplashScreen(),
          "/login": (context) => LoginPage(),
          "/home": (context) => const HomePage(),
          "/chat": (context) => ChatPage(),
          "/profile": (context) => ProfilePage(),
          "/update": (context) => UpadteProfilePage(),
          "/search_user": (context) => SearchUserPage(),
        },
      ),
    );
  }
}

class CheckUserSession extends StatefulWidget {
  const CheckUserSession({super.key});

  @override
  State<CheckUserSession> createState() => _CheckUserSessionState();
}

class _CheckUserSessionState extends State<CheckUserSession> {
  @override
  void initState() {
    checkSessions().then((value) {
      if (value) {
        Navigator.pushNamedAndRemoveUntil(context, "/update", (route) => false,
            arguments: {"title": "Add"});
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
