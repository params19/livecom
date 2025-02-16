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
import 'package:livecom/providers/chat_provider.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("App resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App inactive");

        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App paused");

        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App detched");

        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App hidden");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());
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
        ChangeNotifierProvider(create: (context) => ChatProvider()),
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
          '/': (context) => LoginPage(),
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
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    });

    checkSessions().then((value) {
      final userName =
          Provider.of<UserDataProvider>(context, listen: false).getUserName;
      print("Username: ${userName}");

      if (value) {
        if (userName != null && userName != "") {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, "/update", (route) => false,
              arguments: {"title": "Add"});
        }
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
