import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_lite_driver/global_variables.dart';
import 'package:uber_lite_driver/screens/vehicle_info.dart';

import '../brand_colors.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/TaxiButton.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void registerUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Registering you...'),
    );

    UserCredential res;
    try {
      res = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      DatabaseReference newUserRef =
          FirebaseDatabase.instance.ref().child('drivers/${res.user?.uid}');

      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };

      newUserRef.set(userMap);

      currentFirebaseUser = res.user!;
      Navigator.pushNamed(context, VehicleInfoPage.id);
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Image(
                  image: AssetImage('images/logo.png'),
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Create a Driver\'s Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(fontSize: 14),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10)),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(fontSize: 14),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10)),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(fontSize: 14),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10)),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(fontSize: 14),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10)),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TaxiButton(
                        title: 'Register',
                        color: BrandColors.colorAccentPurple,
                        onPressed: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No internet connectivity');
                          }

                          if (fullNameController.text.length < 3) {
                            showSnackBar('Please provide a valid full name');
                            return;
                          }

                          if (!emailController.text.contains('@')) {
                            showSnackBar(
                                'Please provide a valid email address');
                            return;
                          }

                          if (phoneController.text.length < 10) {
                            showSnackBar('Please provide a valid phone number');
                            return;
                          }

                          if (passwordController.text.length < 8) {
                            showSnackBar('Please provide a valid password');
                            return;
                          }

                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginPage.id,
                      (route) => false,
                    );
                  },
                  child: Text('Already have a Driver account? Log in'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
