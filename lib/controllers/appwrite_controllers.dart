import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:livecom/main.dart';
import 'package:livecom/models/chat_data_model.dart';
import 'package:livecom/models/group_message_model.dart';
import 'package:livecom/models/message_model.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/providers/chat_provider.dart';
import 'package:livecom/providers/group_message_provider.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

const String db = "67b7e7d800060607c3e4";
const String userCollection = "67b7e7e2003adb6ed544";
const String storageBucket = "67b7f7a000142a335f4e";
const String chat_collection = "67b89a320017cbd53479";
const String groupCollection = "67bd4729000f69af4142";
const String groupMessageCollection = "67bd48dd0007b2eec3ea";

Client client = Client()
  ..setEndpoint("https://cloud.appwrite.io/v1")
  ..setProject('67b7e512000635cad2ad')
  ..setSelfSigned(status: true);

// ✅ Use client for services
Account account = Account(client);
final Databases database = Databases(client);
final Storage storage = Storage(client);
final Realtime realtime = Realtime(client);

RealtimeSubscription? chatSubscription;
// for the realtime chat subscription
RealtimeSubscription? subscription;
RealtimeSubscription? groupMsgSubscription;
// to subscribe to realtime changes
subscribeToRealtime({required String userId}) {
  subscription = realtime.subscribe([
    "databases.$db.collections.$chat_collection.documents",
    "databases.$db.collections.$userCollection.documents"
  ]);

  print("Subscribing to realtime");

  subscription!.stream.listen((data) {
    print("Some event happend");
    // print(data.events);
    // print(data.payload);
    final firstItem = data.events[0].split(".");
    final eventType = firstItem[firstItem.length - 1];
    print("Event type is $eventType");
    if (eventType == "create") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    } else if (eventType == "update") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    } else if (eventType == "delete") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    }
  });
}

// Save phone number to the database
Future<bool> savePhoneToDB(
    {required String phoneNumber, required String userId}) async {
  try {
    await database.createDocument(
      databaseId: db,
      collectionId: userCollection,
      documentId: userId,
      data: {'phone': phoneNumber, 'userId': userId},
    );
    print("Phone number saved successfully!");
    return true;
  } on AppwriteException catch (e) {
    print("Error: $e");
    return false;
  }
}

// Check if phone number exists in the database
Future<String> doesPhoneNumberExist(String phoneNumber) async {
  try {
    final DocumentList match = await database.listDocuments(
      databaseId: db,
      collectionId: userCollection,
      queries: [Query.equal("phone", phoneNumber)],
    );
    if (match.documents.isNotEmpty) {
      final Document doc = match.documents.first;
      if (doc.data['phone'] != null || doc.data['phone'] != "") {
        return doc.data['userId'];
      } else {
        print("Phone number not found!");
        return "user_not_found";
      }
    } else {
      print("Phone number not found!");
      return "user_not_found";
    }
  } on AppwriteException catch (e) {
    print("Error on reading DB $e");
    return "user_not_found";
  }
}

//Pjpne number authentication
Future<String> createPhoneSession({required String phoneNumber}) async {
  try {
    final userId = await doesPhoneNumberExist(phoneNumber);
    if (userId == "user_not_found") {
      final Token data = await account.createPhoneToken(
          userId: ID.unique(), phone: phoneNumber);
      await savePhoneToDB(phoneNumber: phoneNumber, userId: data.userId);
      return data.userId;
    } else {
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phoneNumber);
      return data.userId;
    }
  } catch (e) {
    print("Login error $e");
    return "error";
  }
}

//Login with OTP
Future<bool> loginWithOTP({required String userId, required String otp}) async {
  try {
    final Session session = await account.createSession(
      userId: userId,
      secret: otp,
    );
    print(session.userId);
    print("Login successful with OTP!");
    return true;
  } catch (e) {
    print("Login error using OTP: $e");
    return false;
  }
}

//to check whether the session exist or not
Future<bool> checkSessions() async {
  try {
    final Session session = await account.getSession(sessionId: "current");
    print("Session exist ${session.userId}");
    return true;
  } catch (e) {
    print("Session does not exist $e");
    return false;
  }
}

