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
    // try to load the data from local database
    Future.delayed(Duration.zero, () {
      userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
      Provider.of<UserDataProvider>(context, listen: false)
          .loadUserData(userId!);
      imageId =
          Provider.of<UserDataProvider>(context, listen: false).getUserProfile;
    });

    super.initState();
  }

  // FilePickerResult? _filePickerResult;
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
              icon: Icon(Icons.arrow_back, color: Colors.black), // Back button
              onPressed: () {
                // Navigates back
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            title: Text(
              data_passed["title"] == "edit" ? "Update" : "Add Details",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 26,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        _openFilePicker();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 120,
                            backgroundImage: _filePickerResult != null
                                ? Image(
                                        image: FileImage(File(_filePickerResult!
                                            .files.first.path!)))
                                    .image
                                // : Image(image: AssetImage("assets/user.png"))
                                //     .image,
                                : value.getUserProfile != "" &&
                                        value.getUserProfile != null
                                    ? CachedNetworkImageProvider(
                                        "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${value.getUserProfile}/view?project=67b7e512000635cad2ad&mode=admin")
                                    : null,
                            backgroundColor: Colors.grey,
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: primary_purple,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Container(
                          decoration: BoxDecoration(
                            color: secondary_color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(6),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Form(
                            key: _nameKey,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Cannot be empty";
                                } else {
                                  return null;
                                }
                              },
                              controller: _nameController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter your Name"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Container(
                          decoration: BoxDecoration(
                            color: secondary_color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(6),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: TextFormField(
                            controller: _phoneController,
                            enabled: false,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Phone Number"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        print("Current image id is $imageId");
                        if (_nameKey.currentState!.validate()) {
                          // upload the image if file is picked
                          if (_filePickerResult != null) {
                            await uploadProfileImage();
                          }

                          // save the data to database user collection
                          await updateUserDetails(imageId ?? "",
                              userId: userId!, name: _nameController.text);

                          // // navigate the user to the home route
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/home", (route) => false);
                        }
                      },
                      child: Text(
                        data_passed["title"] == "edit" ? "Update" : "Continue",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary_purple,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  ]),
            ),
          ),
        );
      },
    );
  }
}
