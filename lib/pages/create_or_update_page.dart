import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  void _openFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _filePickerResult = result;
    });
  }

  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file = _filePickerResult!.files.first;
        final fileByes = await File(file.path!).readAsBytes();
        final inputfile =
            InputFile.fromBytes(bytes: fileByes, filename: file.name);

        if (imageId != null && imageId != "") {
          await updateImageOnBucket(image: inputfile, oldImageId: imageId!)
              .then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        } else {
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
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _groupKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _openFilePicker,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: secondary_color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary_purple,
                              width: 2,
                            ),
                          ),
                          child: _filePickerResult != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_filePickerResult!.files.first.path!),
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                              : existingData != null &&
                                      existingData.image != null &&
                                      existingData.image != ""
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${existingData.image}/view?project=67b7e512000635cad2ad&mode=admin",
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary_purple,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Group Name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: secondary_color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter group name",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Cannot be empty";
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Group Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: secondary_color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _groupDescController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter group description",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Cannot be empty";
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Is Group Public?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    Switch(
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                      activeColor: primary_purple,
                    ),
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
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_groupKey.currentState!.validate()) {
                        if (_filePickerResult != null) {
                          await uploadProfileImage();
                        }
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Group Updated Successfully")));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Cannot Update Group")));
                            }
                          });
                        } else {
                          await createNewGroup(
                                  currentUser: userId,
                                  groupName: _groupNameController.text,
                                  groupDesc: _groupDescController.text,
                                  image: imageId ?? "",
                                  isOpen: isPublic)
                              .then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Group Created Successfully")));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Cannot Create Group")));
                            }
                          });
                        }
                      }
                    },
                    child: Text(
                      existingData != null ? "Update Group" : "Create Group",
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_purple,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
