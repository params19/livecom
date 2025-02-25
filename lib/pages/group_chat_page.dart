import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/memberCalculate.dart';
import 'package:livecom/models/group_message_model.dart';
import 'package:livecom/models/groups_model.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/providers/group_message_provider.dart';
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

  //  void _sendGroupMessage(
  //     {required String groupId,
  //     required GroupModel groupData,
  //     required String message,
  //     required String senderId,
  //     bool? isImage}) async {
  //   await sendGroupMessage(
  //           groupId: groupId,
  //           message: message,
  //           isImage: isImage,
  //           senderId: senderId)
  //       .then((value) {
  //     if (value) {
  //        List<String> userTokens=[];

  //             for(var i=0;i<groupData.userData.length;i++){
  //               if(groupData.userData[i].userId!=currentUser){
  //               userTokens.add(groupData.userData[i].deviceToken??"");
  //               }
  //             }
  //             print("users token are $userTokens");
  //       Provider.of<GroupMessageProvider>(context, listen: false)
  //           .addGroupMessage(
  //               groupId: groupId,
  //               msg: GroupMessageModel(
  //                   messageId: "",
  //                   groupId: groupId,
  //                   message: message,
  //                   senderId: senderId,
  //                   timestamp: DateTime.now(),
  //                   userData: [UserData(phone: "", userId: senderId)],
  //                   isImage: isImage));
  //     }
  //     _messageController.clear();
  //   });
  // }
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
                Text(
                  memCal(group.members.length),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Container()), // Placeholder for messages UI
          Container(
            margin: EdgeInsets.all(6),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: secondary_color,
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      // _openFilePicker(receiver);
                    },
                    icon: Icon(Icons.image)),
                IconButton(
                    onPressed: () {
                      // _sendMessage(receiver: receiver);
                    },
                    icon: Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }
}
