import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notes_app/authentication/wrapper.dart';
import 'package:notes_app/utils/SizeConfig.dart';

import '../size_config.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() {
    // return Timer(Duration(seconds: 5), onDoneLoading);
    return Future.delayed(Duration(seconds: 5), onDoneLoading);
  }

  onDoneLoading() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Wrapper()));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    MySize().init(context);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/KiteSplash.png'), fit: BoxFit.cover),
      ),
      child: Center(
        child: SpinKitRipple(
          color: Colors.white,
          size: 300.0,
        ),
      ),
    );
  }
}

/*CircleAvatar(
          radius: 80,
          backgroundColor: Color.fromRGBO(0, 79, 255, 0.45),
          child: ClipOval(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      Constants.logoUrl,
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                ),
               child: SpinKitRipple(
          color: Colors.white,
          size: 300.0,
        ),
              ),
            ),
          ),
        ),*/
