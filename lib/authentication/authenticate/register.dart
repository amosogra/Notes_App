import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/authentication/services/service.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/responsive.dart';
import 'package:notes_app/utils/crop.dart';
import 'package:notes_app/utils/do.dart';
import 'package:notes_app/utils/loading.dart';
import 'package:notes_app/utils/log.dart';
import 'package:notes_app/utils/tasks.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class Register extends StatefulWidget {
  static String routeName = "/register";
  final Function? toggleView;
  Register({this.toggleView});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //File _image;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  //GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool loading = false;
  //text field state
  String email = '';
  String password = '';
  String username = '';
  String error = '';
  String? profilePhotoUrl = Constants.logoUrl;

  Color? maskColor;
  initState() {
    super.initState();
  }

  void setError(dynamic error) {
    ScaffoldMessengerState().showSnackBar(SnackBar(content: Text(error.toString())));
    if (mounted) {
      setState(() {});
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
    maskColor = Theme.of(context).accentColor.withOpacity(0.6);
    final config = Provider.of<ConfigurationProvider>(context);
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: config.darkThemeEnabled ? bgColorD : Colors.white,
            appBar: AppBar(
              backgroundColor: config.darkThemeEnabled ? bgColorD.withOpacity(0.2) : Colors.white,
              elevation: 0.0,
              leading: Container(),
              actions: <Widget>[
                TextButton(
                  child: Image.asset('assets/images/Back.png'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            body: Center(
              child: Container(
                  padding: Responsive.isDesktop(context)
                      ? EdgeInsets.symmetric(horizontal: 400)
                      : Responsive.isTablet(context)
                          ? EdgeInsets.symmetric(horizontal: 150)
                          : EdgeInsets.symmetric(horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Sign Up".toUpperCase(),
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: config.darkThemeEnabled ? Colors.white : null),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            // child: Image.asset('assets/images/KiteLogoPurp.png', width: 150,height: 150,),
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Theme.of(context).accentColor,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: CachedNetworkImage(
                                    imageUrl: profilePhotoUrl!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 30.0,
                                ),
                                onPressed: () {
                                  getImage();
                                },
                              ),
                            )
                          ],
                        )),
                        SizedBox(height: 50.0),
                        TextFormField(
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(234, 234, 234, 1),
                            hintText: 'Email',
                            contentPadding: EdgeInsets.all(Responsive.isMobile(context)
                                ? 12
                                : Responsive.isTablet(context)
                                    ? 16
                                    : 24),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                            ),
                          ),
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
                            email = val;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(234, 234, 234, 1),
                            hintText: 'Password',
                            contentPadding: EdgeInsets.all(Responsive.isMobile(context)
                                ? 12
                                : Responsive.isTablet(context)
                                    ? 16
                                    : 24),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(
                              Icons.verified_user,
                            ),
                          ),
                          validator: (val) => val!.length < 6 ? 'Enter password, 6+ chars long' : null,
                          obscureText: true,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          height: 45,
                          child: RaisedButton(
                            color: Color.fromRGBO(113, 119, 249, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.7),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                            elevation: 4,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                bool result = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
                                if (result == false) {
                                  setState(() {
                                    loading = false;
                                    error = 'Please supply a valid email';
                                  });
                                } else {
                                  try {
                                    final result = await _auth.registerWithemailAndPassword(email.trim(), password.trim());
                                    log("Registered User:");
                                    log(result?.toString());
                                    EasyLoading.instance
                                      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
                                      ..loadingStyle = EasyLoadingStyle.dark
                                      ..userInteractions = true
                                      ..dismissOnTap = false
                                      ..toastPosition = EasyLoadingToastPosition.center;
                                    EasyLoading.show();
                                    //Future.delayed(Duration(seconds: 10), functioncall());
                                    if (result != null) {
                                      await Service().register(email.trim(), password.trim(), result.uid, profilePhotoUrl, config.upliner);
                                      config.upliner = null;
                                      final loggeduser = Provider.of<User?>(context, listen: false);
                                      if (loggeduser != null) {
                                        log('Checking Token & Getting Current User Info... uid: ${loggeduser.uid}');
                                        FirebaseFirestore.instance
                                            .collection(Constants.users)
                                            .doc(loggeduser.uid)
                                            .get()
                                            .then((DocumentSnapshot<Map<String, dynamic>> ds) async {
                                          await Do.checkToken(ds).then((v) {
                                            // make sure you initialise notification provider now
                                            EasyLoading.dismiss();
                                            Navigator.of(context).pop();
                                          }).catchError((err, StackTrace stackTrace) {
                                            log("ERROR CAUGHT: $err");
                                            log(stackTrace.toString());
                                            EasyLoading.dismiss();
                                            Navigator.of(context).pop();
                                          }, test: (err) {
                                            setState(() {
                                              loading = false;
                                              error = err.toString();
                                            });
                                            return false;
                                          });
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    log(e.toString());
                                    setState(() {
                                      loading = false;
                                      error = e.toString();
                                    });
                                    return;
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        TextButton(
                          child: Text.rich(
                            TextSpan(
                              text: 'Already a Member?',
                            ),
                          ),
                          onPressed: () {
                            widget.toggleView!();
                          },
                        ),
                        SizedBox(height: 12.0),
                        Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0))
                      ],
                    ),
                  )),
            ),
          );
  }
}
