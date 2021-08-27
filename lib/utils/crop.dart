import 'dart:typed_data';
import 'dart:ui' as ui;
import 'centered_slider_track_shape.dart';
import 'package:flutter/material.dart';
import 'package:crop/crop.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'log.dart';
//import 'package:permission_handler/permission_handler.dart';

class CropImage extends StatefulWidget {
  final bool Function(Uint8List data) onDoneCropping;

  final Uint8List bytes;
  const CropImage({Key? key, required this.bytes, required this.onDoneCropping}) : super(key: key);

  @override
  _CropImageState createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  final controller = CropController(aspectRatio: 1000 / 667.0);
  double _rotation = 0;
  BoxShape shape = BoxShape.rectangle;

  ui.Image? croppedImage;

  @override
  void dispose() {
    croppedImage?.dispose();
    super.dispose();
  }

  Future<void> _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    croppedImage = await controller.crop(pixelRatio: pixelRatio);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Crop Result'),
            centerTitle: true,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    /* final status = await Permission.storage.request();
                    if (status == PermissionStatus.granted) {
                      await _saveScreenShot(cropped);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image Cropped Successfully!'),
                        ),
                      );
                    } */
                    await _saveScreenShot(croppedImage!).then((cropped) {
                      if (cropped != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image Cropped Successfully!'),
                          ),
                        );

                        widget.onDoneCropping(cropped);
                        Navigator.of(context).pop(true);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          body: Center(
            child: RawImage(
              image: croppedImage,
            ),
          ),
        ),
        fullscreenDialog: true,
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            launch('https://ecomnetworks.codemagic.app');
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await _cropImage();
              Navigator.of(context).pop(true);
            },
            tooltip: 'Crop',
            icon: Icon(Icons.crop),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(8),
              child: Crop(
                onChanged: (decomposition) {
                  log("Scale : ${decomposition.scale}, Rotation: ${decomposition.rotation}, translation: ${decomposition.translation}");
                },
                controller: controller,
                shape: shape,
                child: Image.memory(
                  widget.bytes,
                  fit: BoxFit.cover,
                ),
                /* It's very important to set `fit: BoxFit.cover`.
                   Do NOT remove this line.
                   There are a lot of issues on github repo by people who remove this line and their image is not shown correctly.
                */
                foreground: IgnorePointer(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'House Of Glory',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
                helper: shape == BoxShape.rectangle
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.undo,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Undo',
                onPressed: () {
                  controller.rotation = 0;
                  controller.scale = 1;
                  controller.offset = Offset.zero;
                  setState(() {
                    _rotation = 0;
                  });
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme.copyWith(
                    trackShape: CenteredRectangularSliderTrackShape(),
                  ),
                  child: Slider(
                    divisions: 360,
                    value: _rotation,
                    min: -180,
                    max: 180,
                    label: '$_rotation°',
                    onChanged: (n) {
                      setState(() {
                        _rotation = n.roundToDouble();
                        controller.rotation = _rotation;
                      });
                    },
                  ),
                ),
              ),
              PopupMenuButton<BoxShape>(
                icon: Icon(
                  Icons.crop_free,
                  color: theme.colorScheme.primary,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text("Box"),
                    value: BoxShape.rectangle,
                  ),
                  PopupMenuItem(
                    child: Text("Oval"),
                    value: BoxShape.circle,
                  ),
                ],
                tooltip: 'Crop Shape',
                onSelected: (x) {
                  setState(() {
                    shape = x;
                  });
                },
              ),
              PopupMenuButton<double>(
                icon: Icon(
                  Icons.aspect_ratio,
                  color: theme.colorScheme.primary,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text("Original"),
                    value: 1000 / 667.0,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text("16:9"),
                    value: 16.0 / 9.0,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  PopupMenuItem(
                    child: Text("4:3"),
                    value: 4.0 / 3.0,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  PopupMenuItem(
                    child: Text("1:1"),
                    value: 1,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  PopupMenuItem(
                    child: Text("3:4"),
                    value: 3.0 / 4.0,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  PopupMenuItem(
                    child: Text("9:16"),
                    value: 9.0 / 16.0,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
                tooltip: 'Aspect Ratio',
                onSelected: (x) {
                  controller.aspectRatio = x;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Uint8List?> _saveScreenShot(ui.Image img) async {
  var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  var buffer = byteData?.buffer.asUint8List();
  //final result = await ImageGallerySaver.saveImage(buffer);
  //log(result);

  return buffer /* result */;
}