//to save the user details to the database
Future<bool> savePhoneToDb(
    {required String phoneno, required String userId}) async {
  try {
    final response = await database.createDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"phone": phoneno, "userId": userId});

    print(response);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to user database :$e");
    return false;
  }
}

//Logging out the user
Future logOutUser() async {
  await account.deleteSession(sessionId: "current");
}

//To get the user details
Future<UserData?> getUserDetails({required String userId}) async {
  try {
    final response = await database.getDocument(
        databaseId: db, collectionId: userCollection, documentId: userId);
    print("getting user data ");
    print(response.data);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(response.data["name"] ?? "");
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(response.data["profilePic"] ?? "");
    return UserData.toMap(response.data);
  } catch (e) {
    print("error in getting user data :$e");
    return null;
  }
}

//To update the user details
Future<bool> updateUserDetails(
  String pic, {
  required String userId,
  required String name,
}) async {
  try {
    final data = await database.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"name": name, "profilePic": pic});

    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(name);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(pic);
    print(data);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to DB :$e");
    return false;
  }
}

// save image to the storage bucket
Future<String?> saveImageToBucket({required InputFile image}) async {
  try {
    final response = await storage.createFile(
        bucketId: storageBucket, fileId: ID.unique(), file: image);
    print("The response after save to bucket $response");
    return response.$id;
  } catch (e) {
    print("Error on saving image to bucket :$e");
    return null;
  }
}

// update an image in bucket : first delete then create new
Future<String?> updateImageOnBucket(
    {required String oldImageId, required InputFile image}) async {
  try {
    // to delete the old image
    deleteImagefromBucket(oldImageId: oldImageId);

    // create a new image
    final newImage = saveImageToBucket(image: image);

    return newImage;
  } catch (e) {
    print("Cannot Update / Delete image :$e");
    return null;
  }
}

// to only delete the image from the storage bucket
Future<bool> deleteImagefromBucket({required String oldImageId}) async {
  try {
    // to delete the old image
    await storage.deleteFile(bucketId: storageBucket, fileId: oldImageId);
    return true;
  } catch (e) {
    print("Cannot Update / Delete image :$e");
    return false;
  }
}

// search users
Future<DocumentList?> searchUsers(
    {required String searchItem, required String userId}) async {
  try {
    final DocumentList users = await database.listDocuments(
        databaseId: db,
        collectionId: userCollection,
        queries: [
          Query.search("phone", searchItem),
          Query.notEqual("userId", userId)
        ]);

    print("Total Match Users ${users.total}");
    return users;
  } catch (e) {
    print("Error on Search Users :$e");
    return null;
  }
}

// to create a new chat and save to DB
Future createNewChat(
    {required String message,
    required String senderId,
    required String receiverId,
    required bool isImage,
    required bool isGroupInvite}) async {
  try {
    final msg = await database.createDocument(
        databaseId: db,
        collectionId: chat_collection,
        documentId: ID.unique(),
        data: {
          "message": message,
          "senderId": senderId,
          "receiverId": receiverId,
          "timeStamp": DateTime.now().toIso8601String(),
          "isSeenbyReceiver": false,
          "isImage": isImage,
          "userData": [senderId, receiverId],
          "isGroupInvite": isGroupInvite
        });

    print("Message Send !");
    return true;
  } catch (e) {
    print("Failed to Send Message :$e");
    return false;
  }
}

// to edit the chat message and update in the database
Future editChat({
  required String chatId,
  required String message,
}) async {
  try {
    await database.updateDocument(
        databaseId: db,
        collectionId: chat_collection,
        documentId: chatId,
        data: {"message": message});
    print("Message updated");
  } catch (e) {
    print("Error on editing message :$e");
  }
}

// to delete the chat message from the database
Future updateIsSeen({required List<String> chatsIds}) async {
  try {
    for (var chatid in chatsIds) {
      await database.updateDocument(
          databaseId: db,
          collectionId: chat_collection,
          documentId: chatid,
          data: {"isSeenbyReceiver": true});
      print("Update is seen");
    }
  } catch (e) {
    print("Error in update isseen :$e");
  }
}

// to update the online status

