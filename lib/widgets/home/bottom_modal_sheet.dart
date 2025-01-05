import 'package:flutter/material.dart';
import 'package:picapool/screens/Medical/medical_first_page.dart';
import 'package:picapool/screens/cabs/share_cab_page.dart';
import 'package:picapool/screens/trekking/trekking_page.dart';
import 'package:picapool/screens/turf/turf_first_page.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';
import 'package:picapool/widgets/product_lists/product_lists.dart';

// Define a custom class for items if needed
class Item {
  final String imagePath;
  final String text;
  final Widget destinationPage;
  bool isDisabled;

  Item({
    required this.imagePath,
    required this.text,
    required this.destinationPage,
    this.isDisabled = false,
  });
}

void showCustomModalBottomSheet(BuildContext context) {
  Size size = MediaQuery.of(context).size;

  // List of items with image paths, text, and corresponding destination pages
  List<Item> items = [
    Item(
      imagePath: "assets/images/request_vicinity.png",
      text: "Request vicinity",
      destinationPage: const RequestVicinity(),
    ),
    Item(
      imagePath: "assets/images/share_a_cab.png",
      text: "Share a cab",
      destinationPage: const ShareCabScreen(),
      isDisabled: true,
    ),
    Item(
      imagePath: "assets/images/buy_sell.png",
      text: "Buy and sell",
      destinationPage: const ProductListsPage(),
      isDisabled: true,
    ),
    // Item(imagePath: "assets/images/medical_help.png", text: "Medical help", destinationPage: RequestVicinityPage()),
    Item(
      imagePath: "assets/images/trekking.png",
      text: "Trekking",
      destinationPage: const TrekkingPage(),
      isDisabled: true,
    ),
    Item(
      imagePath: "assets/images/medical_help.png",
      text: "Medical help",
      destinationPage: MedicalAttentionPage(),
      isDisabled: true,
    ),
    Item(
      imagePath: "assets/images/share_turf.png",
      text: "Share a turf",
      destinationPage: TurfPage1(),
      isDisabled: true,
    ),

    // Add more items as needed
  ];

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        width: size.width,
        padding: const EdgeInsets.only(top: 20),
        height: size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (items[index].isDisabled) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => items[index].destinationPage),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          items[index].imagePath,
                          width: size.width * 0.25,
                          color:
                              (items[index].isDisabled) ? Colors.white : null,
                          colorBlendMode: BlendMode.color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontFamily: "MontserratM",
                              color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
