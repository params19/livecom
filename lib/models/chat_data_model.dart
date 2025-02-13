import 'package:livecom/models/message_model.dart';
import 'package:livecom/models/user_model.dart';

class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;

  ChatDataModel({required this.message, required this.users});
}