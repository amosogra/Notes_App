import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/components/rounded_icon_btn.dart';
import 'package:notes_app/kconstants.dart';
import 'package:notes_app/size_config.dart';

class PickUploadImages extends StatefulWidget {
  const PickUploadImages({Key? key, required this.images, this.add, this.remove, this.selected, this.showButtons = true}) : super(key: key);

  final List<String> images;
  final Function()? add;
  final ValueChanged<String>? remove;
  final ValueChanged<String>? selected;
  final bool showButtons;

  @override
  _PickUploadImagesState createState() => _PickUploadImagesState();
}

class _PickUploadImagesState extends State<PickUploadImages> {
  int selectedImage = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: getProportionateScreenWidth(20)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(widget.images.length, (index) => buildSmallProductPreview(index)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //Spacer(),
            widget.showButtons
                ? RoundedIconBtn(
                    icon: Icons.remove,
                    showShadow: true,
                    press: () {
                      if (selectedImage < widget.images.length) {
                        if (widget.remove != null && widget.images.length > 0) {
                          widget.remove!(widget.images[selectedImage]);
                        }
                      } else {
                        setState(() {
                          selectedImage--;
                        });
                      }
                    },
                  )
                : Container(),
            SizedBox(width: getProportionateScreenWidth(20)),
            widget.showButtons
                ? RoundedIconBtn(
                    icon: Icons.add,
                    showShadow: true,
                    press: widget.add,
                  )
                : Container(),
          ],
        ),
      ],
    );
  }

  GestureDetector buildSmallProductPreview(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = index;
        });

        if (widget.selected != null) {
          widget.selected!(widget.images[selectedImage]);
        }
      },
      child: AnimatedContainer(
        duration: defaultDuration,
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.all(8),
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: eSecondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ePrimaryColor.withOpacity(selectedImage == index ? 0 : 0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(defaultPadding / 2 + 2),
          ),
          child: CachedNetworkImage(imageUrl: widget.images[index]),
        ),
      ),
    );
  }
}
