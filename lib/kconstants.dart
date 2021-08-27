import 'package:flutter/material.dart';

import 'size_config.dart';

// All of our constant stuff

const double kWidth = defaultPadding * 2;
const double nWidth = defaultPadding * 3;
const double kradius = kDefaultPadding / 4 + kDefaultPadding / 2;

const kPrimaryColor = Colors.orange; //Color(0xFF366CF6);
const kSecondaryColor = Color(0xFFF5F6FC);
const kBgLightColor = Color(0xFFF2F4FC);
const kBgDarkColor = Color(0xFFEBEDFA);
const kBadgeOfflineColor = Color(0xFFEE376E);
const kBadgeOnlineColor = Colors.green;
const kGrayColor = Color(0xFF8793B2);
const kTitleTextColor = Color(0xFF30384D);
const kTextColor = Color(0xFF4D5875);

const kDefaultPadding = defaultPadding;

//..................Dashboard..................
/* const primaryColorD = Color(0xFF2697FF);
const secondaryColorD = Color(0xFF2A2D3E);
const bgColorD = Color(0xFF212332);// Color(0xff464c52); */

const primaryColorD = Color(0xFF2697FF);
final secondaryColorD = eSecondaryColor.withOpacity(0.1); //Color(0xff464c52);
const bgColorD = Color(0xFF2A2D3E); //Color(0xFF212332);

const primaryColor = Color(0xFF8793B2);
const secondaryColor = Color(0xFFEBEDFA);
const bgColor = Color(0xFFCAD5E2); //Color(0xFF999999);

const defaultPadding = 16.0;
//.............................................

//Below configuration is for the ecommerce app
const ePrimaryColor = Color(0xFFFF7643);
const eSecondaryColor = Color(0xFF979797);
const eTextColor = Color(0xFF757575);

const ePrimaryLightColor = Color(0xFFFFECDF);
const ePrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}
