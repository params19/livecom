import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/date_format.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/controllers/notification_controller.dart';
import 'package:livecom/models/chat_data_model.dart';
import 'package:livecom/models/group_message_model.dart';
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
        .loadAllGroupRequiredData(currentUserId);
    PushNotifications.getDeviceToken();
    subscribeToRealtime(userId: currentUserId);
    subscribeToRealtimeGroupMsg(userId: currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GroupMessageProvider>(context, listen: false)
        .loadAllGroupData(currentUserId);
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

                      if (chatData.isEmpty) {
                        return SizedBox.shrink();
                      }
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
                          chatData[totalChats - 1].message.isGroupInvite == true
                              ? "${chatData[totalChats - 1].message.sender == currentUserId ? "You sent a group invite " : "Receive a group invite"}"
                              : "${chatData[totalChats - 1].message.sender == currentUserId ? "You : " : ""}${chatData[totalChats - 1].message.isImage == true ? "Sent an image" : chatData[totalChats - 1].message.message}",
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
                      String groupId = value.getJoinedGroups[index].groupId;
                      List<GroupMessageModel> messages =
                          value.getGroupMessages[groupId] ?? [];
                      GroupMessageModel? lastMessage =
                          messages != null && messages.isNotEmpty
                              ? messages.last
                              : null;

                      return ListTile(
                        onTap: () {
                          print("Group chat window");
                          Navigator.pushNamed(
                            context,
                            "/group_chat",
                            arguments: value.getJoinedGroups[index],
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: value.getJoinedGroups[index].image ==
                                      "" ||
                                  value.getJoinedGroups[index].image == null
                              ? Image(
                                  image: AssetImage("assets/user.png"),
                                ).image
                              : CachedNetworkImageProvider(
                                  "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${value.getJoinedGroups[index].image}/view?project=67b7e512000635cad2ad&mode=admin"),
                        ),
                        title: Text(
                          value.getJoinedGroups[index].groupName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          lastMessage == null
                              ? "No Message"
                              : "${lastMessage!.senderId == currentUserId ? "You : " : "${lastMessage.userData[0].name ?? "No Name"} : "}${lastMessage.isImage == true ? "Sent an image" : lastMessage.message}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FutureBuilder(
                              future: calculateUnreadMessages(
                                  groupId, messages ?? []),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox();
                                } else if (snapshot.hasError) {
                                  return SizedBox();
                                } else {
                                  int unreadMsgCount = snapshot.data ?? 0;
                                  return unreadMsgCount == 0
                                      ? SizedBox()
                                      : CircleAvatar(
                                          backgroundColor: primary_blue,
                                          radius: 10,
                                          child: Text(
                                            "$unreadMsgCount",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white),
                                          ),
                                        );
                                }
                              },
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            lastMessage == null
                                ? SizedBox()
                                : Text(formatDate(lastMessage.timestamp))
                          ],
                        ),
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
