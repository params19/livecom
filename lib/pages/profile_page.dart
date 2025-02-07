import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, "/update");
            },
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/user.png"),
              backgroundColor: Colors.white,
            ),
            title: Text("User Name"),
            subtitle: Text("User Number"),
            trailing: Icon(Icons.edit_outlined),
          ),
          Divider(),
          ListTile(
            onTap: () {
              logOutUser();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (route) => false);
            },
            leading: Icon(Icons.logout_outlined),
            title: Text("Logout"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About"),
          ),
        ],
      ),
    );
  }
}
