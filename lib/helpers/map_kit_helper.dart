import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitHelper {
  static double getMarkerRotation(double sourceLatitude, double sourceLongitude,
      double destinationLatitude, double destinationLongitude) {
    var rotation = SphericalUtil.computeHeading(
        LatLng(sourceLatitude, sourceLongitude),
        LatLng(destinationLatitude, destinationLongitude));
    return rotation.toDouble();
  }
}
