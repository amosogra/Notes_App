import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
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
import 'package:uuid/uuid.dart';

const double bodyTextSizeLg = 16.0;
const double bodyTextSizeSm = 14.0;
const double socialTextSizeLg = 18.0;
const double socialTextSizeSm = 14.0;
const double sidePadding = Sizes.PADDING_16;

class HeaderSectionMobile extends StatefulWidget {
  const HeaderSectionMobile({Key? key}) : super(key: key);

  @override
  _HeaderSectionMobileState createState() => _HeaderSectionMobileState();
}

class _HeaderSectionMobileState extends State<HeaderSectionMobile> with SingleTickerProviderStateMixin {
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
    double headerIntroTextSize = Sizes.TEXT_SIZE_24;
    double screenWidth = widthOfScreen(context) - (sidePadding * 2);
    double contentAreaWidth = screenWidth;
    TextStyle? bodyTextStyle = textTheme.bodyText1?.copyWith(fontSize: bodyTextSizeSm);
    TextStyle? socialTitleStyle = textTheme.subtitle1?.copyWith(fontSize: socialTextSizeSm);

    double buttonWidth = 80;
    double buttonHeight = 48;

    double sizeOfBlobSm = screenWidth * 0.4;
    double sizeOfGoldenGlobe = screenWidth * 0.3;
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
                      left: -(sizeOfGoldenGlobe / 3),
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
                  right: -(sizeOfBlobSm) + 30,
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
                    margin: EdgeInsets.only(top: heightOfStack * 0.1),
                    child: SelectableText(
                      StringConst.FIRST_NAME_MOBILE,
                      style: textTheme.headline1?.copyWith(
                        color: config.darkThemeEnabled ? AppColors.grey50.withOpacity(0.2) : AppColors.grey50,
                        fontSize: headerIntroTextSize * 2.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                    margin: EdgeInsets.only(top: heightOfStack * 0.3),
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
                                    StringConst.INTRO_MOBILE,
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
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.5),
                              child: SelectableText(
                                StringConst.ABOUT_DEV,
                                style: bodyTextStyle?.copyWith(
                                  height: 1.5,
                                  // color: AppColors.black,
                                ),
                              ),
                            ),
                            SpaceH30(),
                            Wrap(
                              children: buildSocialIcons(Data.socialData, config),
                            ),
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
                                else
                                  (DateTime.now().weekday == DateTime.sunday || DateTime.now().weekday == DateTime.wednesday)
                                      ? NimbusButton(
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
                                      : Container(),
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
              SpaceH40(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sidePadding,
                ),
                child: Column(
                  children: buildCardRow(
                    context: context,
                    data: Data.nimbusCardData,
                    width: contentAreaWidth,
                    isHorizontal: false,
                    hasAnimation: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
