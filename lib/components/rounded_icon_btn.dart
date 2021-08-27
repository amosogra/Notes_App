import 'package:flutter/material.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:provider/provider.dart';

import '../size_config.dart';

class RoundedIconBtn extends StatelessWidget {
  const RoundedIconBtn({
    Key? key,
    required this.icon,
    required this.press,
    this.showShadow = false,
    this.height = 40,
    this.width = 40,
  }) : super(key: key);

  final IconData icon;
  final Function()? press;
  final bool showShadow;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigurationProvider>(context);
    return Container(
      height: getProportionateScreenWidth(height),
      width: getProportionateScreenWidth(width),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (showShadow)
            BoxShadow(
              offset: Offset(0, 6),
              blurRadius: 10,
              color: config.darkThemeEnabled ? Color(0xFFf0B0B0).withOpacity(0.2) : Color(0xFFB0B0B0).withOpacity(0.2),
            ),
        ],
      ),
      child: FlatButton(
        padding: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: press,
        child: Icon(
          icon,
          color: ePrimaryColor,
        ),
      ),
    );
  }
}
