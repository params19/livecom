import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class ExploreChannels extends StatefulWidget {
  const ExploreChannels({super.key});

  @override
  State<ExploreChannels> createState() => _ExploreChannelsState();
}

class _ExploreChannelsState extends State<ExploreChannels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Channels"),
      ),
      body: FutureBuilder(
        future: getChannels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("No channels to show");
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        snapshot.data![index].data["image"] == "" ||
                                snapshot.data![index].data["image"] == null
                            ? AssetImage("assets/user.png")
                            : CachedNetworkImageProvider(
                                "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${snapshot.data![index].data["image"]}/view?project=67b7e512000635cad2ad&mode=admin",
                              ),
                  ),
                  title: Text(
                    snapshot.data![index].data["groupName"],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    snapshot.data![index].data["groupDesc"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Join Channel",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      await addUserToGroup(
                        groupId: snapshot.data![index].data["\$id"],
                        currentUser: Provider.of<UserDataProvider>(context,
                                listen: false)
                            .getUserId,
                      ).then((value) {
                        if (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Channel Joined Successfully."),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
