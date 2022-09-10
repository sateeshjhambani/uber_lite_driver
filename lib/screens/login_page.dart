import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_lite_driver/screens/registration.dart';

import '../brand_colors.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/TaxiButton.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  void login() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Logging you in...'),
    );

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('drivers/${credential.user?.uid}');

      userRef.once().then(
            (value) => {
              Navigator.pushNamedAndRemoveUntil(
                  context, MainPage.id, (route) => false)
            },
          );
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(e.toString());
    }
  }

  // todo: remove when tested
  @override
  void initState() {
    emailController.text = 'testdriver02@gmail.com';
    passwordController.text = 'Password';
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
                  height: 70,
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
                  'Sign In as a Driver',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
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
                        title: 'Login',
                        color: BrandColors.colorAccentPurple,
                        onPressed: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No internet connectivity');
                          }

                          if (!emailController.text.contains('@')) {
                            showSnackBar(
                              'Please provide a valid email address',
                            );
                            return;
                          }

                          if (passwordController.text.length < 8) {
                            showSnackBar(
                              'Please provide a valid password',
                            );
                            return;
                          }

                          login();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RegistrationPage.id,
                      (route) => false,
                    );
                  },
                  child: Text('Don\'t  have an account, sign up here'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
