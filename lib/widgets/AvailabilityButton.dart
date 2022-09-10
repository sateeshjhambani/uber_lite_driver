import 'package:flutter/material.dart';

class AvailabilityButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function() onPressed;

  AvailabilityButton(
      {required this.title, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        color: color,
        textColor: Colors.white,
        child: Container(
          height: 55,
          width: 200,
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
            ),
          ),
        ),
      ),
    );
  }
}
