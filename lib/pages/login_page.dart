import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(254, 254, 255, 255),
      body: Column(
        children: [
          Expanded(child: Image.asset("assets/splashscreen_ui.png")),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome to Livecom :)",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Enter your phone number",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      hintText: "Phone number",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black))),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: 200,
                child: ElevatedButton(
                  child: Text('Send OTP'),
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
