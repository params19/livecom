import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';

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
          CircleAvatar(
            backgroundColor: background_color,
            backgroundImage: Image(
              image: AssetImage("assets/user.png"),
            ).image,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          leading: Stack(children: [
            CircleAvatar(
              backgroundColor: background_color,
              backgroundImage: Image(
                image: AssetImage("assets/user.png"),
              ).image,
            ),
            Positioned(
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
        ),
      ),
    );
  }
}
