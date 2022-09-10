import 'package:flutter/material.dart';
import 'package:uber_lite_driver/brand_colors.dart';
import 'package:uber_lite_driver/widgets/TaxiButton.dart';
import 'package:uber_lite_driver/widgets/TaxiOutlineButton.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function() onPressed;

  ConfirmSheet(
      {required this.title, required this.subtitle, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 15,
          spreadRadius: 0.5,
          offset: Offset(0.7, 0.7),
        )
      ]),
      height: 220,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Brand-Bold',
                color: BrandColors.colorText,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: BrandColors.colorTextLight),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: TaxiOutlineButton(
                      title: 'Back',
                      color: BrandColors.colorLightGrayFair,
                      onPressed: () {},
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    child: TaxiButton(
                      title: 'Confirm',
                      color: title == 'Go Online'
                          ? BrandColors.colorGreen
                          : BrandColors.colorOrange,
                      onPressed: onPressed,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