Future<void> updateOnlineStatus({
  required bool status,
  required String userId,
}) async {
  print(
      "updateOnlineStatus function called with status: $status, userId: $userId");

  try {
    await database.updateDocument(
      databaseId: db,
      collectionId: userCollection,
      documentId: userId,
      data: {"isOnline": status},
    );
    print("Updated user online status: $status");
  } catch (e) {
    print("Unable to update online status: $e");
  }
}

// to list all the chats belonging to the current user
Future<Map<String, List<ChatDataModel>>?> currentUserChats(
    String userId) async {
  try {
    var results = await database
        .listDocuments(databaseId: db, collectionId: chat_collection, queries: [
      Query.or(
          [Query.equal("senderId", userId), Query.equal("receiverId", userId)]),
      Query.orderDesc("timeStamp"),
      Query.limit(2000)
    ]);

    final DocumentList chatDocuments = results;

    print(
        "Chat Documents ${chatDocuments.total} and Documents ${chatDocuments.documents.length}");
    Map<String, List<ChatDataModel>> chats = {};

    if (chatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < chatDocuments.documents.length; i++) {
        var doc = chatDocuments.documents[i];
        String sender = doc.data["senderId"];
        String receiver = doc.data["receiverId"];

        MessageModel message = MessageModel.fromMap(doc.data);

        List<UserData> users = [];
        for (var user in doc.data["userData"]) {
          users.add(UserData.toMap(user));
        }

        String key = (sender == userId) ? receiver : sender;

        if (chats[key] == null) {
          chats[key] = [];
        }
        chats[key]!.add(ChatDataModel(message: message, users: users));
      }
    }

    return chats;
  } catch (e) {
    print("Error in Reading Current User chats :$e");
    return null;
  }
}

// to delete the chat from database chat collection
Future deleteCurrentUserChat({required String chatId}) async {
  try {
    await database.deleteDocument(
        databaseId: db, collectionId: chat_collection, documentId: chatId);
  } catch (e) {
    print("Error on Deleting chat message : $e");
  }
}

// to save users device token to user collection
Future saveUserDeviceToken(String token, String userId) async {
  try {
    await database.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"deviceToken": token});
    print("Device token saved to db");

    return true;
  } catch (e) {
    print("Cannot save device token :$e");
    return false;
  }
}

