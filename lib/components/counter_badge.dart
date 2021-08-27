import 'package:flutter/material.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:provider/provider.dart';

import '../kconstants.dart';
import '../extensions.dart';

class CounterBadge extends StatelessWidget {
  const CounterBadge({
    Key? key,
    required this.count,
  }) : super(key: key);

  final int count;

  @override
  Widget build(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: kBadgeOnlineColor, borderRadius: BorderRadius.circular(9)),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: Theme.of(context).textTheme.caption!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
      ),
    ).addNeumorphism(
      offset: Offset(4, 4),
      borderRadius: 9,
      blurRadius: 4,
      topShadowColor: config.darkThemeEnabled ? bgColorD : Colors.white,
      bottomShadowColor: Color(0xFF30384D).withOpacity(0.3),
    );
  }
}
