import 'package:flutter/material.dart';

class Assets {
  static Color appbg = Color(0xFF2C384A);

  static String _imagesRoot = "assets/images/";
  static String logo = _imagesRoot + "fastcheckout.png";
  static String scanicon = _imagesRoot + "scanicon.png";

  static String getPaymentLink =
      'https://us-central1-unique-nuance-310113.cloudfunctions.net/getPaymentLink';
  static String getNotifyLink =
      'https://us-central1-unique-nuance-310113.cloudfunctions.net/sendNotification';
  static const double fourBy1 = 4.0;
  static const double fourBy2 = 8.0;
  static const double fourBy3 = 12.0;
  static const double fourBy4 = 16.0;

  static const double eightBy1 = 8.0;
  static const double eightBy2 = 16.0;
  static const double eightBy3 = 24.0;
  static const double eightBy4 = 32.0;

  static const double sixteenBy1 = 16.0;
  static const double sixteenBy2 = 32.0;
  static const double sixteenBy3 = 48.0;
  static const double sixteenBy4 = 64.0;
}

class CustomColors {
  static final Color firebaseNavy = Color(0xFF2C384A);
  static final Color firebaseOrange = Color(0xFFF57C00);
  static final Color firebaseAmber = Color(0xFFFFA000);
  static final Color firebaseYellow = Color(0xFFFFCA28);
  static final Color firebaseGrey = Color(0xFFECEFF1);
  static final Color googleBackground = Color(0xFF4285F4);
}

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 1.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      width: 3.0,
    ),
  ),
);
const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceRegular = SizedBox(width: 18.0);
const Widget horizontalSpaceMedium = SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = SizedBox(width: 50.0);

const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceRegular = SizedBox(height: 18.0);
const Widget verticalSpaceMedium = SizedBox(height: 25.0);
const Widget verticalSpaceLarge = SizedBox(height: 50.0);

// Screen Size helpers

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightPercentage(BuildContext context, {double percentage = 1}) =>
    screenHeight(context) * percentage;

double screenWidthPercentage(BuildContext context, {double percentage = 1}) =>
    screenWidth(context) * percentage;
