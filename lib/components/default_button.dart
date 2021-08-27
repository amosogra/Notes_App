import 'package:flutter/material.dart';
import 'package:notes_app/providers/configurationProvider.dart';

import '../kconstants.dart';
import '../size_config.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    this.text,
    this.press,
    required this.config,
  }) : super(key: key);
  final String? text;
  final Function? press;
  final ConfigurationProvider config;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: config.darkThemeEnabled ? ePrimaryColor : ePrimaryColor,
        onPressed: press as void Function()?,
        child: Text(
          text!,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
