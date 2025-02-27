import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/models/groups_model.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class CreateOrUpdateGroup extends StatefulWidget {
  const CreateOrUpdateGroup({super.key});

  @override
  State<CreateOrUpdateGroup> createState() => _CreateOrUpdateGroupState();
}

class _CreateOrUpdateGroupState extends State<CreateOrUpdateGroup> {
  final _groupKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _groupDescController = TextEditingController();
  late bool isPublic = true;

  late String? imageId = "";
  late String userId = "";

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
    super.initState();
  }

// to open file picker
  void _openFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _filePickerResult = result;
    });
  }

// upload user profile image and save it to bucket and database
  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file = _filePickerResult!.files.first;
        final fileByes = await File(file.path!).readAsBytes();
        final inputfile =
            InputFile.fromBytes(bytes: fileByes, filename: file.name);

        // if image already exist for the user profile or not
        if (imageId != null && imageId != "") {
          // then update the image
          await updateImageOnBucket(image: inputfile, oldImageId: imageId!)
              .then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        }

        // create new image and upload to bucket
        else {
          await saveImageToBucket(image: inputfile).then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        }
      } else {
        print("something went wrong");
      }
    } catch (e) {
      print("Error on uploading image :$e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GroupModel? existingData =
        ModalRoute.of(context)?.settings.arguments as GroupModel?;

    if (existingData != null) {
      _groupNameController.text = existingData.groupName ?? "No Name";
      _groupDescController.text = existingData.groupDesc ?? "";
      isPublic = existingData.isPublic;
    }
  }

  @override
  Widget build(BuildContext context) {
    GroupModel? existingData =
        ModalRoute.of(context)?.settings.arguments as GroupModel?;

    if (existingData != null) {
      _groupNameController.text = existingData.groupName ?? "";
      _groupDescController.text = existingData.groupDesc ?? "";
      isPublic = existingData.isPublic ?? true; 
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(existingData != null ? "Update Group" : "Create Group"),
      ),
      body: Form(
        key: _groupKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Group Image",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _openFilePicker(),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: secondary_color,
                            shape: BoxShape.circle,
                          ),
                          child: _filePickerResult != null
                              ? ClipOval(
                                  child: Image(
                                    image: FileImage(File(
                                        _filePickerResult!.files.first.path!)),
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                )
                              : existingData != null &&
                                      existingData.image != null &&
                                      existingData.image != ""
                                  ? ClipOval(
                                      child: Image(
                                        image: CachedNetworkImageProvider(
                                            "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${existingData.image}/view?project=67b7e512000635cad2ad&mode=admin"),
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 100,
                        child: GestureDetector(
                          onTap: () =>
                              _openFilePicker(), // Ensuring tap works on the edit button
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary_blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: secondary_color,
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) return "Cannot be empty";
                      return null;
                    },
                    controller: _groupNameController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Enter group name"),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: secondary_color,
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) return "Cannot be empty";
                      return null;
                    },
                    controller: _groupDescController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter group description"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Is Group Public?",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Switch(
                        value: isPublic,
                        onChanged: (value) {
                          isPublic = value;
                          setState(() {});
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        isPublic ? "Public" : "Private",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isPublic ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              if (_groupKey.currentState!.validate()) {
                if (_filePickerResult != null) {
                  await uploadProfileImage();
                }
                // updating the group
                if (existingData != null) {
                  await updateExistingGroup(
                          groupId: existingData.groupId ?? "",
                          groupName: _groupNameController.text,
                          groupDesc: _groupDescController.text,
                          image: imageId == null || imageId == ""
                              ? existingData.image ?? ""
                              : imageId ?? "",
                          isOpen: isPublic)
                      .then((value) {
                    if (value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Group Updated Successfully")));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Cannot Update Group")));
                    }
                  });
                }
                // for create a new group
                else {
                  await createNewGroup(
                          currentUser: userId,
                          groupName: _groupNameController.text,
                          groupDesc: _groupDescController.text,
                          image: imageId ?? "",
                          isOpen: isPublic)
                      .then((value) {
                    if (value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Group Created Successfully")));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Cannot Create Group")));
                    }
                  });
                }
              }
            },
            child: Text(existingData != null ? "Update Group" : "Create Group"),
            style: ElevatedButton.styleFrom(
                backgroundColor: primary_blue, foregroundColor: Colors.white),
          ),
        ),
      ),
    );
  }
}