// to send notification to other user
Future sendNotificationtoOtherUser({
  required String notificationTitle,
  required String notificationBody,
  required String deviceToken,
}) async {
  try {
    print("sending notification");
    final Map<String, dynamic> body = {
      "deviceToken": deviceToken,
      "message": {"title": notificationTitle, "body": notificationBody},
    };

    final response = await http.post(
        Uri.parse("https://67bca59d4c806ce9da08.appwrite.global/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      print("Notification send to other user");
    }
  } catch (e) {
    print("Notification cannot be sent");
  }
}

// Group Functions
// create a new group
Future<bool> createNewGroup(
    {required String currentUser,
    required String groupName,
    required String groupDesc,
    bool? isOpen,
    required String image}) async {
  try {
    await database.createDocument(
        databaseId: db,
        collectionId: groupCollection,
        documentId: ID.unique(),
        data: {
          "admin": currentUser,
          "groupName": groupName,
          "groupDesc": groupDesc,
          "image": image,
          "isPublic": isOpen,
          "members": [currentUser],
          "userData": [currentUser]
        });
    return true;
  } catch (e) {
    print("Failed to create new group $e");
    return false;
  }
}

// to get all the groups of the current user
Future<bool> updateExistingGroup(
    {required String groupId,
    required String groupName,
    required String groupDesc,
    bool? isOpen,
    required String image}) async {
  try {
    await database.updateDocument(
        databaseId: db,
        collectionId: groupCollection,
        documentId: groupId,
        data: {
          "groupName": groupName,
          "groupDesc": groupDesc,
          "image": image,
          "isPublic": isOpen,
        });
    return true;
  } catch (e) {
    print("Failed to update the group $e");
    return false;
  }
}

// read all the groups current user is joined now.
Future<DocumentList?> readAllGroups({required String currentUserId}) async {
  try {
    var result = await database.listDocuments(
        databaseId: db,
        collectionId: groupCollection,
        queries: [Query.equal("members", currentUserId), Query.limit(100)]);

    return result;
  } catch (e) {
    print("Error on reading group $e");
    return null;
  }
}

// send a message to the group
Future<bool> sendGroupMessage(
    {required String groupId,
    required String message,
    required String senderId,
    bool? isImage}) async {
  try {
    await database.createDocument(
        databaseId: db,
        collectionId: groupMessageCollection,
        documentId: ID.unique(),
        data: {
          "groupId": groupId,
          "message": message,
          "senderId": senderId,
          "timeStamp": DateTime.now().toIso8601String(),
          "isImage": isImage ?? false,
          "userData": [senderId]
        });
    return true;
  } catch (e) {
    print("Error on sending group message ");
    return false;
  }
}

// update the group message
Future<bool> updateGroupMessage(
    {required String messageId, required String newMessage}) async {
  try {
    await database.updateDocument(
        databaseId: db,
        collectionId: groupMessageCollection,
        documentId: messageId,
        data: {"message": newMessage});
    return true;
  } catch (e) {
    print("Error on updating group chat :$e");
    return false;
  }
}

// delete the specific group message
Future deleteGroupMessage({required String messageId}) async {
  try {
    await database.deleteDocument(
        databaseId: db,
        collectionId: groupMessageCollection,
        documentId: messageId);
  } catch (e) {
    print("Error in deleting group message :$e");
  }
}

// reading all the group messages
Future<Map<String, List<GroupMessageModel>>?> readGroupMessages(
    {required List<String> groupIds}) async {
  try {
    var results = await database.listDocuments(
        databaseId: db,
        collectionId: groupMessageCollection,
        queries: [
          Query.equal("groupId", groupIds),
          Query.orderDesc("timeStamp"),
          Query.limit(2000)
        ]);

    final DocumentList groupChatDocuments = results;

    Map<String, List<GroupMessageModel>> chats = {};

    if (groupChatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < groupChatDocuments.documents.length; i++) {
        var doc = groupChatDocuments.documents[i];

        GroupMessageModel message = GroupMessageModel.fromMap(doc.data);
        String groupId = doc.data["groupId"];

        String key = groupId;

        if (chats[key] == null) {
          chats[key] = [];
        }
        chats[key]!.add(message);
      }
    }

    print("Loaded chats ${chats.length}");

    return chats;
  } catch (e) {
    print("Error in reading group chat messages :$e");
    return null;
  }
}

// to add the user to the specific group
Future<bool> addUserToGroup(
    {required String groupId, required String currentUser}) async {
  try {
    //  read the group members first
    final result = await database.getDocument(
        databaseId: db,
        collectionId: groupCollection,
        documentId: groupId,
        queries: [
          Query.select(["members"])
        ]);

    List existingMembers = result.data["members"];

    if (!existingMembers.contains(currentUser)) {
      existingMembers.add(currentUser);
    }

    //  update the document of the specific group
    await database.updateDocument(
        databaseId: db,
        collectionId: groupCollection,
        documentId: groupId,
        data: {"members": existingMembers, "userData": existingMembers});
    return true;
  } catch (e) {
    print("Error on joining group :$e");
    return false;
  }
}

// to subscribe to realtime changes
subscribeToRealtimeGroupMsg({required String userId}) {
  subscription = realtime.subscribe([
    "databases.$db.collections.$groupCollection.documents",
    "databases.$db.collections.$groupMessageCollection.documents"
  ]);

  print("Subscribing to realtime");

  subscription!.stream.listen((data) {
    print("Some event happend");
    // print(data.events);
    // print(data.payload);
    final firstItem = data.events[0].split(".");
    final eventType = firstItem[firstItem.length - 1];
    print("event type is $eventType");
    if (eventType == "create") {
      Provider.of<GroupMessageProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadAllGroupRequiredData(userId);
    } else if (eventType == "update") {
      Provider.of<GroupMessageProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadAllGroupRequiredData(userId);
    } else if (eventType == "delete") {
      Provider.of<GroupMessageProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadAllGroupRequiredData(userId);
    }
  });
}
