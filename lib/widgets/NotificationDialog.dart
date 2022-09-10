import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_lite_driver/brand_colors.dart';
import 'package:uber_lite_driver/global_variables.dart';
import 'package:uber_lite_driver/helpers/helper_methods.dart';
import 'package:uber_lite_driver/screens/new_trip_page.dart';
import 'package:uber_lite_driver/widgets/BrandDivider.dart';
import 'package:uber_lite_driver/widgets/TaxiButton.dart';

import '../dataModels/trip_details.dart';
import 'ProgressDialog.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetails tripDetails;

  NotificationDialog({required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'images/taxi.png',
              width: 100,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'NEW TRIP REQUEST',
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.pickupAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.destinationAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'Decline',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'Accept',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailability(context);
                        },
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

  void checkAvailability(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Accepting request...'),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser?.uid}/newTrip');
    newRideRef.once().then((value) {
      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideID = '';
      if (value.snapshot.value != null) {
        thisRideID = value.snapshot.value.toString();
      }

      if (thisRideID == tripDetails.rideId) {
        newRideRef.set('accepted');
        HelperMethods.disableHomeTabLocationUpdates();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewTripPage(
              tripDetails: tripDetails,
            ),
          ),
        );
      } else if (thisRideID == 'cancelled') {
        showSnackbar('Ride has been cancelled', context);
      } else if (thisRideID == 'timeout') {
        showSnackbar('Ride has timed out', context);
      } else {
        showSnackbar('Ride not found', context);
      }
    });
  }

  void showSnackbar(String title, context) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
