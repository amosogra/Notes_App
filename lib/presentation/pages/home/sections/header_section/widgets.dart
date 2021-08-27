import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/presentation/layout/adaptive.dart';
import 'package:notes_app/presentation/widgets/bullet_text.dart';
import 'package:notes_app/presentation/widgets/buttons/social_button.dart';
import 'package:notes_app/presentation/widgets/circular_container.dart';
import 'package:notes_app/presentation/widgets/nimbus_card.dart';
import 'package:notes_app/presentation/widgets/spaces.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/utils/functions.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({
    Key? key,
    required this.controller,
    this.globeSize = 150,
    this.imageHeight,
    this.imageWidth,
    this.fit,
  }) : super(key: key);

  final double? globeSize;
  final double? imageWidth;
  final double? imageHeight;
  final BoxFit? fit;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          child: RotationTransition(
            turns: controller,
            child: Image.asset(
              ImagePath.DOTS_GLOBE_GREY,
              height: globeSize,
              width: globeSize,
            ),
          ),
        ),
        Image.asset(
          ImagePath.DEV_HEADER,
          width: imageWidth,
          height: imageHeight,
          fit: fit,
        ),
      ],
    );
  }
}

List<Widget> buildSocialIcons(List<SocialButtonData> socialItems, ConfigurationProvider config) {
  List<Widget> items = [];
  for (int index = 0; index < socialItems.length; index++) {
    items.add(
      InkWell(
        onTap: () => openUrlLink(socialItems[index].url),
        child: Icon(
          socialItems[index].iconData,
          color: config.darkThemeEnabled ? Colors.white : AppColors.black,
          size: Sizes.ICON_SIZE_18,
        ),
      ),
    );
    items.add(SpaceW20());
  }
  return items;
}

List<Widget> buildCardRow({
  required BuildContext context,
  required List<NimBusCardData> data,
  required double width,
  bool isHorizontal = true,
  bool isWrap = false,
  bool hasAnimation = true,
}) {
  TextTheme textTheme = Theme.of(context).textTheme;
  List<Widget> items = [];

  double cardWidth = responsiveSize(
    context,
    Sizes.WIDTH_32,
    Sizes.WIDTH_40,
    md: Sizes.WIDTH_36,
  );
  double iconSize = responsiveSize(
    context,
    Sizes.ICON_SIZE_18,
    Sizes.ICON_SIZE_24,
  );
  double trailingIconSize = responsiveSize(
    context,
    Sizes.ICON_SIZE_28,
    Sizes.ICON_SIZE_30,
    md: Sizes.ICON_SIZE_30,
  );
  for (int index = 0; index < data.length; index++) {
    items.add(
      InkWell(
        onTap: () {
          if (data[index].title == StringConst.OUR_MISSION) {
            _showDialog(context, _buildOurMission(context));
          } else if (data[index].title == StringConst.OUR_VISION) {
            _showDialog(context, _buildOurVission(context));
          } else {
            _showDialog(context, _buildOurPassion(context));
          }
        },
        child: NimBusCard(
          width: width,
          height: responsiveSize(
            context,
            125,
            130,
          ),
          hasAnimation: hasAnimation,
          leading: CircularContainer(
            width: cardWidth,
            height: cardWidth,
            iconSize: iconSize,
            backgroundColor: data[index].circleBgColor,
            iconColor: data[index].leadingIconColor,
          ),
          title: Flexible(
            child: SelectableText(
              data[index].title,
              style: textTheme.subtitle1?.copyWith(
                fontSize: responsiveSize(
                  context,
                  Sizes.TEXT_SIZE_16,
                  Sizes.TEXT_SIZE_18,
                ),
              ),
            ),
          ),
          subtitle: Flexible(
            child: SelectableText(
              data[index].subtitle,
              maxLines: 1,
              style: textTheme.bodyText1?.copyWith(
                  fontSize: responsiveSize(
                context,
                Sizes.TEXT_SIZE_14,
                Sizes.TEXT_SIZE_16,
              )),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: trailingIconSize,
            color: data[index].trailingIconColor,
          ),
        ),
      ),
    );
    //run this only on mobile devices and laptops but not on tablets.
    // We use `Wrap` to make the widgets wrap on the tablet view
    if (!isWrap) {
      if (isHorizontal) {
        items.add(SpaceW30());
      } else {
        items.add(SpaceH30());
      }
    }
  }

  return items;
}

double computeHeight(double offset, double sizeOfGlobe, double sizeOfBlob) {
  double sum = (offset + sizeOfGlobe) - sizeOfBlob;
  if (sum < 0) {
    return sizeOfBlob;
  } else {
    return sum + sizeOfBlob;
  }
}

Widget _buildOurMission(BuildContext context) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        StringConst.OUR_MISSION,
        style: textTheme.headline6,
      ),
      SpaceH16(),
      ..._buildBulletsWithText(Data.mission),
    ],
  );
}

Widget _buildOurVission(BuildContext context) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        StringConst.OUR_VISION,
        style: textTheme.headline6,
      ),
      SpaceH16(),
      ..._buildBulletsWithText(Data.vission),
    ],
  );
}

Widget _buildOurPassion(BuildContext context) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        StringConst.PROFESSIONALISM,
        style: textTheme.headline6,
      ),
      SpaceH16(),
      ..._buildBulletsWithText(Data.passion),
    ],
  );
}

List<Widget> _buildBulletsWithText(List<String> awards) {
  List<Widget> items = [];
  for (int index = 0; index < awards.length; index++) {
    items.add(
      TextWithBullet(
        text: awards[index],
        overflow: TextOverflow.fade,
      ),
    );
    items.add(SpaceH16());
  }
  return items;
}

_showDialog(BuildContext context, Widget widget) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Container(
          margin: EdgeInsets.only(top: 16),
          child: widget,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              'Okay',
              style: AppTheme.getTextStyle(Theme.of(context).textTheme.subtitle1, color: Theme.of(context).colorScheme.primary, fontWeight: 600, letterSpacing: 0.3),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
