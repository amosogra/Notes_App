// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Packages
//import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:notes_app/internal/languages.dart';
import 'package:notes_app/ui/animations/FadeIn.dart';
import 'package:notes_app/ui/animations/showUp.dart';

class AccentPicker extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;
  AccentPicker({required this.onColorChanged});
  @override
  _AccentPickerState createState() => _AccentPickerState();
}

class _AccentPickerState extends State<AccentPicker> {
  Color? currentColor;

  @override
  Widget build(BuildContext context) {
    //currentColor = Theme.of(context).accentColor;
    return FadeInTransition(
      duration: Duration(milliseconds: 250),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          height: 600,
          width: 400,
          child: Column(
            children: <Widget>[
              Container(
                width: 400,
                padding: EdgeInsets.only(top: 24, bottom: 16),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    color: Theme.of(context).accentColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12.withOpacity(0.10),
                          offset: Offset(0, 3), //(x,y)
                          blurRadius: 6.0,
                          spreadRadius: 0.11)
                    ]),
                child: ShowUpTransition(
                  forward: true,
                  delay: Duration(milliseconds: 100),
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    Languages.of(context)!.labelChooseColor,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: FadeInTransition(
                  delay: Duration(milliseconds: 200),
                  duration: Duration(milliseconds: 200),
                  child: MaterialPicker(
                    //paletteType: PaletteType.rgb,
                    pickerColor: Theme.of(context).accentColor,
                    onColorChanged: (Color value) {
                      widget.onColorChanged(value);
                    },
                  ),
                ),
              ),
              TextButton(
                child: const Text('Got it'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
