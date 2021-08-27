import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notes_app/authentication/authenticate/authenticate.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/models/CheckedIn.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/presentation/layout/adaptive.dart';
import 'package:notes_app/presentation/pages/home/sections/header_section/widgets.dart';
import 'package:notes_app/presentation/widgets/buttons/nimbus_button.dart';
import 'package:notes_app/presentation/widgets/content_area.dart';
import 'package:notes_app/presentation/widgets/spaces.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/screens/home/edit_profile_screen.dart';
import 'package:notes_app/utils/globals.dart';
import 'package:notes_app/utils/log.dart';
import 'package:notes_app/values/values.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

//TODO:: Later
//TODO:: Animation to button. (Channel your adventurous self)

const double bodyTextSizeLg = 16.0;
const double bodyTextSizeSm = 14.0;
const double socialTextSizeLg = 18.0;
const double socialTextSizeSm = 14.0;
// const double sidePadding = Sizes.PADDING_16;

class HeaderSectionWeb extends StatefulWidget {
  @override
  _HeaderSectionWebState createState() => _HeaderSectionWebState();
}

class _HeaderSectionWebState extends State<HeaderSectionWeb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    TextTheme textTheme = Theme.of(context).textTheme;
    final loggeduser = Provider.of<auth.User?>(context);
    final config = Provider.of<ConfigurationProvider>(context);
    double sidePadding = getSidePadding(context);
    double headerIntroTextSize = responsiveSize(
      context,
      Sizes.TEXT_SIZE_24,
      Sizes.TEXT_SIZE_56,
      md: Sizes.TEXT_SIZE_36,
    );
    double bodyTextSize = responsiveSize(context, bodyTextSizeSm, bodyTextSizeLg);
    double socialTextSize = responsiveSize(context, socialTextSizeSm, socialTextSizeLg);
    double screenWidth = widthOfScreen(context);
    double screenHeight = heightOfScreen(context);
    double contentAreaWidth = screenWidth;
    double contentAreaHeight = screenHeight * 0.8;
    double widthOfBlackBlob = contentAreaWidth * 0.5;
    double hiddenPortionOfBlackBlob = widthOfBlackBlob * 0.95;
    TextStyle? bodyTextStyle = textTheme.bodyText1?.copyWith(fontSize: bodyTextSize);
    TextStyle? socialTitleStyle = textTheme.subtitle1?.copyWith(fontSize: socialTextSize);

    List<Widget> cardsForTabletView = buildCardRow(
      context: context,
      data: Data.nimbusCardData,
      width: contentAreaWidth * 0.4,
      isWrap: true,
    );
    double buttonWidth = responsiveSize(
      context,
      80,
      150,
    );
    double buttonHeight = responsiveSize(
      context,
      48,
      60,
      md: 54,
    );

    double sizeOfBlobSm = screenWidth * 0.3;
    double sizeOfGoldenGlobe = screenWidth * 0.2;
    double dottedGoldenGlobeOffset = sizeOfBlobSm * 0.4;
    double heightOfBlobAndGlobe = computeHeight(dottedGoldenGlobeOffset, sizeOfGoldenGlobe, sizeOfBlobSm);
    double heightOfStack = heightOfBlobAndGlobe * 2;
    double blobOffset = heightOfStack * 0.3;
    return ContentArea(
      child: Stack(
        children: [
          Container(
            height: heightOfStack,
            child: Stack(
              children: [
                Stack(
                  children: [
                    Positioned(
                      left: -(sizeOfBlobSm * 0.7),
                      top: blobOffset,
                      child: Image.asset(
                        ImagePath.BLOB_BLACK,
                        height: sizeOfBlobSm,
                        width: sizeOfBlobSm,
                      ),
                    ),
                    Positioned(
                      left: -(sizeOfGoldenGlobe * 0.5),
                      top: blobOffset + dottedGoldenGlobeOffset,
                      child: RotationTransition(
                        turns: _controller,
                        child: Image.asset(
                          ImagePath.DOTS_GLOBE_YELLOW,
                          width: sizeOfGoldenGlobe,
                          height: sizeOfGoldenGlobe,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: -(sizeOfBlobSm * 0.8) + 15,
                  child: HeaderImage(
                    controller: _controller,
                    globeSize: sizeOfGoldenGlobe,
                    imageHeight: heightOfStack,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: heightOfStack * 0.05),
                    child: ResponsiveBuilder(
                      refinedBreakpoints: RefinedBreakpoints(),
                      builder: (context, sizingInformation) {
                        double screenWidth = sizingInformation.screenSize.width;
                        if (screenWidth < RefinedBreakpoints().desktopSmall) {
                          log("$screenWidth");
                          return SelectableText(
                            StringConst.FIRST_NAME_MOBILE,
                            style: textTheme.headline1?.copyWith(
                              color: config.darkThemeEnabled ? AppColors.grey50.withOpacity(0.2) : AppColors.grey50,
                              fontSize: headerIntroTextSize * 2,
                            ),
                          );
                        } else {
                          return SelectableText(
                            StringConst.FIRST_NAME,
                            style: textTheme.headline1?.copyWith(
                              color: config.darkThemeEnabled ? AppColors.grey50.withOpacity(0.2) : AppColors.grey50,
                              fontSize: headerIntroTextSize * 2,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: heightOfStack * 0.2, left: (sizeOfBlobSm * 0.35)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: screenWidth),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    StringConst.INTRO,
                                    speed: Duration(milliseconds: 60),
                                    textStyle: textTheme.headline2?.copyWith(
                                      fontSize: headerIntroTextSize,
                                    ),
                                  ),
                                ],
                                onTap: () {},
                                isRepeatingAnimation: true,
                                totalRepeatCount: 5,
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: screenWidth),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    StringConst.POSITION,
                                    speed: Duration(milliseconds: 80),
                                    textStyle: textTheme.headline2?.copyWith(
                                      fontSize: headerIntroTextSize,
                                      color: AppColors.primaryColor,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                                onTap: () {},
                                isRepeatingAnimation: true,
                                totalRepeatCount: 5,
                              ),
                            ),
                            SpaceH16(),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.35),
                              child: SelectableText(
                                StringConst.ABOUT_DEV,
                                style: bodyTextStyle?.copyWith(height: 1.5),
                              ),
                            ),
                            SpaceH30(),
                            Wrap(
                              children: buildSocialIcons(Data.socialData, config),
                            ),
                            /* SpaceH30(),
                            Wrap(
                              // mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      "${StringConst.EMAIL}:",
                                      style: socialTitleStyle,
                                    ),
                                    SpaceH8(),
                                    SelectableText(
                                      "${StringConst.DEV_EMAIL_2}",
                                      style: bodyTextStyle,
                                    ),
                                  ],
                                ),
                                SpaceW16(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      "${StringConst.BEHANCE}:",
                                      style: socialTitleStyle,
                                    ),
                                    SpaceH8(),
                                    SelectableText(
                                      "${StringConst.BEHANCE_ID}",
                                      style: bodyTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ), */
                            SpaceH40(),
                            Row(
                              children: [
                                if (loggeduser?.uid == null)
                                  NimbusButton(
                                    width: buttonWidth,
                                    height: buttonHeight,
                                    buttonTitle: StringConst.JOIN_US_NOW,
                                    //buttonColor: AppColors.primaryColor,
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
                                    },
                                  )
                                else if (DateTime.now().weekday == DateTime.sunday || DateTime.now().weekday == DateTime.wednesday)
                                  NimbusButton(
                                    width: buttonWidth,
                                    height: buttonHeight,
                                    buttonTitle: StringConst.CHECK_IN,
                                    //buttonColor: AppColors.primaryColor,
                                    onPressed: () {
                                      EasyLoading.show();
                                      FirebaseFirestore.instance.collection(Constants.users).doc(loggeduser?.uid).get().then((doc) async {
                                        var user = User.fromJson(doc.data() ?? {});
                                        Globals().updateGlobalUser(user);
                                        if (user.firstName == null) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                                          EasyLoading.showToast("Please update your profile information");
                                          return;
                                        } else {
                                          var checkins = user.checkins
                                                  ?.where((checkin) =>
                                                      checkin.timestamp.millisecondsSinceEpoch >=
                                                      Timestamp.fromDate(DateTime.now().subtract(new Duration(days: 1))).millisecondsSinceEpoch)
                                                  .toList() ??
                                              [];

                                          if (checkins.length > 0) {
                                            EasyLoading.showInfo("You have been checked in already..stay welcomed.");
                                            return;
                                          }
                                          await FirebaseFirestore.instance.collection(Constants.users).doc(loggeduser?.uid).update({
                                            'lastCheckedInTimestamp': FieldValue.serverTimestamp(),
                                            'checkins': FieldValue.arrayUnion([
                                              CheckedIn(
                                                id: "${user.uid!.substring(0, user.uid!.length ~/ 4)}-${Uuid().v1().length}",
                                                uid: user.uid!,
                                                name: "${user.firstName ?? 'Unknown'}-${user.lastName ?? ''}",
                                                image: user.avatarUrl ?? '',
                                                role: user.role ?? '${Role.visitor}',
                                                regulatory: false,
                                                timestamp: Timestamp.now(),
                                                address: user.address,
                                              ).toJson()
                                            ])
                                          }).then((v) {
                                            EasyLoading.showSuccess("Checked In");
                                          }, onError: (err, StackTrace stacktrace) {
                                            log(err);
                                            log(stacktrace.toString());
                                            EasyLoading.showError("Something went wrong, please try check your internet connection and try again..");
                                          });
                                        }
                                      }, onError: (err, StackTrace stacktrace) {
                                        log(err);
                                        log(stacktrace.toString());
                                        EasyLoading.showError("Something went wrong, please try again..");
                                      });
                                    },
                                  )
                                else
                                  Container(),
                                SpaceW16(),
                              ],
                            ),
                            SpaceH30(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 150),
              Container(
                margin: EdgeInsets.only(left: (sizeOfBlobSm * 0.35)),
                child: ResponsiveBuilder(
                  refinedBreakpoints: RefinedBreakpoints(),
                  builder: (context, sizingInformation) {
                    double screenWidth = sizingInformation.screenSize.width;
                    if (screenWidth < RefinedBreakpoints().tabletNormal) {
                      return Container(
                        margin: EdgeInsets.only(right: (sizeOfBlobSm * 0.35)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buildCardRow(
                            context: context,
                            data: Data.nimbusCardData,
                            width: contentAreaWidth,
                            isHorizontal: false,
                            hasAnimation: false,
                          ),
                        ),
                      );
                    } else if (screenWidth >= RefinedBreakpoints().tabletNormal && screenWidth <= 1024) {
                      log("Width: $screenWidth");
                      return Wrap(
                        runSpacing: 24,
                        children: [
                          SizedBox(width: contentAreaWidth * 0.03),
                          cardsForTabletView[0],
                          SpaceW40(),
                          cardsForTabletView[1],
                          //SizedBox(width: contentAreaWidth * 0.03),
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: cardsForTabletView[2],
                            ),
                          ),
                        ],
                      );
                    } else {
                      log("WIDE WIDTH: $screenWidth");
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...buildCardRow(
                                context: context,
                                data: Data.nimbusCardData,
                                width: contentAreaWidth / 3.8,
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeaderImage() {
    return ResponsiveBuilder(
      refinedBreakpoints: RefinedBreakpoints(),
      builder: (context, sizingInformation) {
        double screenWidth = sizingInformation.screenSize.width;
        if (screenWidth < RefinedBreakpoints().tabletSmall) {
          return Align(
            alignment: Alignment(5, -1.0),
            child: AspectRatio(
              aspectRatio: 2.5 / 4,
              child: Align(
                alignment: Alignment(5, -1.0),
                child: HeaderImage(
                  controller: _controller,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        } else if (screenWidth >= RefinedBreakpoints().tabletSmall && screenWidth <= RefinedBreakpoints().tabletExtraLarge) {
          return Align(
            alignment: Alignment(2, -1.0),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Align(
                alignment: Alignment(2, -1.0),
                child: HeaderImage(
                  controller: _controller,
                  globeSize: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        } else {
          return Align(
            alignment: Alignment(1.5, -1.5),
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Align(
                alignment: Alignment(1.5, -1.5),
                child: HeaderImage(
                  controller: _controller,
                  globeSize: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
