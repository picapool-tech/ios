import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/notification/notification_service.dart';
import 'package:picapool/screens/home/values/main_heading_options.dart';
import 'package:picapool/screens/home/widgets/carousel.dart';
import 'package:picapool/screens/home/widgets/main_heading_bottom_sheet_content.dart';
import 'package:picapool/screens/home/widgets/main_heading_options.dart';
import 'package:picapool/screens/home/widgets/pooling_categories.dart';
import 'package:picapool/screens/home/widgets/view_more_tinted_option.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/divider.dart';

class DownSheet extends StatefulWidget {
  final String searchQuery;
  final ScrollController scrollController;
  const DownSheet({
    super.key,
    required this.searchQuery,
    required this.scrollController,
  });

  @override
  State<DownSheet> createState() => _DownSheetState();
}

class _DownSheetState extends State<DownSheet> {
  @override
  Widget build(BuildContext context) {
    NotificationService().retrieveToken().then((toen) {
      debugPrint("GET FCM OTKEN: $toen");
    });

    return Container(
      alignment: Alignment.topCenter,

      padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
      // height: size.height,
      width: double.infinity,
      decoration: roundedContainer().copyWith(
        color: AppTheme.currentTheme.colorScheme.surfaceContainer,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: PicaValues.largeSpacing + 6,
            ),

            // ...List.generate(
            //   (MainHeadingOptions.headingOptions.length / 3).ceil(),
            //   (rowIndex) {
            //     final startIndex = rowIndex * 3;
            //     final endIndex = (startIndex + 3)
            //         .clamp(0, MainHeadingOptions.headingOptions.length);
            //     final rowItems = MainHeadingOptions.headingOptions
            //         .sublist(startIndex, endIndex);

            //     return Padding(
            //       padding: const EdgeInsets.only(bottom: 12),
            //       child: Row(
            //         spacing: 12,
            //         children: [
            //           ...rowItems.map((item) => Expanded(
            //                 child: MainHeadingOptionsWidget(
            //                   mainHeadingOptionData: item,
            //                 ),
            //               )),
            //           // Fill remaining spaces if less than 3 items in last row
            //           ...List.generate(
            //             3 - rowItems.length,
            //             (index) => const Expanded(child: SizedBox()),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
            //MAIN HEADING OPTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (index) => MainHeadingOptionsWidget(
                  mainHeadingOptionData:
                      MainHeadingOptions.headingOptions[index],
                ),
              ),
            ),

            const SizedBox(
              height: PicaValues.largeSpacing,
            ),

            //VIEW MORE BUTTON
            ViewMoreTintedOption(onPressed: () {
              showAllMainHeadingOptions();
            }),
            const CustomDivider(text: " Amazing offers near you "),
            const CarouselWidget(),
            const CustomDivider(text: " Pooling Categories "),
            const SizedBox(
              height: PicaValues.mediumSpacing,
            ),
            const PoolingCategoriesList(),
            const SizedBox(
              height: kToolbarHeight + 100,
            ),
          ],
        ),
      ),
    );
  }

  InkWell mainActionView({
    required Function onTap,
    required String title,
    required String assetImage,
    isDisabled = false,
  }) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (!isDisabled)
          ? () {
              onTap();
            }
          : null,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          Image.asset(
            // "assets/images/share_cab.png",
            assetImage,
            width: size.width * 0.275,
            color: (isDisabled) ? Colors.white : null,
            colorBlendMode: BlendMode.color,
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            title,
            // "Share a cab",
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  void showAllMainHeadingOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return const MainHeadingBottomSheetContent();
      },
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.elasticIn,
        reverseCurve: Curves.elasticOut,
        reverseDuration: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}
