/*
* File : Edit Profile
* Version : 1.0.0
* */

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/ui/notifiers/overlay.dart';
import 'package:notes_app/utils/generate_search.dart';
import 'package:notes_app/utils/log.dart';
import 'package:notes_app/values/values.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../../models/user_model.dart';
import '../../providers/configurationProvider.dart';
import '../../responsive.dart';
import '../../ui/AppTheme.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/crop.dart';
import '../../utils/tasks.dart';

class EditProfileScreen extends StatefulWidget {
  static String routeName = "/edit";
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  ThemeData? themeData;

  var fistName;
  var lastName;
  var email = TextEditingController();
  var phone;
  var address;
  var state;
  var city;
  var gender = "Unknown";
  String? profilePhotoUrl = Constants.logoUrl;
  DocumentSnapshot? logged;
  Color? maskColor;
  bool enable = false;

  String profile = Constants.slogan;
  String username = Constants.appName;

  var bankName;
  var accountName;
  var accountNumber;
  DateTime? dateOfBirth;
  User? user;

  @override
  void initState() {
    super.initState();
    final loggeduser = Provider.of<fire.User?>(context, listen: false);
    if (loggeduser != null) {
      FirebaseFirestore.instance.collection(Constants.users).doc(loggeduser.uid).get().then((doc) {
        logged = doc;
        var data = doc.data() ?? {};
        var _user = User.fromJson(data);
        log("DATA: $data");
        if (mounted) {
          var _fistName = data['first_name'] ?? "";
          var _lastName = data['last_name'] ?? "";
          var _email = data['email'] ?? "";
          var _gender = data['gender'] ?? "Unknown";
          var _phone = "";
          var _address = "";
          var _state = "";
          var _city = "";
          Timestamp? dob = data['dateOfBirth'];
          if (data['address'] != null) {
            _phone = data['address']["phone"] ?? "";
            _address = data['address']["address_1"] ?? "";
            _state = data['address']["state"] ?? "";
            _city = data['address']["city"] ?? "";
          }
          var _profilePhotoUrl = data["avatar_url"] ?? profilePhotoUrl;
          setState(() {
            user = _user;
            fistName = _fistName;
            lastName = _lastName;
            email.text = _email;
            gender = _gender;
            phone = _phone;
            address = _address;
            state = _state;
            city = _city;
            profilePhotoUrl = _profilePhotoUrl;
            username = "$_fistName $_lastName";
            profile = "${data['role'] ?? 'Regular'} Profile";
            dateOfBirth = dob?.toDate();
          });
        }
      });
    }
  }

