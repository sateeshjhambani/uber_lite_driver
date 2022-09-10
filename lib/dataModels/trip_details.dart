import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  final String destinationAddress;
  final String pickupAddress;
  final LatLng pickup;
  final LatLng destination;
  final String rideId;
  final String paymentMethod;
  final String riderName;
  final String riderPhone;

  TripDetails(
      {required this.destinationAddress,
      required this.pickupAddress,
      required this.pickup,
      required this.destination,
      required this.rideId,
      required this.paymentMethod,
      required this.riderName,
      required this.riderPhone});
}
