import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:livecom/constants/chat_message.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/models/message_model.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/providers/chat_provider.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class ChatPage extends StatefulWidget {
  // final List<MessageModel> messages;

  // // Constructor to receive messages
  // ChatPage({required this.messages});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();

  late String currentUserId;
  late String currentUserName;

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    // TODO: implement initState
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;

    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    super.initState();
  }

  // to open file picker
  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  // to upload files to our storage bucket and our database
  void uploadAllImage(UserData receiver) async {
    if (_filePickerResult != null) {
      _filePickerResult!.paths.forEach((path) {
        if (path != null) {
          var file = io.File(path);
          final fileBytes = file.readAsBytesSync();
          final inputfile = InputFile.fromBytes(
              bytes: fileBytes, filename: file.path.split("/").last);

          // saving image to our storage bucket
          saveImageToBucket(image: inputfile).then((imageId) {
            if (imageId != null) {
              createNewChat(
                message: imageId,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: true,
                isGroupInvite: false,
              ).then((value) {
                if (value) {
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(
                        message: imageId,
                        sender: currentUserId,
                        receiver: receiver.userId,
                        timestamp: DateTime.now(),
                        isSeenByReceiver: false,
                        isImage: true,
                      ),
                      currentUserId,
                      [UserData(phone: "", userId: currentUserId), receiver]);
                }
              });
            }
          });
        }
      });
    } else {
      print("File pick cancelled by user");
    }
  }

// to send simple text message
  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: false,
                isGroupInvite: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                MessageModel(
                  message: messageController.text,
                  sender: currentUserId,
                  receiver: receiver.userId,
                  timestamp: DateTime.now(),
                  isSeenByReceiver: false,
                ),
                currentUserId,
                [UserData(phone: "", userId: currentUserId), receiver]);

            messageController.clear();
          }
        });
      });
    }
  }

  Future<void> editMessage() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextFormField(
            controller: editmessageController,
            maxLines: 10,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Add your edit message logic here
                Navigator.pop(context);
              },
              child: Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;

    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        List<String> receiverMsgList = [];
        // get all the messages that are not seen by the receiver
        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              receiverMsgList.add(chat.message.messageId!);
            }
          }
        }
        updateIsSeen(chatsIds: receiverMsgList);
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
                // CircleAvatar(
                //   backgroundImage: receiver.profilePic == null ||
                //           (receiver.profilePic?.isEmpty ?? true)
                //       ? Image(
                //           image: AssetImage("assets/user.png"),
                //         ).image
                //       : CachedNetworkImageProvider(
                //           "https://cloud.appwrite.io/v1/storage/buckets/67a3d9aa002c49506451/files/${receiver.profilePic}/view?project=67a316ad003a50945b8b&mode=admin"),
                // ),
                CircleAvatar(
                  backgroundImage: receiver.profilePic == null ||
                          (receiver.profilePic?.isEmpty ?? true)
                      ? AssetImage("assets/user.png")
                      : CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${receiver.profilePic}/view?project=67b7e512000635cad2ad&mode=admin",
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
                      receiver.name!,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      otherUserOnline == true ? "Online" : "Offline",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                      reverse: true,
                      itemCount: userAndOtherChats.length,
                      itemBuilder: (context, index) {
                        final msg = userAndOtherChats[
                                userAndOtherChats.length - 1 - index]
                            .message;

                        print("User Chats :${userAndOtherChats.length}");

                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: msg.isImage == true
                                    ? Text(msg.sender == currentUserId
                                        ? "Choose what you want to do with this image."
                                        : "This image cant be modified")
                                    : Text(
                                        "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ..."),
                                content: msg.isImage == true
                                    ? Text(msg.sender == currentUserId
                                        ? 'Delete this image'
                                        : 'This image cant be delted')
                                    : Text(msg.sender == currentUserId
                                        ? 'Choose what you want to do with this message.'
                                        : 'This message cant be modified'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel")),
                                  msg.sender == currentUserId
                                      ? TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            editmessageController.text =
                                                msg.message;

                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text(
                                                          "Edit this message"),
                                                      content: TextFormField(
                                                        controller:
                                                            editmessageController,
                                                        maxLines: 10,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              editChat(
                                                                chatId: msg
                                                                    .messageId!,
                                                                message:
                                                                    editmessageController
                                                                        .text,
                                                              );
                                                              Navigator.pop(
                                                                  context);
                                                              editmessageController
                                                                  .text = "";
                                                            },
                                                            child: Text("Ok")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("Cancel")),
                                                      ],
                                                    ));
                                          },
                                          child: Text("Edit"))
                                      : SizedBox(),
                                  msg.sender == currentUserId
                                      ? TextButton(
                                          onPressed: () {
                                            Provider.of<ChatProvider>(context,
                                                    listen: false)
                                                .deleteMessage(
                                                    msg, currentUserId);

                                            Navigator.pop(context);
                                          },
                                          child: Text("Delete"))
                                      : SizedBox(),
                                ],
                              ),
                            );
                          },
                          child: ChatMessage(
                            isImage: msg.isImage ?? false,
                            message: msg,
                            currentUserId: currentUserId,
                          ),
                        );
                      }),
                ),
              ),
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
                          onSubmitted: (_) {
                            _sendMessage(receiver: receiver);
                          },
                          controller: messageController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type a message..."),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            _openFilePicker(receiver);
                          },
                          icon: Icon(Icons.image)),
                      IconButton(
                          onPressed: () {
                            _sendMessage(receiver: receiver);
                          },
                          icon: Icon(Icons.send))
                    ],
                  ))
            ],
          ),
        );
      },
    );
  }
}
