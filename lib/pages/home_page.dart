import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/date_format.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/controllers/notification_controller.dart';
import 'package:livecom/models/chat_data_model.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/pages/search_user_page.dart';
import 'package:livecom/providers/chat_provider.dart';
import 'package:livecom/providers/group_message_provider.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserId = "";

  @override
  void initState() {
    // TODO: implement initState
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    Provider.of<GroupMessageProvider>(context, listen: false)
        .loadAllGroupData(currentUserId);
    PushNotifications.getDeviceToken();
    subscribeToRealtime(userId: currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateOnlineStatus(status: true, userId: currentUserId);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: background_color,
        appBar: AppBar(
          backgroundColor: background_color,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: const Text(
            "Chats",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile"),
              child: Consumer<UserDataProvider>(
                builder: (context, value, child) {
                  return CircleAvatar(
                    backgroundImage: value.getUserProfile != null &&
                            value.getUserProfile != ""
                        ? CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${value.getUserProfile}/view?project=67b7e512000635cad2ad&mode=admin")
                        : const AssetImage("assets/user.png") as ImageProvider,
                  );
                },
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Direct Messages",
              ),
              Tab(
                text: "Groups",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Consumer<ChatProvider>(
              builder: (context, value, child) {
                if (value.getAllChats.isEmpty) {
                  return const Center(
                    child: Text("No chats yet!"),
                  );
                } else {
                  List otherUsers = value.getAllChats.keys.toList();

                  return ListView.builder(
                    itemCount: otherUsers.length,
                    itemBuilder: (context, index) {
                      List<ChatDataModel> chatData =
                          value.getAllChats[otherUsers[index]]!;
                      int totalChats = chatData.length;
                      UserData otherUser =
                          chatData[0].users[0].userId == currentUserId
                              ? chatData[0].users[1]
                              : chatData[0].users[0];

                      int unreadMsg =
                          chatData.fold(0, (previousValue, element) {
                        return element.message.isSeenByReceiver
                            ? previousValue
                            : previousValue + 1;
                      });

                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, "/chat",
                              arguments: otherUser);
                        },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: otherUser.profilePic == null ||
                                      otherUser.profilePic!.isEmpty
                                  ? const AssetImage("assets/user.png")
                                  : CachedNetworkImageProvider(
                                      "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${otherUser.profilePic}/view?project=67b7e512000635cad2ad&mode=admin",
                                    ) as ImageProvider,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: otherUser.isOnline!
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        title: Text(otherUser.name ?? "Unknown"),
                        subtitle: Text(
                          "${chatData[totalChats - 1].message.sender == currentUserId ? "You: " : ""}"
                          "${chatData[totalChats - 1].message.isImage! ? "Sent an image" : chatData[totalChats - 1].message.message}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (chatData[totalChats - 1].message.sender !=
                                    currentUserId &&
                                unreadMsg > 0)
                              CircleAvatar(
                                backgroundColor: primary_blue,
                                radius: 10,
                                child: Text(
                                  unreadMsg.toString(),
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(formatDate(
                                chatData[totalChats - 1].message.timestamp)),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
            Consumer<GroupMessageProvider>(
              builder: (context, value, child) {
                if (value.getJoinedGroups.isEmpty) {
                  return Center(child: Text("No Group Joined"));
                } else {
                  return ListView.builder(
                    itemCount: value.getJoinedGroups.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(value.getJoinedGroups[index].groupName),
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchUserPage()),
            );
          },
          child: const Icon(Icons.chat),
        ),
      ),
    );
  }
}
