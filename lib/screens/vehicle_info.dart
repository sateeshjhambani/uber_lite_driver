import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_lite_driver/brand_colors.dart';
import 'package:uber_lite_driver/global_variables.dart';
import 'package:uber_lite_driver/screens/main_page.dart';

import '../widgets/ProgressDialog.dart';
import '../widgets/TaxiButton.dart';

class VehicleInfoPage extends StatefulWidget {
  static const String id = 'vehicleInfo';

  @override
  State<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  var carModelController = TextEditingController();

  var carColorController = TextEditingController();

  var vehicleNumberController = TextEditingController();

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

  void updateProfile() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Registering you...'),
    );

    String id = currentFirebaseUser != null ? currentFirebaseUser!.uid : '';
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child('drivers/$id/vehicle_details');

    Map map = {
      'car_color': carColorController.text,
      'car_model': carModelController.text,
      'vehicle_number': vehicleNumberController.text
    };
    driverRef.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'images/logo.png',
                height: 110,
                width: 110,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text('Enter vehicle details'),
                    SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Car Model',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carColorController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Car Color',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: vehicleNumberController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Vehicle Number',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    TaxiButton(
                      color: BrandColors.colorGreen,
                      title: 'Proceed',
                      onPressed: () async {
                        var connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (connectivityResult != ConnectivityResult.mobile &&
                            connectivityResult != ConnectivityResult.wifi) {
                          showSnackBar('No internet connectivity');
                        }

                        if (carModelController.text.length < 3) {
                          showSnackBar('Please provide a valid car model');
                          return;
                        }

                        if (carColorController.text.length < 3) {
                          showSnackBar('Please provide a valid car color');
                          return;
                        }

                        if (carModelController.text.length < 3) {
                          showSnackBar('Please provide a valid vehicle number');
                          return;
                        }

                        updateProfile();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
