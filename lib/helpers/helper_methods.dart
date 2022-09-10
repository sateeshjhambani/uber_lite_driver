import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_lite_driver/helpers/request_helper.dart';

import '../dataModels/direction_details.dart';
import '../global_variables.dart';
import '../widgets/ProgressDialog.dart';

class HelperMethods {
  static Future<DirectionDetails?> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKeyWithBilling';

    var response = await RequestHelper.getRequest(url);
    if (response == 'failed' || response['status'] != 'OK') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(
        distanceText: response['routes'][0]['legs'][0]['distance']['text'],
        distanceValue: response['routes'][0]['legs'][0]['distance']['value'],
        durationText: response['routes'][0]['legs'][0]['duration']['text'],
        durationValue: response['routes'][0]['legs'][0]['duration']['value'],
        encodedPoints: response['routes'][0]['overview_polyline']['points']);

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details, int durationValue) {
    // per KM = $1,
    // per min = $0.5,
    // base fare = $3

    double baseFare = 3;
    double distanceFare = (details.distanceValue / 1000) * 1;
    double timeFare = (durationValue / 60) * 0.5;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);

    return randInt.toDouble();
  }

  static void disableHomeTabLocationUpdates() {
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static void enableHomeTabLocationUpdates() {
    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, currentPosition.latitude,
        currentPosition.longitude);
  }

  static void showProgressDialog(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );
  }
}
