import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/internal/constants.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../kconstants.dart';

class Tags extends StatelessWidget {
  const Tags({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            WebsafeSvg.asset("assets/Icons/Angle down.svg", width: 16),
            SizedBox(width: kDefaultPadding / 4),
            WebsafeSvg.asset("assets/Icons/Markup.svg", width: 20),
            SizedBox(width: kDefaultPadding / 2),
            Text(
              "Tags",
              style: Theme.of(context).textTheme.button!.copyWith(color: kGrayColor),
            ),
            Spacer(),
            MaterialButton(
              padding: EdgeInsets.all(10),
              minWidth: 40,
              onPressed: () {},
              child: Icon(
                MdiIcons.eyeCheck,
                color: kGrayColor,
                size: 20,
              ),
            )
          ],
        ),
        SizedBox(height: kDefaultPadding / 2),
        buildTag(context, color: Colors.purple, title: Role.admin),
        buildTag(context, color: Colors.pink, title: Role.minister),
        buildTag(context, color: Colors.blue, title: Role.hod),
        buildTag(context, color: Colors.orange, title: Role.worker),
        buildTag(context, color: Colors.green, title: Role.member),
        buildTag(context, color: Colors.brown, title: Role.teenager),
        buildTag(context, color: Colors.yellow, title: Role.visitor),
        buildTag(context, color: Colors.red, title: Role.returningVisitor),
      ],
    );
  }

  InkWell buildTag(BuildContext context, {required Color color, required String title}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kDefaultPadding * 1.5, 10, 0, 10),
        child: Row(
          children: [
            WebsafeSvg.asset(
              "assets/Icons/Markup filled.svg",
              height: 18,
              color: color,
            ),
            SizedBox(width: kDefaultPadding / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.button!.copyWith(color: kGrayColor),
            ),
          ],
        ),
      ),
    );
  }
}
