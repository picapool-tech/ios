import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/screens/live_pooling/widgets/live_pooling_list_item.dart';

class LivePooling extends StatelessWidget {
  const LivePooling({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Pooling'),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kBottomNavigationBarHeight + 30),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: PicaOutlinedTextField(
              controller: controller,
              borderRadius: 12,
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                // Handle search logic here
                debugPrint('Search query: $value');
              },
              fillColor: Colors.white,
              filled: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.mic),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.sort),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Get.theme.colorScheme.secondary.lighten(75),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return LivePoolingListItem();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
