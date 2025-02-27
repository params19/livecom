import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livecom/controllers/notification_controller.dart';
import 'package:livecom/pages/create_or_update_page.dart';
import 'package:livecom/pages/group_chat_page.dart';
import 'package:livecom/pages/group_details.dart';
import 'package:livecom/pages/invite_members.dart';
import 'package:livecom/providers/group_message_provider.dart';
import 'package:provider/provider.dart';
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
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("Lifecycle changed: $state"); // Debugging

    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print("Executing updateOnlineStatus: resumed"); // Debugging
        updateOnlineStatus(status: true, userId: currentUserId);
        break;
      case AppLifecycleState.inactive:
        print("Executing updateOnlineStatus: inactive"); // Debugging
        updateOnlineStatus(status: false, userId: currentUserId);
        break;
      case AppLifecycleState.paused:
        print("Executing updateOnlineStatus: paused"); // Debugging
        updateOnlineStatus(status: false, userId: currentUserId);
        break;
      case AppLifecycleState.detached:
        print("Executing updateOnlineStatus: detached"); // Debugging
        updateOnlineStatus(status: false, userId: currentUserId);
        break;
      default:
        print("Unhandled state: $state"); // Debugging
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalSavedData.init();

  WidgetsBinding.instance.addObserver(LifecycleEventHandler());

  // Initialize Firebase messaging
  await PushNotifications.init();
  await PushNotifications.localNotiInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      navigatorKey.currentState?.pushNamed("/message", arguments: message);
    }
  });

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });

  // Handle app launch from terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState?.pushNamed("/home");
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => GroupMessageProvider())
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
          '/': (context) => const CheckUserSession(),
          "/login": (context) => LoginPage(),
          "/home": (context) => const HomePage(),
          "/chat": (context) => ChatPage(),
          "/profile": (context) => ProfilePage(),
          "/update": (context) => UpadteProfilePage(),
          "/search_user": (context) => SearchUserPage(),
          "/modify_group": (context) => CreateOrUpdateGroup(),
          "/group_chat": (context) => GroupChatPage(),
          "/invite_page": (context) => InviteMembers(),
          "/group_details": (context) => GroupDetails(),
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
    super.initState();

    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    });

    checkSessions().then((isLoggedIn) {
      final userName =
          Provider.of<UserDataProvider>(context, listen: false).getUserName;

      if (isLoggedIn) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          userName.isNotEmpty ? "/home" : "/update",
          (route) => false,
          arguments: userName.isEmpty ? {"title": "Add"} : null,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
