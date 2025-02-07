import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        backgroundColor: background_color,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
        ),
        actions: [
          GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile"),
              child:
                  Consumer<UserDataProvider>(builder: (context, value, child) {
                return CircleAvatar(
                  backgroundImage: value.getUserProfile != null ||
                          value.getUserProfile != ""
                      ? CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/67a3d9aa002c49506451/files/${value.getUserProfile}/view?project=67a316ad003a50945b8b&mode=admin")
                      : Image(
                          image: AssetImage("assets/user.png"),
                        ).image,
                );
              }))
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/chat");
          },
          leading: Stack(children: [
            CircleAvatar(
              backgroundColor: background_color,
              backgroundImage: Image(
                image: AssetImage("assets/user.png"),
              ).image,
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.green,
              ),
            )
          ]),
          title: Text("Other User"),
          subtitle: Text("Hey there!"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                backgroundColor: primary_blue,
                radius: 10,
                child: Text(
                  "10",
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text("10:00 AM")
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.chat),
      ),
    );
  }
}
