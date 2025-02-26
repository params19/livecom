// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:livecom/controllers/notification_controller.dart';
// import 'package:provider/provider.dart';
// import 'package:livecom/controllers/appwrite_controllers.dart';
// import 'package:livecom/controllers/local_saved_data.dart';
// import 'package:livecom/pages/chat_page.dart';
// import 'package:livecom/pages/home_page.dart';
// import 'package:livecom/pages/login_page.dart';
// import 'package:livecom/pages/profile_page.dart';
// import 'package:livecom/pages/search_user_page.dart';
// import 'package:livecom/pages/splashscreen.dart';
// import 'package:livecom/pages/update_profile_page.dart';
// import 'package:livecom/providers/chat_provider.dart';
// import 'package:livecom/providers/user_data_provider.dart';
// import 'firebase_options.dart';

// final navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
//   print("Handling background message: ${message.messageId}");
// }

// class LifecycleEventHandler extends WidgetsBindingObserver {
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//      String currentUserId = Provider.of<UserDataProvider>(
//             navigatorKey.currentState!.context,
//             listen: false)
//         .getUserId;
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.resumed:
//         updateOnlineStatus(status: true, userId: currentUserId);
//         print("app resumed");
//         break;
//       case AppLifecycleState.inactive:
//         updateOnlineStatus(status: false, userId: currentUserId);
//         print("app inactive");

//         break;
//       case AppLifecycleState.paused:
//         updateOnlineStatus(status: false, userId: currentUserId);
//         print("app paused");

//         break;
//       case AppLifecycleState.detached:
//         updateOnlineStatus(status: false, userId: currentUserId);
//         print("app detched");

//         break;
//       case AppLifecycleState.hidden:
//         updateOnlineStatus(status: false, userId: currentUserId);
//         print("app hidden");
//     }
//   }

// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   WidgetsBinding.instance.addObserver(LifecycleEventHandler());

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await LocalSavedData.init();

//   // Initialize Firebase messaging
//   await PushNotifications.init();
//   await PushNotifications.localNotiInit();
//   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

//   // Handle background notification taps
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     if (message.notification != null) {
//       navigatorKey.currentState?.pushNamed("/message", arguments: message);
//     }
//   });

//   // Handle foreground notifications
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     String payloadData = jsonEncode(message.data);
//     if (message.notification != null) {
//       PushNotifications.showSimpleNotification(
//         title: message.notification!.title!,
//         body: message.notification!.body!,
//         payload: payloadData,
//       );
//     }
//   });

//   // for handling in terminated state
//   final RemoteMessage? message =
//       await FirebaseMessaging.instance.getInitialMessage();

//   if (message != null) {
//     print("Launched from terminated state");
//     Future.delayed(Duration(seconds: 1), () {
//       navigatorKey.currentState!.pushNamed(
//         "/home",
//       );
//     });
//   }
//   runApp(const MyApp());
// }
// @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(lifecycleEventHandler);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(lifecycleEventHandler);
//     super.dispose();
//   }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => UserDataProvider()),
//         ChangeNotifierProvider(create: (context) => ChatProvider()),
//       ],
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         debugShowCheckedModeBanner: false,
//         title: 'Livecom',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//           useMaterial3: true,
//         ),
//         routes: {
//           '/': (context) => CheckUserSession(),
//           // "/splash": (context) => const SplashScreen(),
//           "/login": (context) => LoginPage(),
//           "/home": (context) => const HomePage(),
//           "/chat": (context) => ChatPage(),
//           "/profile": (context) => ProfilePage(),
//           "/update": (context) => UpadteProfilePage(),
//           "/search_user": (context) => SearchUserPage(),
//         },
//       ),
//     );
//   }
// }

// class CheckUserSession extends StatefulWidget {
//   const CheckUserSession({super.key});

//   @override
//   State<CheckUserSession> createState() => _CheckUserSessionState();
// }

// class _CheckUserSessionState extends State<CheckUserSession> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
//     });

//     checkSessions().then((isLoggedIn) {
//       final userName =
//           Provider.of<UserDataProvider>(context, listen: false).getUserName;

//       if (isLoggedIn) {
//         if (userName.isNotEmpty) {
//           Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
//         } else {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             "/update",
//             (route) => false,
//             arguments: {"title": "Add"},
//           );
//         }
//       } else {
//         Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
