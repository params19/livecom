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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    Provider.of<GroupMessageProvider>(context, listen: false)
        .loadAllGroupRequiredData(currentUserId);
    PushNotifications.getDeviceToken();
    subscribeToRealtime(userId: currentUserId);
    subscribeToRealtimeGroupMsg(userId: currentUserId);
  }

  void _handleSearch() {
    // Implement search functionality here
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
            labelColor: primary_purple, // Color of the selected tab text
            unselectedLabelColor:
                Colors.black, // Color of the unselected tab text
            indicatorColor:
                primary_purple, // Color of the indicator below the selected tab
            tabs: const [
              Tab(text: "Direct Messages"),
              Tab(text: "Groups"),
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
                        return const SizedBox.shrink();
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
                                backgroundColor: primary_purple,
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
                  return const Center(child: Text("No Group Joined"));
                } else {
                  // Sort groups based on the timestamp of the latest message in each group
                  value.getJoinedGroups.sort((a, b) {
                    String groupIdA = a.groupId;
                    String groupIdB = b.groupId;

                    // Get the latest message for group A
                    List<GroupMessageModel>? messagesA =
                        value.getGroupMessages?[groupIdA];
                    DateTime? latestTimestampA =
                        messagesA != null && messagesA.isNotEmpty
                            ? messagesA.last.timestamp
                            : DateTime.fromMillisecondsSinceEpoch(
                                0); // Default old date if no messages

                    // Get the latest message for group B
                    List<GroupMessageModel>? messagesB =
                        value.getGroupMessages?[groupIdB];
                    DateTime? latestTimestampB =
                        messagesB != null && messagesB.isNotEmpty
                            ? messagesB.last.timestamp
                            : DateTime.fromMillisecondsSinceEpoch(
                                0); // Default old date if no messages

                    // Sort in descending order by timestamp
                    return latestTimestampB.compareTo(latestTimestampA);
                  });
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, "/explore_channels");
                        },
                        leading: Padding(
                          padding: const EdgeInsets.only(
                              left: 6.0), // Add space here
                          child: const Icon(Icons.groups_outlined),
                        ),
                        title: const Text("Explore Channels",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black54,
                          textDirection: TextDirection.ltr,
                          size: 18,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: value.getJoinedGroups.length,
                          itemBuilder: (context, index) {
                            String groupId =
                                value.getJoinedGroups[index].groupId;
                            List<GroupMessageModel> messages =
                                value.getGroupMessages[groupId] ?? [];
                            GroupMessageModel? lastMessage =
                                messages.isNotEmpty ? messages.last : null;

                            return ListTile(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/group_chat",
                                  arguments: value.getJoinedGroups[index],
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: value
                                                .getJoinedGroups[index].image ==
                                            "" ||
                                        value.getJoinedGroups[index].image ==
                                            null
                                    ? const AssetImage("assets/user.png")
                                    : CachedNetworkImageProvider(
                                        "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${value.getJoinedGroups[index].image}/view?project=67b7e512000635cad2ad&mode=admin"),
                              ),
                              title: Text(
                                value.getJoinedGroups[index].groupName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                lastMessage == null
                                    ? "No Message"
                                    : "${lastMessage.senderId == currentUserId ? "You : " : "${lastMessage.userData[0].name ?? "No Name"} : "}${lastMessage.isImage == true ? "Sent an image" : lastMessage.message}",
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FutureBuilder(
                                    future: calculateUnreadMessages(
                                        groupId, messages),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox();
                                      } else if (snapshot.hasError) {
                                        return const SizedBox();
                                      } else {
                                        int unreadMsgCount = snapshot.data ?? 0;
                                        return unreadMsgCount == 0
                                            ? const SizedBox()
                                            : CircleAvatar(
                                                backgroundColor: primary_purple,
                                                radius: 10,
                                                child: Text(
                                                  "$unreadMsgCount",
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white),
                                                ),
                                              );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  lastMessage == null
                                      ? const SizedBox()
                                      : Text(formatDate(lastMessage.timestamp))
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchUserPage()),
            );
          },
          child: const Icon(Icons.chat),
        ),
      ),
    );
  }
}
