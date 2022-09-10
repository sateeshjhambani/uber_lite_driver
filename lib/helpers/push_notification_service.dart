import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_lite_driver/dataModels/trip_details.dart';
import 'package:uber_lite_driver/global_variables.dart';

import '../firebase_options.dart';
import '../widgets/NotificationDialog.dart';
import '../widgets/ProgressDialog.dart';

late BuildContext buildContext;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  fetchRideInfo(getId(message), buildContext);
}

String getId(RemoteMessage message) {
  if (Platform.isAndroid) {
    String rideId = message.data['ride_id'];
    return rideId;
  }
  return '';
}

void fetchRideInfo(String rideId, context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) =>
        ProgressDialog(status: 'Fetching details...'),
  );

  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('rideRequest/$rideId');

  databaseReference.once().then((databaseEvent) {
    Navigator.pop(context);

    var map = databaseEvent.snapshot.value as Map;
    if (map != null) {
      assetsAudioPlayer.open(
        Audio("sounds/alert.mp3"),
      );
      assetsAudioPlayer.play();

      double pickupLat = double.parse(map['location']['latitude'].toString());
      double pickupLong = double.parse(map['location']['longitude'].toString());
      String pickupAddress = map['pickup_address'].toString();
      double destinationLat =
          double.parse(map['destination']['latitude'].toString());
      double destinationLong =
          double.parse(map['destination']['longitude'].toString());
      String destinationAddress = map['destination_address'].toString();
      String paymentMethod = map['payment_method'].toString();
      String riderName = map['rider_name'].toString();
      String riderPhone = map['rider_phone'].toString();

      TripDetails tripDetails = TripDetails(
          destinationAddress: destinationAddress,
          pickupAddress: pickupAddress,
          pickup: LatLng(pickupLat, pickupLong),
          destination: LatLng(destinationLat, destinationLong),
          rideId: rideId,
          paymentMethod: paymentMethod,
          riderName: riderName,
          riderPhone: riderPhone);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NotificationDialog(
          tripDetails: tripDetails,
        ),
      );
    }
  });
}

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  Future init(context) async {
    buildContext = context;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      fetchRideInfo(getId(message), context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      fetchRideInfo(getId(message), context);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String> getToken() async {
    String? token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser?.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');

    return token ?? '';
  }
}
