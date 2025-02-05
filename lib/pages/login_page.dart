import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';

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

  // ✅ Save phone number to the database
  void handleOTPSubmit(String userId, BuildContext context) {
    if (_otpKey.currentState!.validate()) {
      loginWithOTP(userId: userId, otp: _otpController.text).then((value) {
        if (value) {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error in login with OTP")),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(254, 254, 255, 255),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Livecom :)",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your phone number to continue",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
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
                        countryCode = value.dialCode!;
                      },
                      initialSelection: 'IN',
                      favorite: ['+91', 'IN'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                    ),
                    labelText: "Phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: 160,
                child: ElevatedButton(
                  child: const Text('Send OTP'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createPhoneSession(
                              phoneNumber: countryCode + _phoneController.text)
                          .then((value) {
                        if (value == "error") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error in sending OTP")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("OTP sent successfully")),
                          );

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Center(
                                child: Text(
                                  "OTP Verification",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Enter 6 digit OTP",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 15),
                                  Form(
                                    key: _otpKey,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.length != 6) {
                                          return "Please enter a valid OTP";
                                        }
                                        return null;
                                      },
                                      controller: _otpController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        labelText: "Enter the OTP here",
                                        labelStyle: TextStyle(fontSize: 13),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide:
                                              BorderSide(color: primary_blue),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    print("OTP SENT");
                                    handleOTPSubmit(value, context);
                                  },
                                  child: Text("Submit"),
                                )
                              ],
                            ),
                          );
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
