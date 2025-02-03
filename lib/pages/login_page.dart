import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';

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

  String countryCode = "+91";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(254, 254, 255, 255),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                "assets/splashscreen_ui.png",
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome to Livecom :)",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("Enter your phone number",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.length != 10) {
                          return "Please enter a valid phone number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: CountryCodePicker(
                            onChanged: (value) {
                              print(value.dialCode);
                              countryCode = value.dialCode!;
                            },
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                          ),
                          hintText: "Phone number",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primary_blue))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text('Send OTP'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print("Validated");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primary_blue,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
