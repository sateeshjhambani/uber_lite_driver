import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_lite_driver/global_variables.dart';
import 'package:uber_lite_driver/screens/login_page.dart';
import 'package:uber_lite_driver/screens/main_page.dart';
import 'package:uber_lite_driver/screens/registration.dart';
import 'package:uber_lite_driver/screens/vehicle_info.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  currentFirebaseUser = FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Brand-Regular',
        primarySwatch: Colors.blue,
      ),
      initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
      routes: {
        LoginPage.id: (context) => LoginPage(),
        RegistrationPage.id: (context) => RegistrationPage(),
        VehicleInfoPage.id: (context) => VehicleInfoPage(),
        MainPage.id: (context) => MainPage(),
      },
    );
  }
}
