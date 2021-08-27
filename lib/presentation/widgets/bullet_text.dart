import 'package:flutter/material.dart';
import 'package:notes_app/presentation/widgets/spaces.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';

class TextWithBullet extends StatelessWidget {
  TextWithBullet({
    required this.text,
    this.textStyle,
    this.spacing,
    this.overflow,
  });

  final String text;
  final TextStyle? textStyle;
  final double? spacing;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final config = Provider.of<ConfigurationProvider>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Bullet(),
        spacing == null ? SpaceW16() : SizedBox(width: spacing),
        Flexible(
          child: Text(
            text,
            overflow: overflow,
            style: textStyle ??
                textTheme.bodyText1?.copyWith(
                  color: config.darkThemeEnabled ? AppColors.primaryText2Dark : AppColors.primaryText2Light,
                ),
          ),
        ),
      ],
    );
  }
}

class Bullet extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  Bullet({
    this.width = 4.0,
    this.height = 4.0,
    this.borderRadius = 20,
    this.color = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
    );
  }
}
