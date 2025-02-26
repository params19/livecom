import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/memberCalculate.dart';
import 'package:livecom/models/groups_model.dart';

class GroupDetails extends StatefulWidget {
  const GroupDetails({super.key});

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  @override
  Widget build(BuildContext context) {
    final GroupModel groupData =
        ModalRoute.of(context)!.settings.arguments as GroupModel;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: background_color,
        leadingWidth: 40,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage:
                  groupData.image == null || groupData.image!.isEmpty
                      ? AssetImage("assets/user.png")
                      : CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${groupData.image}/view?project=67b7e512000635cad2ad&mode=admin",
                        ) as ImageProvider,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupData.groupName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  memCal(groupData.members.length),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Description :"),
            Text(
              groupData.groupDesc?.isNotEmpty == true
                  ? groupData.groupDesc!
                  : "No description available",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Divider(),
            _buildSectionTitle("Members :"),
            Expanded(
              child: ListView.builder(
                itemCount: groupData.userData.length,
                itemBuilder: (context, index) {
                  var e = groupData.userData[index];
                  return _buildMemberCard(
                    name: e.name ?? "No Name",
                    role: e.userId == groupData.admin ? "Admin" : "Member",
                    profilePic: e.profilePic,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMemberCard(
      {required String name, required String role, String? profilePic}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: profilePic == null || profilePic.isEmpty
              ? AssetImage("assets/user.png")
              : CachedNetworkImageProvider(
                  "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/$profilePic/view?project=67b7e512000635cad2ad&mode=admin",
                ) as ImageProvider,
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          role,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }
}
