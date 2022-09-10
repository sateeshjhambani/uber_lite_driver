import 'package:firebase_database/firebase_database.dart';

class Driver {
  late String fullname;
  late String email;
  late String phone;
  late String id;
  late String carModel;
  late String carColor;
  late String vehicleNumber;

  Driver(
      {required this.fullname,
      required this.email,
      required this.phone,
      required this.id,
      required this.carModel,
      required this.carColor,
      required this.vehicleNumber});

  Driver.fromSnapshot(DataSnapshot snapshot) {
    dynamic object = snapshot.value!;
    id = snapshot.key ?? '';
    phone = object['phone'];
    email = object['email'];
    fullname = object['fullname'];
    carModel = object['vehicle_details']['car_model'];
    carColor = object['vehicle_details']['car_color'];
    vehicleNumber = object['vehicle_details']['vehicle_number'];
  }
}
