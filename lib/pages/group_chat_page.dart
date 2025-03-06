import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/group_chat_message.dart';
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
  TextEditingController _editMessageController = TextEditingController();
  late String currentUser = "";
  late String currentUserName = "";

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    super.initState();
    currentUser =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;

    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
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
        saveImageToBucket(image: inputFile).then((imageId) {
          if (imageId != null) {
            sendGroupMessage(
                groupId: groupData.groupId,
                message: imageId,
                senderId: currentUser,
                isImage: true);
            List<String> userTokens = [];

            for (var i = 0; i < groupData.userData.length; i++) {
              if (groupData.userData[i].userId != currentUser) {
                userTokens.add(groupData.userData[i].deviceToken ?? "");
              }
            }
            print("Users token are $userTokens");
            sendMultipleNotificationtoOtherUser(
                notificationTitle:
                    "Received an image in ${groupData.groupName}",
                notificationBody: '${currentUserName}: Sent an image',
                deviceToken: userTokens);
          }
        });
      } else {
        print("File path is null");
      }
    }
  }

  void _sendGroupMessage(
      {required String groupId,
      required GroupModel groupData,
      required String message,
      required String senderId,
      bool? isImage}) async {
    await sendGroupMessage(
            groupId: groupId,
            message: message,
            isImage: isImage,
            senderId: senderId)
        .then((value) {
      if (value) {
        List<String> userTokens = [];

        for (var i = 0; i < groupData.userData.length; i++) {
          if (groupData.userData[i].userId != currentUser) {
            userTokens.add(groupData.userData[i].deviceToken ?? "");
          }
        }
        print("Users token are $userTokens");
        sendMultipleNotificationtoOtherUser(
            notificationTitle: "Received a message in ${groupData.groupName}",
            notificationBody: '${currentUserName}: ${_messageController.text}',
            deviceToken: userTokens);
        Provider.of<GroupMessageProvider>(context, listen: false)
            .addGroupMessage(
                groupId: groupId,
                msg: GroupMessageModel(
                    messageId: "",
                    groupId: groupId,
                    message: message,
                    senderId: senderId,
                    timestamp: DateTime.now(),
                    userData: [UserData(phone: "", userId: senderId)],
                    isImage: isImage));
      }
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GroupModel group =
        ModalRoute.of(context)!.settings.arguments as GroupModel;

    Provider.of<GroupMessageProvider>(context, listen: false).loadAllGroupData(
        Provider.of<UserDataProvider>(context, listen: false).getUserId);
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
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/group_details", arguments: group);
          },
          child: Row(
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
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              if (group.isPublic || group.admin == currentUser)
                PopupMenuItem<String>(
                    onTap: () => Navigator.pushNamed(context, "/invite_page",
                        arguments: group),
                    child: Row(
                      children: [
                        Icon(Icons.group_add_outlined),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Invite Members")
                      ],
                    )),
              if (group.admin == currentUser)
                PopupMenuItem<String>(
                    onTap: () => Navigator.pushNamed(context, "/modify_group",
                        arguments: group),
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Edit Group")
                      ],
                    )),
              if (group.admin != currentUser)
                PopupMenuItem<String>(
                    onTap: () async {
                      await exitGroup(
                              groupId: group.groupId, currentUser: currentUser)
                          .then((value) {
                        if (value) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Group Left Successfully.")));
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to exit group.")));
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Exit Group")
                      ],
                    )),
            ],
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<GroupMessageProvider>(
              builder: (context, value, child) {
                Map<String, List<GroupMessageModel>> allGroupMessages =
                    value.getGroupMessages;
                List<GroupMessageModel> thisGroupMsg =
                    allGroupMessages[group.groupId] ?? [];
                // Reverse the list
                List<GroupMessageModel> reversedMsg =
                    thisGroupMsg.reversed.toList();
                if (thisGroupMsg.length > 0) {
                  updateLastMessageSeen(
                      group.groupId, thisGroupMsg.last.messageId);
                }
                Provider.of<GroupMessageProvider>(context, listen: false)
                    .loadAllGroupData(
                        Provider.of<UserDataProvider>(context, listen: false)
                            .getUserId);
                return ListView.builder(
                  reverse: true,
                  itemCount: reversedMsg.length,
                  itemBuilder: (context, index) {
                    final msg = reversedMsg[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: msg.isImage == true
                                ? Text(msg.senderId == currentUser ||
                                        group.admin == currentUser
                                    ? "Choose what you want to do with this image."
                                    : "This image can't be modified")
                                : Text(
                                    "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ..."),
                            content: msg.isImage == true
                                ? Text(msg.senderId == currentUser ||
                                        group.admin == currentUser
                                    ? 'Delete this image'
                                    : 'This image can\'t be deleted')
                                : Text(msg.senderId == currentUser ||
                                        group.admin == currentUser
                                    ? 'Choose what you want to do with this message.'
                                    : 'This message can\'t be modified'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              if ((msg.senderId == currentUser ||
                                      group.admin == currentUser) &&
                                  (msg.isImage ?? false))
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _editMessageController.text = msg.message;

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Edit this message"),
                                        content: TextFormField(
                                          controller: _editMessageController,
                                          maxLines: 10,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              updateGroupMessage(
                                                messageId: msg.messageId,
                                                newMessage:
                                                    _editMessageController.text,
                                              ).then((_) =>
                                                  Navigator.pop(context));
                                            },
                                            child: Text("Ok"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Cancel"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text("Edit"),
                                ),
                              if (msg.senderId == currentUser ||
                                  group.admin == currentUser)
                                TextButton(
                                  onPressed: () {
                                    deleteGroupMessage(
                                        messageId: msg.messageId);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Delete"),
                                ),
                            ],
                          ),
                        );
                      },
                      child: GroupChatMessage(
                        msg: msg,
                        currentUser: currentUser,
                        isImage: msg.isImage ?? false,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: secondary_color,
                  borderRadius: BorderRadius.circular(20)),
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
          )
        ],
      ),
    );
  }
}
