import 'package:flutter/material.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/presentation/layout/adaptive.dart';
import 'package:notes_app/presentation/widgets/bullet_text.dart';
import 'package:notes_app/presentation/widgets/content_area.dart';
import 'package:notes_app/presentation/widgets/nimbus_info_section.dart';
import 'package:notes_app/presentation/widgets/spaces.dart';
import 'package:notes_app/values/values.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MeetingsSection extends StatefulWidget {
  MeetingsSection({Key? key});
  @override
  _MeetingsSectionState createState() => _MeetingsSectionState();
}

class _MeetingsSectionState extends State<MeetingsSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool text1InView = false;
  bool text2InView = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _controller.forward();
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = widthOfScreen(context) - (getSidePadding(context));
    double screenHeight = heightOfScreen(context);
    double contentAreaWidth = responsiveSize(
      context,
      screenWidth,
      screenWidth * 0.5,
      md: screenWidth * 0.5,
    );
    double contentAreaHeight = screenHeight * 0.9;
    return VisibilityDetector(
      key: Key('awards-section'),
      onVisibilityChanged: (visibilityInfo) {
        double visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 50) {
          setState(() {
            text1InView = true;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: getSidePadding(context)),
        child: ResponsiveBuilder(
          refinedBreakpoints: RefinedBreakpoints(),
          builder: (context, sizingInformation) {
            double screenWidth = sizingInformation.screenSize.width;
            if (screenWidth <= 1024) {
              return Column(
                children: [
                  ResponsiveBuilder(
                    builder: (context, sizingInformation) {
                      double screenWidth = sizingInformation.screenSize.width;
                      if (screenWidth < (RefinedBreakpoints().tabletSmall)) {
                        return _buildMeetingInfoSectionSm();
                      } else {
                        return _buildMeetingInfoSectionLg();
                      }
                    },
                  ),
                  SpaceH20(),
                  ResponsiveBuilder(
                    builder: (context, sizingInformation) {
                      double screenWidth = sizingInformation.screenSize.width;
                      if (screenWidth < (RefinedBreakpoints().tabletSmall)) {
                        return _buildImage(
                          width: screenWidth,
                          height: screenHeight * 0.5,
                        );
                      } else {
                        return Center(
                          child: _buildImage(
                            width: screenWidth * 0.75,
                            height: screenHeight,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContentArea(
                    width: contentAreaWidth,
                    height: contentAreaHeight,
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                //Spacer(),
                                _buildMeetingInfoSectionLg(),
                                Spacer(flex: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        //SizedBox(height: defaultPadding/2),
                        _buildImage(
                          width: contentAreaWidth,
                          height: contentAreaHeight,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMeetingInfoSectionSm() {
    return NimbusInfoSection2(
      sectionTitle: StringConst.WHY_CHOSE_US,
      title1: StringConst.BENEFITS_TITLE,
      hasTitle2: false,
      body: StringConst.BENEFITS_DESC,
      child: Column(
        children: [
          _buildMeetings1(),
          SpaceH40(),
        ],
      ),
    );
  }

  Widget _buildMeetingInfoSectionLg() {
    return NimbusInfoSection1(
      sectionTitle: StringConst.WHY_CHOSE_US,
      title1: StringConst.BENEFITS_TITLE,
      hasTitle2: false,
      body: StringConst.BENEFITS_DESC,
      child: Container(
        child: Row(
          children: [
            _buildMeetings1(),
            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({
    required double width,
    required double height,
  }) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.bodyText1?.merge(
      Styles.customTextStyle3(
        fontSize: responsiveSize(context, 64, 80, md: 76),
        height: 1.25,
        color: AppColors.primaryColor,
      ),
    );

    TextStyle? titleStyleSm = textTheme.bodyText1?.merge(
      Styles.customTextStyle3(
        fontSize: responsiveSize(context, 45, 60, sm: 56),
        height: 1.25,
        color: AppColors.primaryColor,
      ),
    );
    double textPosition = assignWidth(context, 0.05);
    return Center(
      child: ContentArea(
        width: width,
        height: height,
        child: Stack(
          children: [
            Stack(
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  top: Sizes.HEIGHT_130,
                  child: ResponsiveBuilder(
                    refinedBreakpoints: RefinedBreakpoints(),
                    builder: (context, sizingInformation) {
                      double screenWidth = sizingInformation.screenSize.width;
                      if (screenWidth < (RefinedBreakpoints().tabletSmall)) {
                        return RotationTransition(
                          turns: _controller,
                          child: Image.asset(
                            ImagePath.DOTS_GLOBE_YELLOW,
                            width: Sizes.WIDTH_150,
                            height: Sizes.HEIGHT_150,
                          ),
                        );
                      } else {
                        return RotationTransition(
                          turns: _controller,
                          child: Image.asset(
                            ImagePath.DOTS_GLOBE_YELLOW,
                          ),
                        );
                      }
                    },
                  ),
                ),
                Image.asset(
                  ImagePath.DEV_AWARD,
                ),
                ResponsiveBuilder(
                  refinedBreakpoints: RefinedBreakpoints(),
                  builder: (context, sizingInformation) {
                    double screenWidth = sizingInformation.screenSize.width;
                    if (screenWidth < (RefinedBreakpoints().tabletSmall)) {
                      return Stack(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              AnimatedPositioned(
                                left: text1InView ? textPosition : -150,
                                child: Text(StringConst.JESUS, style: titleStyleSm),
                                curve: Curves.fastOutSlowIn,
                                onEnd: () {
                                  setState(() {
                                    text2InView = true;
                                  });
                                },
                                duration: Duration(milliseconds: 750),
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              AnimatedPositioned(
                                right: text2InView ? textPosition : -150,
                                child: Text(StringConst.LIVES, style: titleStyleSm),
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 750),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Stack(
                        children: [
                          AnimatedPositioned(
                            left: text1InView ? textPosition : -150,
                            child: Text(StringConst.JESUS, style: titleStyle),
                            curve: Curves.fastOutSlowIn,
                            onEnd: () {
                              setState(() {
                                text2InView = true;
                              });
                            },
                            duration: Duration(milliseconds: 750),
                          ),
                          AnimatedPositioned(
                            right: text2InView ? textPosition : -150,
                            child: Text(StringConst.LIVES, style: titleStyle),
                            curve: Curves.fastOutSlowIn,
                            duration: Duration(milliseconds: 750),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetings1() {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.BENEFITS_TYPE_TITLE_2,
          style: textTheme.headline6,
        ),
        SpaceH16(),
        ..._buildMeetings(Data.services),
      ],
    );
  }

  List<Widget> _buildMeetings(List<String> awards) {
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
}
