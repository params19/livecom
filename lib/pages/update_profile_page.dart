import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';

class UpadteProfilePage extends StatefulWidget {
  const UpadteProfilePage({super.key});

  @override
  State<UpadteProfilePage> createState() => _UpadteProfilePageState();
}

class _UpadteProfilePageState extends State<UpadteProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 120,
                  backgroundImage:
                      Image(image: AssetImage("assets/user.png")).image,
                  backgroundColor: Colors.white,
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary_blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                      ),
                    ))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.all(6),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Expanded(
                  child: TextFormField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Enter your Name"),
              )),
            )
          ]),
    );
  }
}
