import 'package:flutter/material.dart';
import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/screens/home/values/main_heading_options.dart';
import 'package:picapool/screens/home/widgets/main_heading_options.dart';

class MainHeadingBottomSheetContent extends StatelessWidget {
  final List<MainHeadingOptionsData> headingOptions;

  const MainHeadingBottomSheetContent({
    super.key,
    this.headingOptions = MainHeadingOptions.headingOptions,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 0,
        childAspectRatio: 9 / 11,
      ),
      itemCount: headingOptions.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        MainHeadingOptionsData headingOption = headingOptions[index];
        return MainHeadingOptionsWidget(
          mainHeadingOptionData: headingOption,
        );
      },
    );
  }
}
