import 'package:flutter/material.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/ui/components/shimmerContainer.dart';

// Our design contains Neumorphism design and i made a extention for it
// We can apply it on any  widget

extension Neumorphism on Widget {
  addNeumorphism({
    double borderRadius = 10.0,
    Offset offset = const Offset(5, 5),
    double blurRadius = 10,
    Color topShadowColor = Colors.white60,
    Color bottomShadowColor = const Color(0x26234395),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            offset: offset,
            blurRadius: blurRadius,
            color: bottomShadowColor,
          ),
          BoxShadow(
            offset: Offset(-offset.dx, -offset.dx),
            blurRadius: blurRadius,
            color: topShadowColor,
          ),
        ],
      ),
      child: this,
    );
  }
}

extension Shadowphism on Widget {
  addShadowphism({
    Offset offset = const Offset(5, 5),
    double blurRadius = 10,
    Color topShadowColor = Colors.white60,
    Color bottomShadowColor = const Color(0x26234395),
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            offset: offset,
            blurRadius: blurRadius,
            color: bottomShadowColor,
          ),
          BoxShadow(
            offset: Offset(-offset.dx, -offset.dx),
            blurRadius: blurRadius,
            color: topShadowColor,
          ),
        ],
      ),
      child: this,
    );
  }
}

Container shimmerNode(BuildContext context, GestureTapCallback? onClose, double? width, double defaultWidthOfDrawer) {
  return Container(
    padding: EdgeInsets.only(left: defaultPadding, right: defaultPadding),
    margin: EdgeInsets.only(bottom: defaultPadding / 2),
    width: (width ?? defaultWidthOfDrawer) - 2 * 24,
    decoration: BoxDecoration(
      color: kBgDarkColor,
      borderRadius: BorderRadius.circular(kradius),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: nWidth,
          height: nWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ShimmerContainer(
            height: nWidth,
            width: nWidth,
          ),
        ),
        SizedBox(width: kDefaultPadding / 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: defaultPadding / 4),
            ShimmerContainer(
              height: 12,
              width: 100,
              borderRadius: BorderRadius.circular(10),
              margin: EdgeInsets.only(left: 4, top: 4, bottom: 8),
            ),
            ShimmerContainer(
              height: 10,
              width: 90,
              borderRadius: BorderRadius.circular(10),
              margin: EdgeInsets.only(left: 4, bottom: 4),
            ),
            SizedBox(height: defaultPadding / 4),
          ],
        ),
        Spacer(),
        InkWell(
          //onTap: onClose ?? () => context.router.pop(),
          child: Icon(
            Icons.close,
            size: 30,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
