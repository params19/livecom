import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/models/group_message_model.dart';
import 'package:livecom/models/groups_model.dart';

class GroupMessageProvider extends ChangeNotifier {
  List<GroupModel> _joinedGroups = [];
  Map<String, List<GroupMessageModel>>? _groupMessages = {};

  // read joined groups
  List<GroupModel> get getJoinedGroups => _joinedGroups;
  // read all group messages
  Map<String, List<GroupMessageModel>> get getGroupMessages =>
      _groupMessages ?? {};

  Timer? _debounce;

  loadAllGroupRequiredData(String userId) async {
    await loadAllGroupData(userId);
  }

  // read all the group , the current user is joined and then update it in provider
  loadAllGroupData(String userId) async {
    final results = await readAllGroups(currentUserId: userId);
    if (results != null) {
      _joinedGroups =
          results.documents.map((e) => GroupModel.fromMap(e.data)).toList();
    }
    notifyListeners();
  }

  // add group message
  addGroupMessage({required String groupId, required GroupMessageModel msg}) {
    try {
      _groupMessages![groupId]!.add(msg);
      notifyListeners();
    } catch (e) {
      print("Error on adding chats on provider");
    }
  }
}
