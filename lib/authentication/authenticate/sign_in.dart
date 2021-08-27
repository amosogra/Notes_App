import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/authentication/services/auth.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/utils/loading.dart';
import 'package:notes_app/utils/log.dart';
import 'package:provider/provider.dart';

import '../../responsive.dart';

class SignIn extends StatefulWidget {
  static String routeName = "/login";
  final Function? toggleView;
  SignIn({this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  void setError(dynamic error) {
    ScaffoldMessengerState().showSnackBar(SnackBar(content: Text(error.toString())));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final config = Provider.of<ConfigurationProvider>(context);
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: config.darkThemeEnabled ? bgColorD : Colors.white,
            appBar: AppBar(
              backgroundColor: config.darkThemeEnabled ? bgColorD.withOpacity(0.2) : Colors.white,
              elevation: 0.0,
              leading: InkWell(
                  onTap: () {
                    widget.toggleView!();
                  },
                  child: Image.asset('assets/images/Back.png')),
              actions: <Widget>[
                TextButton(
                  child: Image.asset('assets/images/OK.png'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (mounted) {
                        setState(() {
                          loading = true;
                        });
                      }

                      try {
                        var result = await _auth.signInWithemailAndPassword(email.trim(), password.trim());
                        log("SignedIn User:");
                        log(result?.toString());
                        if (result != null) {
                          FirebaseFirestore.instance.collection(Constants.users).doc(result.uid).update({
                            'lastSignedTimestamp': Timestamp.now(),
                            "isOnline": true,
                          });
                          Navigator.of(context).pop();
                          return;
                        }
                        Navigator.of(context).pop();
                      } catch (e) {
                        //log(e.toString());
                        if (mounted) {
                          setState(() {
                            loading = false;
                            error = 'Could not sign in with those credentials..\n${e.toString()}';
                          });
                        }
                        return;
                      }
                    }
                  },
                )
              ],
            ),
            body: Container(
                height: height,
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
                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                        child: Text(
                          "Sign In",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: config.darkThemeEnabled ? Colors.white : null),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Color.fromRGBO(0, 79, 255, 0.45),
                        child: ClipOval(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CachedNetworkImage(
                              imageUrl: Constants.logoUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50.0),
                      Container(
                        //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                        child: TextFormField(
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
                          validator: (val) => val!.length < 6 ? 'Enter a valid email' : null,
                          onChanged: (val) {
                            if (mounted) {
                              setState(() {
                                email = val;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                        child: TextFormField(
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
                            prefixIcon: Icon(Icons.verified_user),
                          ),
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'Enter password, 6+ chars long' : null,
                          onChanged: (val) {
                            if (mounted) {
                              password = val;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(error, style: TextStyle(color: Colors.red, fontSize: 18.0))
                    ],
                  ),
                )),
          );
  }
}
