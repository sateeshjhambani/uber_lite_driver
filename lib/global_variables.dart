import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dataModels/driver.dart';

String mapKey = 'AIzaSyA1MwvmY0ylcAnivpYpeMQi9mcGIPPGQ90';
String mapKeyWithBilling = 'AIzaSyDqK54Gfh-3Y7jr_Lin_y-LSua2zz9dcxc';
User? currentFirebaseUser;
final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
late DatabaseReference tripRequestRef;
late StreamSubscription<Position> homeTabPositionStream;
late StreamSubscription<Position> ridePositionStream;
final assetsAudioPlayer = AssetsAudioPlayer();
late Position currentPosition;
late DatabaseReference rideRef;
late Driver currentDriverInfo;
