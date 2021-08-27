// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/internal/languages.dart';
import 'package:notes_app/providers/configurationProvider.dart';
import 'package:notes_app/ui/AppTheme.dart';
import 'package:notes_app/ui/notifiers/accentPicker.dart';
import 'package:notes_app/utils/SizeConfig.dart';

// Packages
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../../kconstants.dart';

class ThemeSettings extends StatefulWidget {
  @override
  _ThemeSettingsState createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> with TickerProviderStateMixin {
  bool carouselScrollDirection = false;
  var db = Hive.box('settings');
  @override
  void initState() {
    super.initState();
    carouselScrollDirection = db.get('carouselScrollDirection', defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        backgroundColor: Theme.of(context).accentColor,
        title: Text.rich(
          TextSpan(
            text: "Theme Settings".toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.3),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: Text(
                Languages.of(context)?.labelUseSystemTheme ?? "Use System Theme",
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                Languages.of(context)?.labelUseSystemThemeJustification ?? "Enable/Disable automatic Theme",
                style: TextStyle(fontSize: 12),
              ),
              activeColor: Theme.of(context).accentColor,
              value: config.systemThemeEnabled,
              onChanged: (bool newValue) async {
                config.systemThemeEnabled = newValue;
                await Future.delayed(Duration(seconds: 1));
                Brightness _systemBrightness = Theme.of(context).brightness;
                Brightness _statusBarBrightness = _systemBrightness == Brightness.light ? Brightness.dark : Brightness.light;
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: _statusBarBrightness,
                    statusBarIconBrightness: _statusBarBrightness,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarIconBrightness: _statusBarBrightness,
                  ),
                );
              },
            ),
            SizedBox(height: kDefaultPadding / 2),
            // Enable/Disable Dark Theme
            AnimatedSize(
                vsync: this,
                curve: Curves.easeInOutBack,
                duration: Duration(milliseconds: 500),
                child: config.systemThemeEnabled == false
                    ? SwitchListTile(
                        title: Text(
                          Languages.of(context)?.labelEnableDarkTheme ?? "Enable Dark Theme",
                          style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          Languages.of(context)?.labelEnableDarkThemeJustification ?? "Use Dark Theme by default",
                          style: TextStyle(fontSize: 12),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: config.darkThemeEnabled,
                        onChanged: (bool newValue) async {
                          config.darkThemeEnabled = newValue;
                          await Future.delayed(Duration(seconds: 1));
                          Brightness _systemBrightness = Theme.of(context).brightness;
                          Brightness _statusBarBrightness = _systemBrightness == Brightness.light ? Brightness.dark : Brightness.light;
                          SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarBrightness: _statusBarBrightness,
                              statusBarIconBrightness: _statusBarBrightness,
                              systemNavigationBarColor: Colors.transparent,
                              systemNavigationBarIconBrightness: _statusBarBrightness,
                            ),
                          );
                        },
                      )
                    : Container()),
            SizedBox(height: kDefaultPadding / 2),
            // Enable/Disable Black Theme
            SwitchListTile(
              title: Text(
                Languages.of(context)?.labelEnableBlackTheme ?? "Enable Black Theme",
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                Languages.of(context)?.labelEnableBlackThemeJustification ?? "Enable Pure Black Theme",
                style: TextStyle(fontSize: 12),
              ),
              activeColor: Theme.of(context).accentColor,
              value: config.blackThemeEnabled,
              onChanged: (bool newValue) async {
                config.blackThemeEnabled = newValue;
                await Future.delayed(Duration(seconds: 1));
                Brightness _systemBrightness = Theme.of(context).brightness;
                Brightness _statusBarBrightness = _systemBrightness == Brightness.light ? Brightness.dark : Brightness.light;
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: _statusBarBrightness,
                    statusBarIconBrightness: _statusBarBrightness,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarIconBrightness: _statusBarBrightness,
                  ),
                );
              },
            ),
            SizedBox(height: kDefaultPadding / 2),
            SwitchListTile(
              title: Text(
                "Carousel Scroll Direction",
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                carouselScrollDirection ? "Axis.vertical" : "Axis.horizontal",
                style: TextStyle(fontSize: 12),
              ),
              value: carouselScrollDirection,
              activeColor: Theme.of(context).accentColor,
              onChanged: (bool value) async {
                db.put('carouselScrollDirection', value);
                setState(() {
                  carouselScrollDirection = value;
                });
              },
            ),
            SizedBox(height: kDefaultPadding / 2),
            // App AccentColor Setting
            ListTile(
              onTap: () => config.systemThemeEnabled = !config.systemThemeEnabled,
              title: Text(
                Languages.of(context)?.labelAccentColor ?? "Accent Color",
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                Languages.of(context)?.labelAccentColorJustification ?? "Customize accent color",
                style: TextStyle(fontSize: 12),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: IconButton(
                  icon: Icon(Icons.colorize),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AccentPicker(
                          onColorChanged: (Color color) {
                            config.accentColor = color;
                            //Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
