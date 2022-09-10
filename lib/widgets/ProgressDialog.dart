import 'package:flutter/material.dart';
import 'package:gradient_ui_widgets/gradient_ui_widgets.dart'
    as GradientWidgets;

import '../brand_colors.dart';

class ProgressDialog extends StatelessWidget {
  final String status;

  ProgressDialog({required this.status});

  Gradient g1 = LinearGradient(
    colors: [
      BrandColors.colorGreen,
      BrandColors.colorAccent,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 5,
              ),
              GradientWidgets.GradientCircularProgressIndicator(
                valueGradient: g1,
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(
                width: 25,
              ),
              Text(
                status,
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ),
      ),
    );
  }
}
