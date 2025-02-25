import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);

  // handle the search
  void _handleSearch() {
    searchUsers(
      searchItem: _searchController.text,
      userId: Provider.of<UserDataProvider>(context, listen: false).getUserId,
    ).then((value) {
      if (value != null) {
        setState(() {
          searchedUsers = value;
        });
      } else {
        setState(() {
          searchedUsers = DocumentList(total: 0, documents: []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Users",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _handleSearch(),
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _handleSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.black), // Default border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.black), // Border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.black, width: 2), // Border when focused
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/modify_group",
                  );
                },
                leading: Icon(Icons.group_add_outlined),
                title: Text("Create new group"),
                trailing: Icon(
                  Icons
                      .arrow_forward_ios, // Add an arrow for navigation indication
                  color: Colors.grey, // Subtle arrow color
                  size: 18,
                ),
              )
            ],
          ),
        ),
      ),
      body: searchedUsers.total == -1
          ? Center(
              child: Text("Use the search box to search users."),
            )
          : searchedUsers.total == 0
              ? Center(
                  child: Text("No users found"),
                )
              : ListView.builder(
                  itemCount: searchedUsers.documents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/chat",
                            arguments: UserData.toMap(
                                searchedUsers.documents[index].data));
                      },
                      leading: CircleAvatar(
                        backgroundImage: searchedUsers
                                        .documents[index].data["profilePic"] !=
                                    null &&
                                searchedUsers
                                        .documents[index].data["profilePic"] !=
                                    ""
                            ? NetworkImage(
                                "https://cloud.appwrite.io/v1/storage/buckets/67a3d9aa002c49506451/files/${searchedUsers.documents[index].data["profilePic"]}/view?project=67a316ad003a50945b8b&mode=admin")
                            : Image(image: AssetImage("assets/user.png")).image,
                      ),
                      title: Text(searchedUsers.documents[index].data["name"] ??
                          "No Name"),
                      subtitle: Text(
                          searchedUsers.documents[index].data["phone"] ?? ""),
                    );
                  },
                ),
    );
  }
}
