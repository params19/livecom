import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/models/groups_model.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _editMessageController = TextEditingController();
  late String currentUser;

  @override
  void initState() {
    super.initState();
    currentUser =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
  }

  @override
  Widget build(BuildContext context) {
    final GroupModel group =
        ModalRoute.of(context)!.settings.arguments as GroupModel;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: background_color,
        leadingWidth: 40,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: group.image == null || group.image == ""
                  ? const AssetImage("assets/user.png") as ImageProvider
                  : CachedNetworkImageProvider(
                      "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${group.image}/view?project=67b7e512000635cad2ad&mode=admin",
                    ),
              onBackgroundImageError: (_, __) {
                debugPrint("Failed to load profile pic");
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.groupName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              if (group.isPublic || group.admin == currentUser)
                PopupMenuItem<String>(
                  onTap: () => Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, "/invite_members",
                        arguments: group);
                  }),
                  child: const Row(
                    children: [
                      Icon(Icons.group_add_outlined),
                      SizedBox(width: 8),
                      Text("Invite Members"),
                    ],
                  ),
                ),
              if (group.admin == currentUser)
                PopupMenuItem<String>(
                  onTap: () => Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, "/modify_group",
                        arguments: group);
                  }),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text("Edit Group"),
                    ],
                  ),
                ),
              if (group.admin != currentUser)
                PopupMenuItem<String>(
                  onTap: () {
                    
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text("Exit Group"),
                    ],
                  ),
                ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
