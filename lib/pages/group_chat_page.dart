import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/models/groups_model.dart';
import 'package:livecom/pages/home_page.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
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
          icon: Icon(Icons.arrow_back, color: Colors.black), // Back button
          onPressed: () {
            // Navigates back
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: group.image == null || (group.image == "")
                  ? AssetImage("assets/user.png")
                  : CachedNetworkImageProvider(
                      "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${group.image}/view?project=67b7e512000635cad2ad&mode=admin",
                    ),
              onBackgroundImageError: (_, __) {
                print("Failed to load profile pic");
              },
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.groupName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
