import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_lite_driver/brand_colors.dart';
import 'package:uber_lite_driver/dataModels/trip_details.dart';
import 'package:uber_lite_driver/global_variables.dart';
import 'package:uber_lite_driver/helpers/map_kit_helper.dart';
import 'package:uber_lite_driver/widgets/CollectPaymentDialog.dart';
import 'package:uber_lite_driver/widgets/TaxiButton.dart';

import '../helpers/helper_methods.dart';
import '../widgets/ProgressDialog.dart';

class NewTripPage extends StatefulWidget {
  static const String id = 'newTrip';
  final TripDetails tripDetails;

  NewTripPage({required this.tripDetails});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController rideMapController;
  double mapPadding = 0;

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  late BitmapDescriptor movingMarkerIcon;
  late Position myPosition;

  String status = 'accepted';
  String durationString = '';

  bool isRequestingDirections = false;

  String buttonTitle = 'Arrived';
  Color buttonColor = BrandColors.colorGreen;
  late Timer timer;
  int durationCounter = 0;

  Future<void> getDirection(LatLng pickup, LatLng destination) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickup, destination);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails?.encodedPoints ?? "");

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      for (var points in results) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      }

      _polyLines.clear();
      setState(() {
        Polyline polyLine = Polyline(
          polylineId: const PolylineId('polyId'),
          color: Color.fromARGB(255, 95, 109, 237),
          points: polylineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          geodesic: true,
        );

        _polyLines.add(polyLine);
      });

      LatLngBounds bounds;
      if (pickup.latitude > destination.latitude &&
          pickup.longitude > destination.longitude) {
        bounds = LatLngBounds(southwest: destination, northeast: pickup);
      } else if (pickup.longitude > destination.longitude) {
        bounds = LatLngBounds(
            southwest: LatLng(pickup.latitude, destination.longitude),
            northeast: LatLng(destination.latitude, pickup.longitude));
      } else if (pickup.latitude > destination.latitude) {
        bounds = LatLngBounds(
            southwest: LatLng(destination.latitude, pickup.longitude),
            northeast: LatLng(pickup.latitude, destination.longitude));
      } else {
        bounds = LatLngBounds(southwest: pickup, northeast: destination);
      }

      rideMapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 60),
      );

      Marker pickupMarker = Marker(
          markerId: MarkerId('pickup'),
          position: pickup,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

      Marker destinationMarker = Marker(
          markerId: MarkerId('destination'),
          position: destination,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

      setState(() {
        _markers.add(pickupMarker);
        _markers.add(destinationMarker);
      });

      Circle pickupCircle = Circle(
          circleId: CircleId('pickup'),
          strokeColor: Colors.green,
          strokeWidth: 3,
          radius: 12,
          center: pickup,
          fillColor: BrandColors.colorGreen);

      Circle destinationCircle = Circle(
          circleId: CircleId('destination'),
          strokeColor: BrandColors.colorAccentPurple,
          strokeWidth: 3,
          radius: 12,
          center: destination,
          fillColor: BrandColors.colorBlue);

      setState(() {
        _circles.add(pickupCircle);
        _circles.add(destinationCircle);
      });
    }
  }

  var locationSettings =
      LocationSettings(accuracy: LocationAccuracy.bestForNavigation);

  void acceptTrip() {
    String rideId = widget.tripDetails.rideId;

    rideRef = FirebaseDatabase.instance.ref().child('rideRequest/$rideId');
    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullname);
    rideRef
        .child('car_details')
        .set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString()
    };

    rideRef.child('driver_location').set(locationMap);
  }

  void createMarker() async {
    ImageConfiguration imageConfiguration = createLocalImageConfiguration(
      context,
      size: Size(2, 2),
    );
    await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      Platform.isIOS ? 'images/car_ios.png' : 'images/car_android.png',
    ).then((icon) {
      movingMarkerIcon = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    acceptTrip();
  }

  void getLocationUpdates() {
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(myPosition.latitude, myPosition.longitude);

      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);

      Marker movingMarker = Marker(
          markerId: MarkerId('moving'),
          position: pos,
          icon: movingMarkerIcon, //Icon for Marker
          rotation: rotation,
          infoWindow: InfoWindow(title: 'Current Location'));

      setState(() {
        CameraPosition cp = CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });

      oldPosition = pos;
      updateTripDetail();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };

      rideRef.child('driver_location').set(locationMap);
    });
  }

  void updateTripDetail() async {
    if (!isRequestingDirections) {
      isRequestingDirections = true;
      if (myPosition == null) {
        return;
      }
      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      late LatLng destinationlatLng;
      if (status == 'accepted') {
        destinationlatLng = widget.tripDetails.pickup;
      } else {
        destinationlatLng = widget.tripDetails.destination;
      }

      var directionDetails = await HelperMethods.getDirectionDetails(
          positionLatLng, destinationlatLng);

      if (directionDetails != null) {
        setState(() {
          durationString = directionDetails.durationText;
        });
      }

      isRequestingDirections = false;
    }
  }

  void startTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip() async {
    HelperMethods.showProgressDialog(context);

    timer.cancel();
    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);
    var directionDetails = await HelperMethods.getDirectionDetails(
        widget.tripDetails.pickup, currentLatLng);

    Navigator.pop(context);

    int fares = directionDetails != null
        ? HelperMethods.estimateFares(directionDetails, durationCounter)
        : 0;

    rideRef.child('fares').set(fares.toString());
    rideRef.child('status').set('ended');
    ridePositionStream.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectPayment(
          paymentMethod: widget.tripDetails.paymentMethod, fares: fares),
    );

    topUpEarnings(fares);
  }

  void topUpEarnings(int fares) {
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentFirebaseUser?.uid}/earnings');
    earningsRef.once().then((value) {
      if (value.snapshot.value != null) {
        double oldEarnings = double.parse(value.snapshot.value.toString());
        double adjustedEarnings = ((fares.toDouble()) * 0.85) + oldEarnings;
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      } else {
        double adjustedEarnings = ((fares.toDouble()) * 0.85);
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            circles: _circles,
            markers: _markers,
            polylines: _polyLines,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              rideMapController = controller;

              setState(() {
                mapPadding = Platform.isIOS ? 255 : 260;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.tripDetails.pickup;
              await getDirection(currentLatLng, pickupLatLng);

              getLocationUpdates();
            },
            initialCameraPosition: googlePlex,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: Platform.isIOS ? 280 : 255,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      durationString,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Brand-Bold',
                          color: BrandColors.colorAccentPurple),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.tripDetails.riderName,
                          style:
                              TextStyle(fontSize: 22, fontFamily: 'Brand-Bold'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.call),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
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
                              widget.tripDetails.pickupAddress,
                              style: TextStyle(
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
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
                              widget.tripDetails.destinationAddress,
                              style: TextStyle(
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TaxiButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPressed: () async {
                        if (status == 'accepted') {
                          status = 'arrived';
                          rideRef.child('status').set(('arrived'));

                          setState(() {
                            buttonTitle = 'Start Trip';
                            buttonColor = BrandColors.colorAccentPurple;
                          });

                          await getDirection(widget.tripDetails.pickup,
                              widget.tripDetails.destination);
                        } else if (status == 'arrived') {
                          status = 'ontrip';
                          rideRef.child('status').set(('ontrip'));

                          setState(() {
                            buttonTitle = 'End Trip';
                            buttonColor = Colors.red.shade900;
                          });

                          startTimer();
                        } else if (status == 'ontrip') {
                          endTrip();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
