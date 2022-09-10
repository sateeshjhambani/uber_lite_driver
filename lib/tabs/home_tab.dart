import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_lite_driver/brand_colors.dart';
import 'package:uber_lite_driver/global_variables.dart';
import 'package:uber_lite_driver/helpers/push_notification_service.dart';
import 'package:uber_lite_driver/widgets/AvailabilityButton.dart';

import '../dataModels/driver.dart';
import '../widgets/ConfirmSheet.dart';

class HomeTab extends StatefulWidget {
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;

  String availabilityTitle = 'Go Online';
  Color availabilityColor = BrandColors.colorOrange;
  bool isAvailable = false;

  void getCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        final snackBar = SnackBar(
          content: Text(
            'Location Not Available',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;

    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser?.uid}');
    driverRef.once().then((value) {
      if (value.snapshot.value != null) {
        currentDriverInfo = Driver.fromSnapshot(value.snapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.init(context);
    pushNotificationService.getToken();
  }

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          initialCameraPosition: googlePlex,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: (!isAvailable) ? 'Go Online' : 'Go Offline',
                      subtitle: (!isAvailable)
                          ? 'You are about to become available to receive trip requests'
                          : 'You will stop receiving new trip requests',
                      onPressed: () {
                        if (!isAvailable) {
                          goOnline();
                          getLocationUpdates();
                          Navigator.pop(context);

                          setState(() {
                            availabilityColor = BrandColors.colorGreen;
                            availabilityTitle = 'Go Offline';
                            isAvailable = true;
                          });
                        } else {
                          goOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = BrandColors.colorOrange;
                            availabilityTitle = 'Go Online';
                            isAvailable = false;
                          });
                        }
                      },
                    ),
                  );
                },
              )
            ],
          ),
        )
      ],
    );
  }

  void goOnline() {
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFirebaseUser?.uid ?? '',
        currentPosition.latitude, currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser?.uid}/newTrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {});
  }

  void goOffline() {
    Geofire.removeLocation(currentFirebaseUser?.uid ?? '');
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
  }

  void getLocationUpdates() {
    LocationSettings settings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);
    homeTabPositionStream =
        Geolocator.getPositionStream(locationSettings: settings)
            .listen((Position position) {
      currentPosition = position;

      if (isAvailable) {
        Geofire.initialize('driversAvailable');
        Geofire.setLocation(currentFirebaseUser?.uid ?? '', position.latitude,
            position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = CameraPosition(target: pos, zoom: 14);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    });
  }
}
