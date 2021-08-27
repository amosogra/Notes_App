import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/extensions.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:notes_app/models/user_model.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:timeago/timeago.dart' as timeago;

var tagColor = {
  Role.admin: Colors.purple,
  Role.minister: Colors.pink,
  Role.hod: Colors.blue,
  Role.worker: Colors.orange,
  Role.member: Colors.green,
  Role.teenager: Colors.brown,
  Role.visitor: Colors.yellow,
  Role.returningVisitor: Colors.red,
};

class PrayerCard extends StatefulWidget {
  const PrayerCard({
    Key? key,
    this.isActive = false,
    this.user,
    this.press,
  }) : super(key: key);

  final bool isActive;
  final PrayerRequester? user;
  final VoidCallback? press;

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  Here the shadow is not showing properly
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: InkWell(
        onTap: widget.press,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? kPrimaryColor
                    : config.darkThemeEnabled
                        ? Colors.transparent
                        : kBgDarkColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: CachedNetworkImageProvider(widget.user!.avatarUrl!),
                        ),
                      ),
                      SizedBox(width: kDefaultPadding / 2),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "${widget.user?.firstName ?? 'Unknown'} ${widget.user?.lastName ?? 'User'} \n",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: widget.isActive
                                  ? Colors.white
                                  : config.darkThemeEnabled
                                      ? Colors.white
                                      : kTextColor,
                            ),
                            children: [
                              TextSpan(
                                text: "${widget.user!.role!.toLowerCase()} profile \n",
                                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                                      color: widget.isActive
                                          ? Colors.white.withOpacity(0.7)
                                          : config.darkThemeEnabled
                                              ? Colors.white70
                                              : kTextColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            timeago.format((widget.user?.timestamp ?? Timestamp.now()).toDate()),
                            style: Theme.of(context).textTheme.caption!.copyWith(
                                  color: widget.isActive
                                      ? Colors.white70
                                      : config.darkThemeEnabled
                                          ? Colors.white70
                                          : null,
                                ),
                          ),
                          SizedBox(height: 5),
                          if (widget.user?.prayed == false)
                            WebsafeSvg.asset(
                              "assets/Icons/Paperclip.svg",
                              color: widget.isActive
                                  ? Colors.white70
                                  : config.darkThemeEnabled
                                      ? Colors.white
                                      : kGrayColor,
                            )
                        ],
                      ),
                    ],
                  ),
                  //SizedBox(height: kDefaultPadding / 4),
                  Text(
                    widget.user?.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          height: 1.5,
                          color: widget.isActive
                              ? Colors.white70
                              : config.darkThemeEnabled
                                  ? Colors.white
                                  : null,
                        ),
                  )
                ],
              ),
            ).addNeumorphism(
              blurRadius: 15,
              borderRadius: 15,
              offset: Offset(5, 5),
              topShadowColor: config.darkThemeEnabled ? secondaryColorD : Colors.white60,
              bottomShadowColor: /* config.darkThemeEnabled ? Colors.yellow.withOpacity(0.15) : */ Color(0xFF234395).withOpacity(0.15),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.user!.prayed! ? kBadgeOnlineColor : kBadgeOfflineColor,
                ),
              ).addNeumorphism(
                blurRadius: 4,
                borderRadius: 8,
                offset: Offset(2, 2),
              ),
            ),
            //if (user.tagColor != null)
            Positioned(
              left: 8,
              top: 0,
              child: WebsafeSvg.asset(
                "assets/Icons/Markup filled.svg",
                height: 18,
                color: tagColor[widget.user!.role!],
              ),
            )
          ],
        ),
      ),
    );
  }
}