  Future getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    log('Image Path ${image?.path}');
    _cropImage(await image!.readAsBytes(), image);
  }

  Future _cropImage(Uint8List bytes, PickedFile? file) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CropImage(
            bytes: bytes,
            onDoneCropping: (Uint8List data) {
              uploadPic(file, data);
              return true;
            },
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future uploadPic(PickedFile? image, Uint8List data) async {
    String fileName = path.basename(image!.path);

    Map<String, dynamic> result =
        await Tasks.uploadImageTask(image, data, fileName.contains(".") ? fileName : "$fileName.png", maskColor, "uploading profile picture");
    if (result['uploaded']) {
      var _profilePhotoUrl = result['url'];

      if (mounted) {
        setState(() {
          profilePhotoUrl = _profilePhotoUrl;
        });
      }
      log("Profile Picture Uploaded: $profilePhotoUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    themeData = AppTheme.getThemeFromThemeMode(config.darkThemeEnabled ? 2 : 1);
    maskColor = Theme.of(context).accentColor.withOpacity(0.4);
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: MySize.size24, bottom: MySize.size24),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              MdiIcons.chevronLeft,
                              color: themeData!.colorScheme.onBackground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Update Profile".toUpperCase(),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Container(
                          //alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => setState(() {
                              enable = !enable;
                            }),
                            icon: Icon(
                              enable ? MdiIcons.lock : MdiIcons.pencil,
                              color: themeData!.colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          //open gallery
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: MySize.size16),
                          width: MySize.getScaledSizeHeight(180),
                          height: MySize.getScaledSizeHeight(180),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: CachedNetworkImageProvider(profilePhotoUrl!), fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: MySize.size12,
                        right: MySize.size8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: themeData!.scaffoldBackgroundColor, width: 2, style: BorderStyle.solid),
                            color: themeData!.colorScheme.primary,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(MySize.size0),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt, //MdiIcons.pencil,
                                size: MySize.size30,
                                color: themeData!.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Text(username, style: AppTheme.getTextStyle(themeData!.textTheme.headline6, fontWeight: 600, letterSpacing: 0)),
                  Text(profile, style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2, fontWeight: 500)),
                ],
              ),
            ),
            Container(
              //padding: EdgeInsets.only(top: MySize.size36, left: MySize.size24, right: MySize.size24, bottom: 36),
              padding: Responsive.isDesktop(context)
                  ? EdgeInsets.symmetric(horizontal: 400)
                  : Responsive.isTablet(context)
                      ? EdgeInsets.symmetric(horizontal: 150)
                      : EdgeInsets.symmetric(horizontal: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    PopupMenuButton<String>(
                      enabled: enable,
                      //color: Colors.black,
                      child: Row(
                        children: [
                          Icon(
                            MdiIcons.genderMaleFemale,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(
                            width: kDefaultPadding / 2,
                          ),
                          Text("Gender: $gender"),
                        ],
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Please pick your gender"),
                          value: "Unknown",
                          textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          child: Text("Male"),
                          value: "Male",
                          textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        PopupMenuItem(
                          child: Text("Female"),
                          value: "Female",
                          textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                      tooltip: 'Gender',
                      onSelected: (x) {
                        setState(() {
                          gender = x;
                        });
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: enable,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "First Name",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            MdiIcons.accountOutline, //Icons.supervised_user_circle,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        controller: TextEditingController(text: fistName),
                        validator: (val) => val!.isEmpty ? 'Entry cannot be empty' : null,
                        onChanged: (val) {
                          fistName = val;
                          log(val);
                        },
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: enable,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "Last Name",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            MdiIcons.accountOutline,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        controller: TextEditingController(text: lastName),
                        validator: (val) => val!.isEmpty ? 'Entry cannot be empty' : null,
                        onChanged: (val) {
                          lastName = val;
                        },
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: false,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            MdiIcons.emailOutline,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: email,
                        validator: (val) {
                          if (val!.length < 6) {
                            return 'Entry cannot be less than 6 characters';
                          }
                          var x = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val);
                          if (x == false) {
                            return "Please supply a valid email";
                          }

                          return null;
                        },
                        onChanged: (val) {
                          email.text = val;
                        },
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: enable,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "Phone",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            MdiIcons.phoneOutline,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        keyboardType: TextInputType.text,
                        controller: TextEditingController(text: phone),
                        validator: (val) {
                          if (val!.trim().length != 11) {
                            return 'Please insert 11 digit mobile number e.g (081 xxxx xxxx)';
                          } else {
                            var parsed = int.tryParse(val.trim());
                            return parsed != null ? null : "Only numbers are allowed.";
                          }
                        },
                        onChanged: (val) {
                          phone = val.trim();
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: enable,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "Home Address",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            Icons.location_pin,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        controller: TextEditingController(text: address),
                        validator: (val) => val!.length < 15 ? 'Your billing address is too short to be understood' : null,
                        onChanged: (val) {
                          address = val;
                        },
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: enable,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "State",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            Icons.location_city,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        controller: TextEditingController(text: state),
                        validator: (val) => val!.isEmpty ? 'Entry cannot be empty' : null,
                        onChanged: (val) {
                          state = val;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: TextFormField(
                        enabled: enable,
                        style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "City",
                          hintStyle:
                              AppTheme.getTextStyle(themeData!.textTheme.subtitle2, letterSpacing: 0.1, color: themeData!.colorScheme.onBackground, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: themeData!.colorScheme.background,
                          prefixIcon: Icon(
                            Icons.location_city_outlined,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        controller: TextEditingController(text: city),
                        validator: (val) => val!.isEmpty ? 'Entry cannot be empty' : null,
                        onChanged: (val) {
                          //setState(() {
                          city = val;
                          //});
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: DateTimePicker(
                        enabled: true,
                        type: DateTimePickerType.date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        initialDate: dateOfBirth,
                        initialValue: dateOfBirth != null ? DateFormat("EEE, d MMMM, yyyy").format(dateOfBirth!) : null,
                        icon: Icon(Icons.event),
                        cancelText: "Cancel",
                        confirmText: "Confirm",
                        dateMask: 'EEE, d MMM, yyyy',
                        dateLabelText: dateOfBirth != null ? DateFormat("EEE, d MMMM, yyyy").format(dateOfBirth!) : 'Date of Birth (DOB)',
                        smartQuotesType: SmartQuotesType.enabled,
                        onChanged: (date) {
                          setState(() {
                            dateOfBirth = DateTime.tryParse(date);
                          });
                        },
                        style: AppTheme.getTextStyle(Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white), letterSpacing: 0.1, fontWeight: 500),
                        decoration: InputDecoration(
                          hintText: "Date of Birth (DOB)",
                          hintStyle: AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle2, letterSpacing: 0.1, fontWeight: 500),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: AppColors.primaryColor, //themeData.colorScheme.background,
                          prefixIcon: Icon(
                            MdiIcons.timelineAlert,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        /* controller: TextEditingController(
                          text: dateOfBirth != null ? DateFormat("EEE, d MMMM, yyyy").format(dateOfBirth!) : '',
                        ), */
                      ),
                    ),
                    /* Container(
                        margin: EdgeInsets.only(top: MySize.size16),
                        child: TextFormField(
                          style: AppTheme.getTextStyle(themeData.textTheme.bodyText1, letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                          decoration: InputDecoration(
                            hintText: "Change Password",
                            hintStyle:
                                AppTheme.getTextStyle(themeData.textTheme.subtitle2, letterSpacing: 0.1, color: themeData.colorScheme.onBackground, fontWeight: 500),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: themeData.colorScheme.background,
                            prefixIcon: Icon(
                              MdiIcons.lockOutline,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? MdiIcons.eyeOutline : MdiIcons.eyeOffOutline,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          obscureText: _passwordVisible,
                        ),
                      ), */
                    Container(
                      margin: EdgeInsets.only(top: MySize.size24, bottom: MySize.size36),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
                        boxShadow: [
                          BoxShadow(
                            color: themeData!.colorScheme.primary.withAlpha(20),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        color: themeData!.colorScheme.primary,
                        padding: EdgeInsets.only(left: MySize.size32, right: MySize.size32),
                        splashColor: Colors.white,
                        onPressed: () {
                          if (gender == 'Unknown') {
                            showOverlayNotification((context) {
                              return MessageNotification(
                                title: "Invalid Gender",
                                subtitle: 'Please pick a gender before proceeding',
                                onReplay: () {
                                  OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
                                  toast('Warm regards');
                                },
                              );
                            }, duration: Duration.zero);
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            //update
                            final loggedUser = Provider.of<fire.User?>(context, listen: false);
                            if (loggedUser != null) {
                              EasyLoading.instance
                                ..indicatorType = EasyLoadingIndicatorType.cubeGrid
                                ..loadingStyle = EasyLoadingStyle.dark
                                ..userInteractions = true
                                ..dismissOnTap = false
                                ..toastPosition = EasyLoadingToastPosition.center;
                              EasyLoading.show();

                              User user = User(
                                //uid: loggedUser?.uid,
                                email: email.text,
                                firstName: fistName.toString().trim(),
                                lastName: lastName.toString().trim(),
                                gender: gender.toString().trim(),
                                avatarUrl: profilePhotoUrl,
                                lastModified: Timestamp.now(),
                                dateOfBirth: dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
                                searchKeywords: GenerateSearch.getSearchKeywords("${fistName.toString().trim()} ${lastName.toString().trim()}"),
                                address: Address(
                                  address1: address.toString().trim(),
                                  city: city.toString().trim(),
                                  state: state.toString().trim(),
                                  phone: phone.toString().trim(),
                                ),
                              );

                              FirebaseFirestore.instance
                                  .collection(Constants.users)
                                  .doc(loggedUser.uid)
                                  .update(User.discardNullOrEmptyEntriesAndValues(user.toJson()))
                                  .then((v) {
                                showOverlayNotification((context) {
                                  return MessageNotification(
                                    title: "Heads UP",
                                    subtitle: 'Update Successful',
                                    onReplay: () {
                                      OverlaySupportEntry.of(context)!.dismiss(); //use OverlaySupportEntry to dismiss overlay
                                      toast('Warm regards');
                                    },
                                  );
                                }, duration: Duration(seconds: 3));

                                log("BEFORE: ${user.toJson()}\n\n");
                                log("AFTER: ${User.discardNullOrEmptyEntriesAndValues(user.toJson())}\n\n");

                                FirebaseFirestore.instance.collection(Constants.users).doc(loggedUser.uid).get().then((doc) {
                                  var data = doc.data();
                                  //log("UPDATED DATA: $data");
                                  if (mounted && data != null) {
                                    var _fistName = data['first_name'] ?? "";
                                    var _lastName = data['last_name'] ?? "";
                                    var _profilePhotoUrl = data["avatar_url"] ?? profilePhotoUrl;
                                    setState(() {
                                      profilePhotoUrl = _profilePhotoUrl;
                                      username = "$_fistName $_lastName";
                                      profile = "${data['role'] ?? profile} Profile";
                                    });
                                  }
                                });
                                setState(() {
                                  enable = false;
                                });

                                EasyLoading.dismiss(animation: true);
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop();
                                });
                              });

                              /* log("BEFORE: ${user.toJson()}");
                                [' ', ' ', ' '].forEach(print);
                                var formatted = User.discardNullOrEmptyEntriesAndValues(user.toJson());
                                [' ', ' ', ' '].forEach(print);
                                log("AFTER: $formatted"); */
                              /*user.toJson().entries.forEach((v) {
                                  log("ENTRIES: ${v.toString()} - IS MAP?: ${v.value is Map ? 'YES' : 'NO'} - CONTAINS FIRST?: ${v.toString().contains("fir")}");
                                  if ((v.value is Map) && (v.value as Map).entries.length > 1) {
                                    (v.value as Map).entries.forEach((v1) {
                                      log(
                                          "         SUB ENTRY: ${v1.toString()} - IS MAP?: ${v1.value is Map ? 'YES' : 'NO'} - CONTAINS FIRST?: ${v1.toString().contains("fir")}");
                                    });
                                  }
                                }); */
                            }
                          }
                        },
                        child: Text(
                          "UPDATE",
                          style: AppTheme.getTextStyle(themeData!.textTheme.button, fontWeight: 600, color: themeData!.colorScheme.onPrimary, letterSpacing: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
