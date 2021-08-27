import 'package:flutter/material.dart';
import 'package:notes_app/presentation/layout/adaptive.dart';
import 'package:notes_app/presentation/widgets/content_area.dart';
import 'package:notes_app/presentation/widgets/nimbus_info_section.dart';
import 'package:notes_app/values/values.dart';

//TODO:: Add proper testimonial Section
class TestimonialsSection extends StatelessWidget {
  TestimonialsSection({Key? key});
  @override
  Widget build(BuildContext context) {
    double screenWidth = widthOfScreen(context);
    double screenHeight = heightOfScreen(context);
    double contentAreaWidth = screenWidth * 0.8;
    double contentAreaHeight = screenHeight * 1.0;

    return ContentArea(
      width: contentAreaWidth,
      height: contentAreaHeight,
      child: Row(
        children: [
          Stack(
            children: [
//              Image.asset(
//                ImagePath.DEV_HEADER,
//                width: contentAreaWidth * 0.5,
//              ),
              Card(
                child: NimbusInfoSection1(
                  sectionTitle: StringConst.MY_TESTIMONIALS,
                  title1: StringConst.TESTIMONIALS_SECTION_TITLE,
                  hasTitle2: false,
                  body: StringConst.TESTIMONIALS_1,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
