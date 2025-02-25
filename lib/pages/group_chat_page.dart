import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/memberCalculate.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
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
  late String currentUser = "";

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    super.initState();
    currentUser =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
  }

  void _sendGroupMessage({
    required String groupId,
    required GroupModel groupData,
    required String message,
    required String senderId,
    bool? isImage,
  }) async {
    bool success = await sendGroupMessage(
      groupId: groupId,
      message: message,
      isImage: isImage,
      senderId: senderId,
    );

    if (success) {
      List<String> userTokens = groupData.userData
          .where((user) => user.userId != currentUser)
          .map((user) => user.deviceToken ?? "")
          .toList();

      print("Users token are $userTokens");

      Provider.of<GroupMessageProvider>(context, listen: false).addGroupMessage(
        groupId: groupId,
        msg: GroupMessageModel(
          messageId: "",
          groupId: groupId,
          message: message,
          senderId: senderId,
          timestamp: DateTime.now(),
          userData: [UserData(phone: "", userId: senderId)],
          isImage: isImage,
        ),
      );

      _messageController.clear();
    }
  }

  // Open file picker
  void _openFilePicker(GroupModel groupData) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result != null) {
      setState(() {
        _filePickerResult = result;
      });
      uploadAllImage(groupData);
    } else {
      print("File pick cancelled by user");
    }
  }

  // Upload files to storage bucket and database
  void uploadAllImage(GroupModel groupData) async {
    if (_filePickerResult == null) return;

    for (String? path in _filePickerResult!.paths) {
      if (path != null) {
        File file = File(path);
        final fileBytes = file.readAsBytesSync();
        final inputFile = InputFile.fromBytes(
          bytes: fileBytes,
          filename: file.path.split("/").last,
        );

        // Save image to storage bucket
        String? imageId = await saveImageToBucket(image: inputFile);

        if (imageId != null) {
          _sendGroupMessage(
            groupId: groupData.groupId,
            groupData: groupData,
            message: imageId,
            senderId: currentUser,
            isImage: true,
          );
        }
      }
    }
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
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.groupName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  memCal(group.members.length),
                  style: const TextStyle(fontSize: 14),
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
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: secondary_color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _openFilePicker(group),
                  icon: const Icon(Icons.image),
                ),
                IconButton(
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _sendGroupMessage(
                        groupData: group,
                        groupId: group.groupId,
                        message: _messageController.text.trim(),
                        senderId: currentUser,
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
