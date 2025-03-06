import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/pages/profile_page.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class UpadteProfilePage extends StatefulWidget {
  const UpadteProfilePage({super.key});

  @override
  State<UpadteProfilePage> createState() => _UpadteProfilePageState();
}

class _UpadteProfilePageState extends State<UpadteProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  FilePickerResult? _filePickerResult;
  late String? imageId = "";
  late String? userId = "";

  final _nameKey = GlobalKey<FormState>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
      Provider.of<UserDataProvider>(context, listen: false)
          .loadUserData(userId!);
      imageId =
          Provider.of<UserDataProvider>(context, listen: false).getUserProfile;
    });
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
        print("Something went wrong");
      }
    } catch (e) {
      print("Error on uploading image :$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final data_passed =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    return Consumer<UserDataProvider>(
      builder: (context, value, child) {
        _nameController.text = value.getUserName;
        _phoneController.text = value.getUserNumber;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            title: Text(
              data_passed["title"] == "edit" ? "Update Profile" : "Add Details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _openFilePicker,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: secondary_color,
                          backgroundImage: _filePickerResult != null
                              ? Image.file(File(
                                      _filePickerResult!.files.first.path!))
                                  .image
                              : value.getUserProfile != "" &&
                                      value.getUserProfile != null
                                  ? CachedNetworkImageProvider(
                                      "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${value.getUserProfile}/view?project=67b7e512000635cad2ad&mode=admin")
                                  : null,
                          child: value.getUserProfile == "" ||
                                  value.getUserProfile == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
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
                  SizedBox(height: 30),
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: secondary_color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your name",
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
                    "Phone Number",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: secondary_color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone Number",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (_nameKey.currentState!.validate()) {
                        if (_filePickerResult != null) {
                          await uploadProfileImage();
                        }
                        await updateUserDetails(imageId ?? "",
                            userId: userId!, name: _nameController.text);
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (route) => false);
                      }
                    },
                    child: Text(
                      data_passed["title"] == "edit"
                          ? "Update Profile"
                          : "Continue",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_purple,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
