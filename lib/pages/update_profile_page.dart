import 'dart:io';

import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
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

  @override
  void initState() {
    //load krdo data ko
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    });
    // Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    super.initState();
  }

  // FilePickerResult? _filePickerResult;
  void _openFilePicker() async {
    _filePickerResult = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _filePickerResult = _filePickerResult;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data_passed =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
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
                          child: Expanded(
                              child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your Name"),
                          )),
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
                      onPressed: () {
                        // Navigator.pop(context);
                      },
                      child: Text("Update"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary_blue,
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
